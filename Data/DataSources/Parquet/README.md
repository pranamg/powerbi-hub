---
title: Parquet
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Parquet

> Columnar file format.

## Why it is a good fit

Parquet is columnar and compressed, so Power BI reads only the columns a query
needs. It is usually much smaller than the equivalent CSV and refreshes
faster.

## Practice

- Point the source at a **folder of Parquet files** to pick up new
  partitions automatically, rather than at a single file.
- Keep related files in a consistent schema. Parquet merges folders by column
  name and silently produces nulls when columns differ.
- Combine with **incremental refresh** so history is not re-read on every run.
- Partition by date where the files are naturally divided that way.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [CSV](../CSV/)
- [Performance tuning](../../../Optimization/PerformanceTuning/)
- [Fabric OneLake](../../../Integrations/Fabric/OneLake.md)
