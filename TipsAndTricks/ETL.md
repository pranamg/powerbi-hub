---
title: ETL Tips & Tricks
tags: [tips]
audience: [all]
difficulty: intermediate
last_verified: 2026-09-29
---

# ETL Tips & Tricks

Practical guidance for Power Query. The dominant theme: **push work to the
source**. Every pattern below reduces either how much data crosses the wire
or how much the engine has to do in memory.

> Full guidance lives in [Power Query Best Practices](../Queries/PowerQuery/BestPractices/README.md).
> This page is the short, opinionated version.

---

## Query folding is the single biggest lever

If a step can be folded, the source database does the work and Power BI
receives less data. If it can't, you download the table and process it
locally. One non-foldable step early in a query can cost more than
everything else combined.

### What breaks folding

Steps that force evaluation locally, roughly in order of how often they bite:

| Step | Why it breaks |
|------|---------------|
| `Table.Buffer` | Forces the whole table into memory. The single most common cause |
| Adding a calculated column | Most calculated column expressions cannot fold |
| `Table.AddCustomColumn` | Same, unless the expression is foldable |
| Merging with a local table | A merge with an in-memory table cannot fold |
| `Text.PadLeft` / `Text.Format` | Most text functions do not fold |
| `List.Transform` on a non-foldable list | Depends on source type |
| `Table.ReplaceValue` | Foldable only for some source types and value types |
| Reordering or splitting columns | Usually foldable; check rather than assume |

### What preserves folding

Native column selection, filtering, sorting, grouping, removing duplicates,
merging (when both sides are remote), and combining queries.

### Check it

Enable **View → Query Diagnostics → Diagnose** in Power Query Editor, or hover
the step to see the "folding" indicator. Do this before optimising anything
else.

For a per-step breakdown, see
[Power Query Best Practices](../Queries/PowerQuery/BestPractices/README.md).

---

## Staging and staging well

A **staging query** is a query that only references another query and
normalises its output. Two or three staging layers, each with one job, is the
pattern worth adopting:

```
Source query      → connection, credentials, base filtering
  └─ Staging 1    → types, column selection, renaming
      └─ Staging 2 → business logic, merges, derived columns
          └─ Dim/Fact → final shape handed to the model
```

The payoff: each layer has one responsibility, so a change to business logic
never requires reworking the connection, and the model load is trivial to
audit.

Avoid over-layering. If a staging query adds no clarity, remove it.

---

## Remove columns early

Every column you keep costs refresh time, memory, and model size. Remove
anything the model will never use:

```m
= let
    Source = Csv.Document(File.Contents(CsvPath), [Delimiter=",", Columns=47, Encoding=65001]),
    // Keep only what the model needs, then let Power BI infer types.
    Trimmed = Table.SelectColumns(Source, {"OrderDate", "CustomerKey", "ProductKey", "SalesAmount"}),
    Typed = Table.TransformColumnTypes(Trimmed, {
        {"OrderDate", type date},
        {"CustomerKey", Int64.Type},
        {"ProductKey", Int64.Type},
        {"SalesAmount", Currency.Type}
    })
in
    Typed
```

**Select columns, then set types.** A large `Table.PromoteHeaders` followed by
manual type edits is the same work with more steps. Doing it in one place
makes the intended model visible in one screen.

Note that `Table.SelectColumns` preserves order — put the key columns first,
which also helps the model.

---

## Choose data types deliberately

| Situation | Use |
|-----------|-----|
| Keys and IDs that will be joined | `Int64.Type` or `Text.Type` — pick one and be consistent |
| Money | `Currency.Type` (or a fixed decimal, not `type number`) |
| Percentages stored as fractions | `type number`; set format string at the model level instead |
| Dates with a time component | `type datetime` only if you need the time |
| True date columns | `type date` — smaller than `datetime`, and enables date hierarchies |

Avoid `type number` for anything that should not support fractional values.
Ints compress far better in VertiPaq and avoid currency-floating-point
surprises.

---

## Parameters and dynamic sources

A **parameter query** is a single-value table other queries reference. It is
the right way to make a refresh-time choice without editing M code:

```m
// Parameter query
let
    Source = "AdventureWorks",
    UseDirectQuery = false
in
    Source
```

Reference it with `#"Parameter Name"` to make the dependency explicit and
visible in the dependency view.

See [fnParameterTable.m](../Queries/PowerQuery/CustomFunctions/fnParameterTable.m)
in this hub for a fuller pattern, and
[fnDynamicDataSource.m](../Queries/PowerQuery/CustomFunctions/fnDynamicDataSource.m)
for selecting a source from a parameter.

For multi-source consolidation, `Table.Combine` over a folder is often better
than maintaining a list by hand.

---

## Incremental refresh

For large tables, refresh only the changed range. The rule:

- Filter on a date column that exists **in the source**, not one you create
- The range must be able to refresh *recent* data *and* historical data that
  can change (late-arriving facts, restatements)
- Set the "archive" boundary so old partitions are never re-read

`fnDateTableGenerator.m` in this hub generates the date scaffolding these
setups reference. See
[Data Sources](../Data/DataSources/README.md) for source-specific notes.

---

## Custom functions

A custom function is reusable, parameterised M. It is worth the small overhead
when a transformation is used more than once or is error-prone.

| Rule | Why |
|------|-----|
| Keep them genuinely reusable | A function used once is indirection, not abstraction |
| Document parameters | A future reader cannot infer what `optionalAny` was meant to be |
| Avoid deep nesting | M nests expressions; five levels is unreadable |
| Prefer `each` over `_` for anything non-trivial | `each` can be named, which matters in a let binding |
| Return a table, not a value, for tabular transforms | Easier to chain and to debug |

This hub has five worked examples in
[Custom Functions](../Queries/PowerQuery/CustomFunctions/README.md),
including [fnErrorHandler.m](../Queries/PowerQuery/CustomFunctions/fnErrorHandler.m)
and [fnCleanText.m](../Queries/PowerQuery/CustomFunctions/fnCleanText.m).

---

## Error handling

Errors are a design question, not a debugging accident. Decide per step
whether to keep the row, replace the value, or fail loudly.

```m
// Keep the row, mark it.
= Table.AddColumn(Source, "HasError", each try [Sales] is error, type logical)

// Replace the bad value.
= Table.ReplaceValue(Source, "Sales", null, "#error", Replacer.ReplaceValue, {"Sales"})

// Keep only good rows.
= Table.SelectRows(Source, each [Sales] <> null and not ([Sales] is error))
```

Silently swallowing errors produces a model that is wrong rather than one that
is visibly broken. Where a bad row is tolerable, **keep it and flag it** — the
flag can become a quality measure.

---

## Performance checklist

Work in this order; each step is worth more than the next:

1. **Is it folding?** If not, fix that first. Everything else is noise until
   the source is doing the work.
2. **Are you fetching whole tables?** Select columns and filter in the source
   step, not later.
3. **Is it a dimension or a fact?** A dimension with 20 columns of unique text
   is a memory problem before it is a size problem.
4. **Is the column type right?** `Int64` and `date` compress far better than
   `number` and `datetime`.
5. **Are you doing repeated expensive work?** A nested `Table.SelectRows` per
   row is O(n·m); a merge is not.
6. **Is the refresh concurrent with query time?** Schedule refreshes outside
   business hours. See [Monitoring](../Monitoring/README.md).

---

## Mistakes that are expensive to undo

| Mistake | Why it costs |
|---------|--------------|
| Calculated column where a Power Query column belongs | Increases model size and refresh time; cannot be optimised in the model |
| `Table.Buffer` added to "fix" a slow step | Hides the real problem and inflates memory |
| Changing a column type after it is used downstream | Requires re-checking every dependent step |
| Hard-coded file paths or credentials | Breaks on refresh from the service |
| Nested functions four levels deep in one `let` | Unmaintainable and undebuggable |
| Filtering in the model that should be in the source | Every refresh still pays for the rows |

---

## Related

- [Power Query Best Practices](../Queries/PowerQuery/BestPractices/README.md) — the
  fuller treatment
- [Power Query Tips & Tricks](./PowerQuery.md) — shorter, syntax-level tips
- [Custom Functions](../Queries/PowerQuery/CustomFunctions/README.md) — worked examples
- [Data Sources](../Data/DataSources/README.md) — per-source guidance
- [Memory Optimization](../Optimization/MemoryOptimization/README.md)
- [ETL Best Practices](../Data/ETL/BestPractices/README.md)
