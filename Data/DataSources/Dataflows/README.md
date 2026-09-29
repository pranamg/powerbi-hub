# Dataflows

> Power BI dataflows as an upstream source.

## Why use one

A dataflow centralises transformation logic that would otherwise be duplicated
across every report. It is the lightweight option when a full data warehouse
is not warranted.

## Practice

- Use **standard vs optimised** deliberately. Optimised dataflows write to
  read-optimised storage and are faster to query, but they are read-only to
  downstream computation.
- Do not build a dependency chain that is more than a couple of dataflows
  deep; refresh becomes slow and hard to trace.
- Enable **incremental refresh** on large tables.
- Keep the dataflow as the place transformation happens. Reports should apply
  only presentation logic.


## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [Fabric Dataflow Gen2](../../../Integrations/Fabric/DataflowGen2.md)
- [ETL best practices](../../ETL/BestPractices/)
