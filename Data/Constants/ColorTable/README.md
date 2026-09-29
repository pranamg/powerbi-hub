# ColorTable

> Named color constants for consistent formatting.

## Purpose

Centralising colors in a table means a palette change is a data change, not a
rewrite of every measure. Measures reference the table, and a theme or
slicer can then drive the colors.

## Pattern

Create a two-column table with a unique name and a hex value, then format by
field using that table. Keep the names stable — renaming a constant breaks
every measure that references it.

## Practice

- Store colors as text in `#RRGGBB` form.
- Keep the table in a separate table rather than a calculated column, so it can
  be filtered and sorted deliberately.
- Drive consistent *semantic* colors (for example, good/warning/bad) from this
  table rather than picking colors per visual.

## Related

- [Other constants](../Other/)
- [Date table constants](../DateTable/)
- [DAX tips](../../../TipsAndTricks/DAX.md)
