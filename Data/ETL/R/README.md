---
title: R
tags: [power-query, etl]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# R

> R-based ETL.

## Practice

- The R runtime and any packages must be installed wherever refresh runs,
  including the gateway.
- Return a `data.frame` with stable columns and types.
- Use R where a package has no M equivalent; otherwise prefer Power Query.
- R cannot fold, so narrow the data before the script runs.
- **Record package versions.** An unpinned package upgrade can silently change
  output.

## Related

- [R data sources](../../DataSources/R/)
- [R visuals](../../../Visuals/RVisuals/)
