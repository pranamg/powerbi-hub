---
title: Memory Optimization
tags: [performance, optimization]
audience: [model-author]
difficulty: advanced
last_verified: 2026-09-29
---

# Memory Optimization

> Reducing the memory footprint of a model.

## Where memory goes

An Import model is held in compressed in-memory storage, so cost is driven by
**distinct value combinations**, not row count. A high-cardinality string
column can cost more than a large numeric one.

## Highest-impact changes

1. **Set types correctly.** A decimal or whole number column is far cheaper
   than text. Check for columns that were inferred as text because of stray
   characters.
2. **Reduce high-cardinality text**, especially unique identifiers, free-text
   fields, and concatenated strings. Where a large dimension of distinct values
   is genuinely needed, consider moving it to DirectQuery.
3. **Remove unused columns** early in the query, not in the model.
4. **Avoid bi-directional relationships** unless the model needs them; they
   widen the filter context and force more materialisation.
5. **Sort large dimension columns** — sorting a text column can enable better
   compression.
6. **Set low-priority for rarely used large tables** to allow aggressive
   compression.

## Diagnosis

- Compare model size in **Power BI Desktop** against row count to spot a model
  that is disproportionately large.
- **DAX Studio** or the **Performance Analyzer** in Desktop will show which
  tables dominate.
- Check the **Capacity Metrics app** to see whether a production problem is
  actually a memory limit rather than a modelling one. See
  [Capacity Planning](../../Monitoring/CapacityPlanning.md).

## Diagnosing with VertiPaq Analyzer

Do not guess at where memory goes. **VertiPaq Analyzer** is a free external
tool from SQLBI that reports exactly which columns, tables, and encodings
account for the model's size.

### Running it

1. Install [VertiPaq Analyzer](https://www.sqlbi.com/tools/vertipaq-analyzer/)
2. Open the model in Power BI Desktop (Analyzer connects to the running
   instance)
3. Open the external tools pane and launch VertiPaq Analyzer
4. Read the **Columns** and **Tables** sheets

You can also run it against a deployed model over XMLA, which is how you
diagnose a production model without downloading it.

### Reading the results

The **Table** column on the `Model_Schema` sheet gives a size breakdown with
compressed and uncompressed figures, plus the **Cardinality** of each column.
That is the single most useful view: a table far larger than its row count
implies, containing a column with cardinality near the row count, is a
high-cardinality text column eating the model.

The **Dictionary Size**, **Data Size**, and **Hash Size** components tell you
*why*:

| Component | Grows with |
|---|---|
| Dictionary size | Distinct values per column. High cardinality text is the usual culprit |
| Data size | Rows × columns, and bit-width of numeric types. An `Int64` where a `Byte` would do costs eight times more |
| Hash size | Relationship keys and high-cardinality columns. Relationships cost memory on both sides |

### The four encodings, and why they matter

VertiPaq chooses an encoding per column. Understanding which one you got tells
you what to change.

| Encoding | Best for | Symptom of a problem |
|---|---|---|
| Value encoding | Low-cardinality integers, dates, booleans | Column is 8 bytes per value when 1 would do |
| Dictionary encoding | Repeated strings — a `Status` or `Category` column | Dictionary size is large relative to data size |
| Run-length encoding | Sorted, highly repetitive data | A sorted date column should be tiny; if not, it is not sorted |
| Hash encoding | High-cardinality text, relationship keys | Large hash size means expensive joins |

A high-cardinality string column is the most common finding, and it is usually
either a free-text field no one queries, or a concatenated key that should be
split.

### Acting on it

| Finding | Fix |
|---|---|
| Unique identifier column | Remove it. A key already exists for the relationship |
| Free-text column | Remove it, or move the table to DirectQuery |
| Numeric stored as text | Fix the type in Power Query, not in the model |
| Whole number stored as decimal | Change to `Int64` |
| Large unsorted dimension | Sort the column by its key, or a natural order |
| Table that genuinely needs this data | Move to DirectQuery, or partition it |

## Partitioning large tables

Once a table is genuinely large, partitioning lets VertiPaq compress harder and
lets you refresh part of it.

- Partition by a **date column that exists in the source**, not one you create.
- Partitions must be able to refresh *recent* data **and** historical data that
  can change — late-arriving facts and restatements are the usual reason this
  fails.
- Set an **archive boundary** so old partitions are never re-read.
- Keep partitions reasonably sized. Too many tiny partitions is its own cost.
- `fnDateTableGenerator.m` in this hub generates the date scaffolding these
  setups reference.

**Partitioning is a second-line fix.** Column type errors and unnecessary
columns cost you far more, and are far easier to fix. Partition first only when
the model is already clean and the fact table is genuinely large.

## Measure the model, do not estimate it

Power BI Desktop's model size counter is the fastest sanity check. Compare it
to row count:

- Model much larger than rows × columns would suggest → look for a type or
  cardinality problem
- Model far smaller after removing a column → that column was the problem

Re-measure after every change. Memory work without measurement is guesswork.

## Related

- [Performance tuning](../PerformanceTuning/)
- [Composite models](../CompositeModels.md)
- [Capacity Planning](../../Monitoring/CapacityPlanning.md)
- [Metrics](../../Monitoring/Metrics/)
- [ETL Tips](../../TipsAndTricks/ETL.md) — where columns are removed at the source
- [VertiPaq Analyzer](https://www.sqlbi.com/tools/vertipaq-analyzer/)
