---
title: Model Templates
tags: [modeling, tmdl, reference]
audience: [model-author]
difficulty: advanced
last_verified: 2026-09-29
---

# Model Templates

> Scaffolding to copy when starting a new semantic model.

## Before you start

Decide the grain of each fact table and write it down. Most model problems
trace back to an unstated grain.

## Default structure

```
Model
├── FactSales              (grain: one row per order line)
├── FactInventory          (grain: one row per product per day)
├── DimDate                (marked as a date table)
├── DimProduct
├── DimCustomer
└── DimStore               (conformed across both fact tables)
```

## Checklist

- [ ] Every fact table's grain is documented in its description
- [ ] Relationships are single-direction and many-to-one
- [ ] Date table is contiguous and marked as a date table
- [ ] Columns are typed; IDs stored as whole numbers
- [ ] A dedicated date table exists rather than relying on the fact table's date
- [ ] Names follow [NamingConventions.md](../../../Governance/NamingConventions.md)

## Related

- [Model 1](../Model1/) · [Model 2](../Model2/)
- [DAX best practices](../../../Queries/DAX/BestPractices/)
