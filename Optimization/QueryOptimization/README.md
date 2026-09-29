---
title: Query Optimization
tags: [performance, optimization]
audience: [model-author]
difficulty: advanced
last_verified: 2026-09-29
---

# Query Optimization

> Improving DAX and query performance.

## Diagnose before changing

- **Performance Analyzer** (Desktop) gives per-visual timings; the slowest
  visual is where to start.
- **DAX Studio** allows server timings and query plans on a capacity.
- **DAX Query View** in Desktop lets you test expressions directly, which is
  faster than editing a report. See
  [DAXQueryView.md](../../Documentation/UserGuides/DAXQueryView.md).
- **Server timings** distinguish a slow model from a slow visual. A visual can
  be slow simply because it asks for too many rows.

## Common causes and fixes

| Symptom | Usual cause | Fix |
|---------|-------------|-----|
| Slow measure | Repeated `CALCULATE` with the same filter | Bind the filter context to a `VAR` |
| Slow visual | Too many rows returned to the client | Aggregate in the model, not the visual |
| Slow over a large table | Filter not pushed to the source | Use a variable to capture the filter context |
| Slow after adding a relationship | Bi-directional filter or an ambiguous relationship | Fix direction; use `CROSSFILTER` deliberately |
| Slow with a date slicer | Wrong active relationship | Use `USERELATIONSHIP` with an inactive relationship |

## Practice

- Filter **early and narrow**; a visual returning 100k rows is a design
  problem, not a DAX problem.
- Use `TREATAS` rather than `INTERSECT` or `CONTAINS` for pattern-matching
  filters — it performs better and reads more clearly.
- Replace nested `IF` with `SWITCH` for readability, and prefer explicit
  `DIVIDE` over `/`.

## Related

- [DAX best practices](../../Queries/DAX/BestPractices/)
- [Measure patterns](../../Queries/DAX/Measures/)
- [Performance tuning](../PerformanceTuning/)
