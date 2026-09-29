---
title: DAX Best Practices
tags: [dax, best-practices]
audience: [model-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# DAX Best Practices

> Practices for readable and fast DAX.

## Readability

- **Use `VAR` for every intermediate result.** Repeating a `CALCULATE` with
  the same filter is both slower and harder to read. A variable evaluated
  inside `FILTER` is a common performance trap, because the engine may
  evaluate it per row.
- **Prefer `SWITCH` to nested `IF`**, and `&&`/`||` to nested `IF` conditions.
- **Always use `DIVIDE`**, never `/`, so a zero denominator returns blank.
- Name variables for what they mean (`TotalSales`), not for their type.
- Use `[Table].[Measure]` notation in measures that may be renamed or moved.

## Performance

- **Filter early, filter narrow.** A measure that iterates a large table is
  usually the problem.
- Use **`TREATAS`** for pattern-matching filters rather than `INTERSECT` or
  `CONTAINS`.
- Avoid `FILTER(Table, ...)` where `CALCULATE(Table, ...)` would do; the
  latter can fold and is faster.
- Do not use `DISTINCTCOUNT` where a pre-aggregated or semi-additive measure
  is available.
- Check a measure with **DAX Query View** before shipping it. See
  [DAXQueryView.md](../../../Documentation/UserGuides/DAXQueryView.md).

## Semantics

- **Measures, not calculated columns**, for anything aggregatable or that
  depends on filter context.
- A calculated column is evaluated at **refresh** time and is not
  context-aware. This is the rule most often broken by accident.
- Use **calculation groups** to avoid repeating time-intelligence logic across
  measures. See [CalculationGroups](../CalculationGroups/).

## Related

- [Measures](../Measures/) · [Calculated columns](../CalculatedColumns/)
- [DAX tips](../../../TipsAndTricks/DAX.md)
- [Query optimization](../../../Optimization/QueryOptimization/)
