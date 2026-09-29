# Model 1

> Example semantic model.

## Intended scope

A minimal model used to demonstrate structure: a fact table, conformed
dimensions, and a handful of measures. Useful as a starting point before
adding complexity.

## Conventions applied

- Star schema with a single fact table.
- A dedicated date table, marked as such. See
  [DateTable_Basic.dax](../../Constants/DateTable/DateTable_Basic.dax).
- Surrogate keys rather than natural keys in the fact table.
- Hidden foreign key columns.
- Measures rather than calculated columns for anything aggregatable.

## Related

- [Data model templates](./../Templates/)
- [DAX measures](../../../Queries/DAX/Measures/)
- [Development standards](../../../Governance/DevelopmentStandards.md)
