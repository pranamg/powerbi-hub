# Excel

> Working with Excel workbooks as a data source.

## The main risk

Excel is a presentation format, not a data store. Files are frequently
re-saved while a refresh is reading them, which produces a failed or partial
load. When Excel is genuinely the system of record, treat it accordingly.

## Practice

- **Read from a published extract** placed in a known location rather than a
  file a person is actively editing.
- Read from a **table or named range**, not a fixed cell range, so added rows
  are picked up.
- Remove merged cells, totals rows, and blank separator rows before loading.
- Where a workbook holds several sheets, load only the ones the model needs.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [CSV](../CSV/)
- [Data sources folder](../)
