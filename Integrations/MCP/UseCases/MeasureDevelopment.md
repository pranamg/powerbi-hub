# AI-Assisted Measure Development

> Create, validate, and optimize DAX measures with AI assistance via MCP

## Overview

The Power BI MCP Server enables AI to understand your model structure and help create measures that fit your specific context. This goes beyond generic DAX generation by using actual table and column names from your model.

## Measure Creation Workflows

### Workflow 1: Describe What You Need

**Prompt:**
```
"Create a measure that calculates the average order value, 
excluding returns and orders under $10"
```

**AI Process:**
1. Queries model for relevant tables (Orders, Returns)
2. Identifies Amount and OrderType columns
3. Generates context-aware DAX:

```dax
Average Order Value = 
VAR FilteredSales = 
    FILTER(
        'Orders',
        'Orders'[OrderType] <> "Return" &&
        'Orders'[Amount] >= 10
    )
RETURN
    AVERAGEX(FilteredSales, 'Orders'[Amount])
```

### Workflow 2: Start from Similar Measure

**Prompt:**
```
"Create a measure like [Total Sales] but for the previous year"
```

**AI Process:**
1. Retrieves [Total Sales] definition
2. Wraps with time intelligence:

```dax
Total Sales PY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('Date'[Date])
)
```

### Workflow 3: Convert SQL to DAX

**Prompt:**
```
"Convert this SQL to a DAX measure:
SELECT SUM(CASE WHEN status = 'Complete' THEN amount ELSE 0 END) / SUM(amount)
FROM orders"
```

**Generated DAX:**
```dax
Completion Rate = 
DIVIDE(
    CALCULATE(
        SUM('Orders'[Amount]),
        'Orders'[Status] = "Complete"
    ),
    SUM('Orders'[Amount])
)
```

## Validation Patterns

### Test Against Known Values

**Prompt:**
```
"Validate my [Profit Margin %] measure returns approximately 23% 
for product category 'Electronics' in 2024"
```

**AI executes:**
```dax
EVALUATE
ROW(
    "Calculated", 
    CALCULATE(
        [Profit Margin %],
        'Product'[Category] = "Electronics",
        'Date'[Year] = 2024
    ),
    "Expected", 0.23,
    "Within Tolerance", 
    ABS(CALCULATE([Profit Margin %], 'Product'[Category] = "Electronics", 'Date'[Year] = 2024) - 0.23) < 0.01
)
```

### Edge Case Testing

**Prompt:**
```
"Test my [YoY Growth %] measure for division by zero scenarios"
```

**AI generates test suite:**
```dax
-- Test 1: Normal scenario
EVALUATE
CALCULATETABLE(
    ROW("YoY Growth", [YoY Growth %]),
    'Date'[Year] = 2024,
    'Product'[Category] = "Electronics"
)

-- Test 2: Zero previous year (potential divide by zero)
EVALUATE
ROW(
    "Result",
    CALCULATE(
        [YoY Growth %],
        'Date'[Year] = 2020,  -- First year with data
        'Product'[Category] = "New Product"  -- No prior data
    )
)
```

### Compare Two Measure Versions

**Prompt:**
```
"Compare my old [Sales Growth] measure with the new optimized version 
across all regions"
```

```dax
EVALUATE
ADDCOLUMNS(
    VALUES('Geography'[Region]),
    "Old Measure", [Sales Growth],
    "New Measure", [Sales Growth v2],
    "Difference", [Sales Growth v2] - [Sales Growth],
    "Match", [Sales Growth] = [Sales Growth v2]
)
```

## Optimization Assistance

### Identify Performance Issues

**Prompt:**
```
"Analyze my [Complex Calculation] measure for performance issues"
```

**AI examines:**
1. Nested CALCULATE usage
2. Iterator function efficiency
3. Filter context complexity
4. Suggests improvements:

```dax
-- Original (slow)
Complex Calculation Old = 
SUMX(
    'Sales',
    CALCULATE(
        SUMX(
            FILTER('Product', 'Product'[ID] = 'Sales'[ProductID]),
            'Product'[Cost]
        )
    ) * 'Sales'[Quantity]
)

-- Optimized (fast)
Complex Calculation Optimized = 
VAR SalesWithCost = 
    ADDCOLUMNS(
        'Sales',
        "@Cost", RELATED('Product'[Cost])
    )
RETURN
    SUMX(SalesWithCost, [@Cost] * 'Sales'[Quantity])
```

### Simplify Complex Logic

**Prompt:**
```
"Simplify this measure while keeping the same result:
[measure definition]"
```

## Measure Documentation Generation

**Prompt:**
```
"Document the [Customer Lifetime Value] measure including:
- Business definition
- Technical implementation
- Dependencies
- Usage examples"
```

**AI generates:**
```markdown
## Customer Lifetime Value

### Business Definition
Calculates the total revenue a customer has generated since their first purchase,
used for customer segmentation and retention analysis.

### Technical Implementation
```dax
Customer Lifetime Value = 
VAR FirstPurchase = MIN('Sales'[OrderDate])
VAR CustomerID = SELECTEDVALUE('Customer'[CustomerID])
RETURN
CALCULATE(
    SUM('Sales'[Amount]),
    FILTER(
        ALL('Sales'),
        'Sales'[CustomerID] = CustomerID &&
        'Sales'[OrderDate] >= FirstPurchase
    )
)
```

### Dependencies
- Tables: Sales, Customer
- Columns: Sales[OrderDate], Sales[Amount], Sales[CustomerID], Customer[CustomerID]
- Other Measures: None

### Usage Examples
- Segment customers by CLV tiers (Low/Medium/High)
- Compare CLV across acquisition channels
- Track CLV trends over time
```

## Common Measure Patterns

### Request Pattern Library

**Prompt:**
```
"Create a time intelligence measure set for [Revenue] including:
YTD, QTD, MTD, YoY, and rolling 12 months"
```

**AI generates complete set:**
```dax
Revenue YTD = 
TOTALYTD([Revenue], 'Date'[Date])

Revenue QTD = 
TOTALQTD([Revenue], 'Date'[Date])

Revenue MTD = 
TOTALMTD([Revenue], 'Date'[Date])

Revenue YoY = 
[Revenue] - CALCULATE([Revenue], SAMEPERIODLASTYEAR('Date'[Date]))

Revenue YoY % = 
DIVIDE([Revenue YoY], CALCULATE([Revenue], SAMEPERIODLASTYEAR('Date'[Date])))

Revenue Rolling 12M = 
CALCULATE(
    [Revenue],
    DATESINPERIOD('Date'[Date], MAX('Date'[Date]), -12, MONTH)
)
```

## Best Practices

### 1. Provide Context
```
Good: "Create a margin measure for our retail model where 
      Cost is in the Product table and Revenue is in Sales"
Bad: "Create a margin measure"
```

### 2. Specify Edge Cases
```
"Create a growth measure that returns BLANK() instead of 
error when previous period is zero"
```

### 3. Request Validation
```
"Create the measure AND a test query to validate it"
```

### 4. Ask for Alternatives
```
"Show me two approaches to calculate customer retention rate - 
one using CALCULATE and one using window functions"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Measure returns wrong values | Ask AI to trace calculation with sample data |
| Circular dependency | Request AI to identify the cycle |
| Poor performance | Ask for optimization analysis |
| Complex filter context | Request step-by-step breakdown |

## Related Resources

- [UDF Examples](../../../Queries/DAX/UserDefinedFunctions/)
- [Time Intelligence Measures](../../../Queries/DAX/Measures/TimeIntelligence.dax)
- [DAX Tips & Tricks](../../../TipsAndTricks/DAX.md)
