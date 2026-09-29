---
title: Tables
tags: [design, visuals]
audience: [report-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Tables

> Table visual designs.

## Design guidance

- **Do not use a table visual as a report page.** It encourages scrolling and
  defeats the point of summarising. Use it for lookup detail alongside a
  visual, or as an appendix.
- **Sort meaningfully** — by measure descending, or by a defined business
  order. Alphabetical is rarely the answer.
- Keep the **row count modest.** If more rows are needed, the visual choice is
  probably wrong.
- **Format numbers consistently** and use a shared format string so the same
  measure looks the same everywhere. See
  [ConditionalFormatting.dax](../../../Queries/DAX/Measures/ConditionalFormatting.dax).
- **Totals** should be a measure with an explicit format string, not a column
  total, so the total responds correctly to slicers.

## Related

- [Cards](../Cards/) · [Buttons](../Buttons/) · [Other](../Other/)
- [Design guidelines](../../Guidelines/)
- [Themes](../../Themes/)
