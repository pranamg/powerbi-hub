---
title: Performance Tuning
tags: [performance, optimization]
audience: [model-author]
difficulty: advanced
last_verified: 2026-09-29
---

# Performance Tuning

> End-to-end performance practice for models and reports.

## Where time is actually spent

Refresh, query, and visual render are separate problems with separate fixes.
Establish which one is slow before changing anything:

| Problem | Symptom | Where to look |
|---------|---------|---------------|
| Slow refresh | Data is stale | Query design, source load, gateway |
| Slow query | Pages time out or visuals show spinning | DAX, model shape, capacity |
| Slow visual | Some pages slow, others fine | Number of rows returned, visual type |

## Refresh

- Narrow the source early: filter rows and columns before transformation.
- Avoid steps that break query folding.
- Use **incremental refresh** for large fact tables rather than reloading
  history.
- Schedule refreshes to avoid **capacity contention** with interactive users.

## Query

- See [QueryOptimization](../QueryOptimization/) for DAX-level fixes.
- Confirm the model is not memory-constrained; see
  [MemoryOptimization](../MemoryOptimization/).

## Visual

- Return fewer rows. Aggregating in the model is usually far faster than
  aggregating in the visual.
- Avoid highly custom visuals on large datasets, and check the visual's
  performance impact in the Performance Analyzer.

## Measure the change

Re-measure after each change. Performance work without a before-and-after
number is guesswork, and the next person cannot tell whether a change helped.

## Related

- [Composite models](../CompositeModels.md)
- [Metrics](../../Monitoring/Metrics/)
- [Monitoring](../../Monitoring/)
