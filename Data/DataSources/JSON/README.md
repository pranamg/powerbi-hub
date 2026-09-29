---
title: JSON
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# JSON

> JSON files and JSON web APIs.

## Practice

- For APIs, prefer a **structured data source** over a folder of `.json`
  files; it handles pagination and incremental refresh for you.
- When using Web.Contents, set the **API limit** so pagination is followed
  rather than returning only the first page.
- Transform in Power Query rather than nesting `Table.Pivot` and
  `Record.Field` calls. The result is far easier to read and to change.
- Flatten nested records deliberately and name the resulting columns, since
  default names are rarely meaningful.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [Web](../Web/)
- [XML](../XML/)
- [Power Query custom functions](../../../Queries/PowerQuery/CustomFunctions/)
