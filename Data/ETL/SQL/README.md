# SQL

> SQL-based extraction and transformation.

## Practice

- Push work to the database where it is cheaper there: pre-aggregation and
  filtering reduce rows crossing the network.
- **Prefer views or stored procedures over ad hoc SQL in Power BI.** It keeps
  logic versioned, testable, and reviewable, and it keeps the model portable.
- Select explicit columns, never `SELECT *`.
- Ensure columns are typed consistently and avoid implicit conversions, which
  quietly disable efficient plans.
- Add an index appropriate to the filter columns on large tables, and avoid
  applying functions to indexed columns in the `WHERE` clause.
- Set sensible **timeouts and connection limits** so a slow query cannot
  exhaust the gateway.

## Related

- [SQL data sources](../../DataSources/SQL/)
- [Performance tuning](../../../Optimization/PerformanceTuning/)
- [Query optimization](../../../Optimization/QueryOptimization/)
