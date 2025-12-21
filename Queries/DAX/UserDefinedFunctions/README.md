# DAX User Defined Functions (UDFs)

Reusable parameterized DAX functions for Power BI semantic models.

## Requirements

- **Power BI Desktop:** September 2025 or later
- **Enable Feature:** File > Options > Preview Features > DAX user-defined functions

## Available UDF Files

| File | Category | Functions |
|------|----------|-----------|
| `UDF_Examples.dax` | All Categories | Tax, Discount, Margin, Fiscal Year, Tiered Pricing, RAG Status |

## Quick Start

### 1. Define a UDF

```dax
DEFINE
    FUNCTION AddTax(Amount AS CURRENCY, TaxRate AS DOUBLE) AS CURRENCY =
        Amount * (1 + TaxRate)
```

### 2. Use in a Measure

```dax
Sales with Tax = AddTax([Sales Amount], 0.10)
```

## Parameter Modes

| Mode | Behavior | Use When |
|------|----------|----------|
| `VAL` (default) | Evaluated once before function call | Simple value lookups |
| `EXPR` | Evaluated per row in function body | Row-by-row calculations |

## Data Types

`CURRENCY`, `DOUBLE`, `INTEGER`, `STRING`, `BOOLEAN`, `DATETIME`, `TABLE`, `VARIANT`

## Creating UDFs

1. **DAX Query View** - Write and test directly
2. **TMDL View** - Add to model expressions
3. **Tabular Editor** - External tool approach

## Resources

- [Microsoft Documentation](https://learn.microsoft.com/power-bi/transform-model/desktop-user-defined-functions)
- [SQLBI Introduction](https://www.sqlbi.com/articles/introducing-user-defined-functions-in-dax/)
- [daxlib.org](https://daxlib.org) - Community UDF library
