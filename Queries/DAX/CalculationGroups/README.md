# Calculation Groups

> Reusable calculation logic that can be applied to any measure

## Overview

Calculation groups are a powerful feature that allow you to define a set of calculation items that can be applied dynamically to any measure in your model. This eliminates the need to create multiple versions of measures (YTD, PY, YoY, etc.) for every base measure.

## Available Calculation Groups

| File | Description |
|------|-------------|
| [TimeIntelligence.dax](./TimeIntelligence.dax) | Time-based calculations (YTD, QTD, MTD, PY, YoY) |
| [CurrencyConversion.dax](./CurrencyConversion.dax) | Multi-currency support |
| [Comparison.dax](./Comparison.dax) | Budget, Forecast, Target comparisons |

## Creating Calculation Groups

### Using Tabular Editor

1. Right-click Model → Create → Calculation Group
2. Name the calculation group (e.g., "Time Calculation")
3. Name the column (e.g., "Time Calc")
4. Add calculation items

### Using TMDL

```tmdl
calculationGroup 'Time Calculation'
    precedence: 1
    
    calculationItem Current = SELECTEDMEASURE()
        ordinal: 0
    
    calculationItem YTD = 
        CALCULATE(SELECTEDMEASURE(), DATESYTD('Date'[Date]))
        ordinal: 1

    column 'Time Calc'
        dataType: string
        isDefaultLabel: true
```

## How They Work

### Before: Multiple Measures

```dax
Sales = SUM(Sales[Amount])
Sales YTD = TOTALYTD([Sales], 'Date'[Date])
Sales PY = CALCULATE([Sales], SAMEPERIODLASTYEAR('Date'[Date]))
Sales YoY = [Sales] - [Sales PY]

Profit = SUM(Sales[Profit])
Profit YTD = TOTALYTD([Profit], 'Date'[Date])
Profit PY = CALCULATE([Profit], SAMEPERIODLASTYEAR('Date'[Date]))
Profit YoY = [Profit] - [Profit PY]

-- 8 measures for just 2 metrics!
```

### After: With Calculation Group

```dax
Sales = SUM(Sales[Amount])
Profit = SUM(Sales[Profit])

-- Time Calculation group handles YTD, PY, YoY for ALL measures
-- Just 2 measures + 1 calculation group
```

## Usage in Reports

1. Add your base measure to a visual
2. Add the calculation group column (e.g., "Time Calc") to visual or slicer
3. Select the calculation item (e.g., "YTD")
4. The calculation is applied to the measure

### Visual Example

| Product | Sales (with Time Calc = "YoY %") |
|---------|----------------------------------|
| Bikes | 12.5% |
| Clothing | -3.2% |
| Accessories | 8.7% |

## Precedence

When multiple calculation groups are applied:

```
Higher precedence = Outer calculation
Lower precedence = Inner calculation
```

Example:
- Currency Conversion (precedence: 2) - Applied outer
- Time Calculation (precedence: 1) - Applied inner

Result: `CurrencyConversion(TimeCalculation(Measure))`

## Format Strings

Apply dynamic format strings to calculation items:

```tmdl
calculationItem 'YoY %' = 
    DIVIDE(CurrentValue - PriorYear, PriorYear)
    formatString: "0.00%"
```

Common formats:
| Format | Example |
|--------|---------|
| `#,##0` | 1,234 |
| `#,##0.00` | 1,234.56 |
| `0.00%` | 12.34% |
| `$#,##0` | $1,234 |

## Best Practices

### Do's
- Use for repetitive calculations across many measures
- Set appropriate precedence for multiple groups
- Include a "Current" item for unmodified values
- Document each calculation item

### Don'ts
- Don't create calculation groups for single measures
- Don't overcomplicate with too many items
- Don't forget to handle BLANK values
- Don't mix unrelated calculations in one group

## Limitations

- Requires Power BI Desktop (October 2020+)
- Cannot be created in Power BI Desktop UI (need Tabular Editor or TMDL)
- Some visualizations may not fully support calculation groups
- Cannot be used with implicit measures

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Calculation not applied | Check visual has calculation group column |
| Wrong precedence | Adjust precedence in Tabular Editor |
| Format string not working | Ensure format is set on calculation item |
| Performance issues | Simplify calculation item expressions |

## Related Resources

- [Time Intelligence Measures](../Measures/TimeIntelligence.dax)
- [TMDL Templates](../../../Scripts/TMDL/)
- [Microsoft Documentation](https://learn.microsoft.com/power-bi/transform-model/calculation-groups)
