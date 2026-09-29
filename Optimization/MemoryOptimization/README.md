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
  actually a memory limit rather than a modelling one.

## Related

- [Performance tuning](../PerformanceTuning/)
- [Composite models](../CompositeModels.md)
- [Metrics](../../Monitoring/Metrics/)
