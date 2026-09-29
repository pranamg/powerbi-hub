# Model 1 — Minimal Star Schema

> A complete, readable star-schema model: one fact table, three dimensions, and
> a calculated date table.

## Files

| File | Contents |
|------|----------|
| [model.tmdl](./model.tmdl) | Model-level settings and culture |
| [DimDate.tmdl](./DimDate.tmdl) | Calculated date table, marked as the model's date table |
| [DimProduct.tmdl](./DimProduct.tmdl) | Product dimension with a hierarchy and summary measures |
| [DimCustomer.tmdl](./DimCustomer.tmdl) | Customer dimension, including the column used for RLS matching |
| [FactSales.tmdl](./FactSales.tmdl) | Sales fact table and its measures |
| [relationships.tmdl](./relationships.tmdl) | The three many-to-one relationships |

## What this model demonstrates

- **Star schema.** One fact table, dimensions joined many-to-one.
- **Single-direction filtering** on every relationship.
- **A dedicated date table**, marked with `__PBI_LocalDateTable`, rather than
  reusing a date column from the fact table.
- **Surrogate integer keys** rather than natural keys, with the fact table
  foreign keys hidden.
- **Measures rather than calculated columns** for anything aggregatable.
- **VAR-bound filter context** before iteration, and `DIVIDE` for every ratio.
- **Time intelligence written out explicitly**, which is what makes the model
  minimal and readable.

## Loading it

`DimDate` is a calculated table and works as-is. The other partitions point at
placeholder CSV paths:

```
C:\Data\dim_product.csv
C:\Data\dim_customer.csv
C:\Data\fact_sales.csv
```

Replace each `Source` step with a real connection before loading. See
[Data/DataSources/](../) for the connection pattern that suits your source
type. Prefer reading from a view or table you control over a raw file, and
prefer filtering at the source over filtering in the model.

To bring this into a Power BI project, create a folder with
*Power BI Project* (PBIP) and place these files under its model definition
directory, or use the TMDL view in Desktop.

## Reviewing it against the standard

Use this model as a checklist when reviewing a real one:

- [ ] Every fact table's grain is documented in its description
- [ ] Relationships are single-direction and many-to-one
- [ ] The date table is contiguous and marked as a date table
- [ ] Foreign key columns in the fact table are hidden
- [ ] Measures use `[Table].[Measure]` notation
- [ ] Ratios use `DIVIDE`, never `/`
- [ ] Iterating measures bind the context to a `VAR` first
- [ ] Tables, columns, and measures have descriptions

## Extending it

[Model 2](../Model2/) builds on this and adds a second fact table, a
role-playing date, and calculation groups. Once the ideas in this model are
comfortable, Model 2 is the natural next step.

## Related

- [Model templates](../Templates/) — scaffolding for a new model
- [TMDL templates](../../../Scripts/TMDL/) — the templates this model is built from
- [DAX best practices](../../../Queries/DAX/BestPractices/)
- [Development standards](../../../Governance/DevelopmentStandards.md)
