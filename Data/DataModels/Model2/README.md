# Model 2

> Example semantic model.

## Intended scope

Extends the structure of [Model 1](../Model1/) with additional measures,
hierarchies, and a second fact table, to show how a model grows without
losing its shape.

## What it demonstrates

- Multiple fact tables sharing conformed dimensions.
- Role-playing dimensions handled with `USERELATIONSHIP`, using inactive
  relationships where the two dates differ.
- Display folders to keep large measure sets navigable.

## Related

- [DAX measures](../../../Queries/DAX/Measures/)
- [Calculation groups](../../../Queries/DAX/CalculationGroups/)
- [Composite model patterns](../../../Optimization/CompositeModels.md)
