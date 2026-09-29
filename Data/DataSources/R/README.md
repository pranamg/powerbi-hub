---
title: R
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# R

> R-based data sources.

## Practice

- As with Python, the **R source must be installed wherever refresh runs**,
  including the gateway.
- Return a `data.frame` with stable column types and names.
- Use R where the transformation depends on a package that has no M
  equivalent; otherwise prefer Power Query.
- A script in R cannot fold, so narrow the data in M first.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [R ETL](../../ETL/R/)
- [R visuals](../../../Visuals/RVisuals/)
