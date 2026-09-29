---
title: Calculated Columns
tags: [dax, modeling]
audience: [model-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Calculated Columns

> Calculated column patterns.

## Status

This folder is a stub. No content has been written yet.

## When a calculated column is appropriate

Use one when the value **does not depend on filter context**, and is either
static or derivable at refresh time:

- A key or hash column combining several fields.
- A sort-order column for a display.
- A classification bucket derived from existing columns.
- A slowly changing dimension attribute.

## When it is not

Anything that aggregates. This is the most common mistake in Power BI models:

- A running total, a margin, or a percentage of a total. These need filter
  context and **must be measures**.
- Anything that should respond to a slicer. A calculated column cannot.

A calculated column is also materialised at refresh: it increases model
memory, and it does not recalculate when a measure is evaluated.

## Guidance

- Calculated columns are evaluated **row by row, with no context**, so avoid
  relying on a related table's value without a `RELATED` or `RELATEDTABLE`
  call.
- Watch the **refresh time** impact. A calculated column over a large fact
  table is a real cost.
- Consider whether the logic belongs in the source or in a dataflow instead,
  where it can be tested.

## Related

- [Measures](../Measures/)
- [DAX best practices](../BestPractices/)
- [Memory optimization](../../../Optimization/MemoryOptimization/)
