---
title: Model 2 — Multi-Fact Model with Role-Playing Dates
tags: [modeling, tmdl, reference]
audience: [model-author]
difficulty: advanced
last_verified: 2026-09-29
---

# Model 2 — Multi-Fact Model with Role-Playing Dates

> Extends [Model 1](../Model1/) with the three things that make a real model
> harder than the minimal case: a second fact table, a role-playing date, and
> calculation groups.

## Files

| File | Contents |
|------|----------|
| [model.tmdl](./model.tmdl) | Model-level settings and culture |
| [DimDate.tmdl](./DimDate.tmdl) | Calculated date table with a fiscal calendar, plus the date-role selection table |
| [DimShared.tmdl](./DimShared.tmdl) | The two conformed dimensions, Product and Store |
| [FactTables.tmdl](./FactTables.tmdl) | `FactSales` and `FactInventory`, with their measures |
| [relationships.tmdl](./relationships.tmdl) | Seven relationships, including one inactive |
| [CalculationGroups.tmdl](./CalculationGroups.tmdl) | Time Intelligence and Currency Conversion groups |

## What this model demonstrates

### Two fact tables at different grains

| Fact table | Grain | Additive over time? |
|------------|-------|---------------------|
| `FactSales` | one row per order line | Yes |
| `FactInventory` | one row per product, per store, per day | **No** — it is a snapshot |

`FactInventory` is a balance, not a flow. Summing `Units On Hand` across a
month double-counts the same units every day, so the inventory measures report
a closing position or an average instead. This is the single most common
modelling error in a multi-fact model, and it produces numbers that look
entirely plausible.

### A role-playing date

`FactSales` joins `DimDate` twice — once on order date, once on ship date.
Power BI allows only one **active** relationship per table pair, so the ship
date relationship is inactive and reached with `USERELATIONSHIP`:

```dax
Sales by Ship Date =
    CALCULATE(
        [Total Sales],
        USERELATIONSHIP('FactSales'[ShipDateKey], 'DimDate'[Date])
    )
```

A `DimDateRole` table with a `Role` column lets a slicer drive the choice, and
`Sales by Selected Date Role` switches on it. Prefer the explicit
`USERELATIONSHIP` form unless a slicer genuinely needs to drive the selection —
it is easier to review.

Note that `ShipDateKey` is nullable, because an unshipped order has no ship
date. A relationship on a nullable key silently excludes those rows from
measures using `USERELATIONSHIP`. That is correct, but it is why totals differ
between the order-date and ship-date measures.

### Conformed dimensions

`DimProduct` and `DimStore` are shared by both fact tables, so a single slicer
on either filters sales and inventory together.

### Calculation groups

[Total Sales] is defined **once**. The Time Intelligence group supplies the
Current, YTD, prior-year, and growth variants at query time, so a new base
measure gains all four without anyone writing them. The Currency group composes
with it as an independent axis, giving all four combinations with no duplicated
measures.

This is what removes the "the numbers disagree between two pages" class of
defect, which comes from hand-written time-intelligence variants drifting apart
across measures.

## Loading it

As with [Model 1](../Model1/), `DimDate` and `DimDateRole` are calculated
tables and need no source. The other partitions use placeholder paths:

```
C:\Data\dim_product.csv
C:\Data\dim_store.csv
C:\Data\fact_sales.csv
C:\Data\fact_inventory.csv
```

Replace each `Source` step with a real connection before loading.

## A caveat on CalculationGroups.tmdl

**The calculation group syntax in this file is illustrative, not
authoritative.** Calculation groups are serialised differently across Power BI
Desktop versions, and the exact TMDL representation is version-dependent. Read
that file for *what* the groups should contain and *why*, but export the real
definition from your own model rather than assuming this file will load as-is.
Everything else in this folder is intended to be usable directly.

## Things this model gets right that are easy to get wrong

- **Historical cost on the transaction.** `FactSales[Unit Cost]` is recorded at
  time of sale rather than read from `DimProduct[Standard Cost]`. Using the
  dimension attribute makes margin restate silently after a cost change.
- **Non-additive measures are named as such.** `Closing Units On Hand` and
  `Average Units On Hand` say what they are, so a report author does not sum
  them by mistake.
- **Cross-fact measures are flagged.** `Days of Cover` deliberately combines an
  inventory measure with a sales measure, and its description says so, because
  the two are at different grains.
- **One active relationship per pair,** stated explicitly in
  [relationships.tmdl](./relationships.tmdl) along with why.

## Related

- [Model 1](../Model1/) — the minimal case this builds on
- [Calculation group examples](../../../Queries/DAX/CalculationGroups/)
- [Composite model patterns](../../../Optimization/CompositeModels.md)
- [Query optimization](../../../Optimization/QueryOptimization/)
