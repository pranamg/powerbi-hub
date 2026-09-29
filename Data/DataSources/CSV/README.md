---
title: CSV
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# CSV

> Delimited text files.

## Practice

- Confirm the **delimiter, encoding, and header row** explicitly. Relying on
  defaults causes subtle misreads, particularly with semicolon or tab
  delimiters and non-ASCII characters.
- Detect the data type per column, but check the result. Leading zeros in
  identifiers are lost if a column is typed as a number; load such columns as
  text.
- Watch for dates in ambiguous formats. A `01/02/2026` value is ambiguous
  between day-first and month-first, and the default assumption is not
  reliable.
- Store files in a location the gateway can reach, and avoid a desktop path on
  a different machine from the gateway.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [Excel](../Excel/)
- [Parquet](../Parquet/)
- [Power Query tips](../../../TipsAndTricks/PowerQuery.md)
