---
title: SQL
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# SQL

> Connecting Power BI to SQL Server, Azure SQL, and Synapse.

## Choosing an approach

| Source | Approach |
|--------|----------|
| SQL Server / Azure SQL | Import for most workloads; DirectQuery for near-real-time or very large data |
| Synapse | DirectQuery, or a Fabric Lakehouse where available |

## Practice

- Import a **view or table you control** rather than querying base tables
  directly, so business logic is versioned and testable.
- Avoid `SELECT *`. Project only the columns the model needs; wide staging
  tables are the usual cause of slow refreshes.
- Keep filters in the model, not in ad hoc SQL generated per report.
- Watch for implicit type conversion. A numeric column compared against a
  string literal prevents efficient query folding.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [SQL ETL patterns](../../ETL/SQL/)
- [Optimization](../)
- [Power Query best practices](../../../Queries/PowerQuery/BestPractices/)
