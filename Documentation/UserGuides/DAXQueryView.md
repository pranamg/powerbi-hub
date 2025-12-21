# DAX Query View User Guide

> **DAX Query View** is a built-in query editor in Power BI Desktop for writing, testing, and debugging DAX queries directly against your semantic model.

## Overview

DAX Query View provides a dedicated space to:

- Write and execute DAX queries using EVALUATE
- Test measure logic before adding to the model
- Debug complex calculations
- Create and manage User Defined Functions (UDFs)
- Analyze query performance
- Export query results

## Accessing DAX Query View

### Method 1: From the View Menu
1. Open your .pbix file in Power BI Desktop
2. Click **View** in the ribbon
3. Select **DAX query** (or **DAX Query View**)

### Method 2: Keyboard Shortcut
- Press `Ctrl+Alt+D` to toggle DAX Query View

### Method 3: From the Left Navigation
- Click the **DAX Query View** icon in the left sidebar
- Icon looks like a document with code

## Interface Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ Query Tab 1 │ Query Tab 2 │ + New Query                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  DEFINE                                                         │
│      MEASURE Sales[Test Measure] = SUM(Sales[Amount])           │
│                                                                  │
│  EVALUATE                                                       │
│  SUMMARIZECOLUMNS(                                              │
│      'Date'[Year],                                              │
│      "Total", [Test Measure]                                    │
│  )                                                              │
│                                                                  │
│  ▶ Run  │  📊 Results  │  ⏱️ Performance                        │
├─────────────────────────────────────────────────────────────────┤
│ Results Grid                                                    │
│ ┌──────────┬───────────────┐                                   │
│ │ Year     │ Total         │                                   │
│ ├──────────┼───────────────┤                                   │
│ │ 2023     │ $1,234,567    │                                   │
│ │ 2024     │ $2,345,678    │                                   │
│ └──────────┴───────────────┘                                   │
└─────────────────────────────────────────────────────────────────┘
```

## DAX Query Basics

### EVALUATE Statement

The core of DAX queries - returns a table result:

```dax
EVALUATE
'Sales'
```

This returns all rows from the Sales table.

### Filtering Results

```dax
EVALUATE
FILTER(
    'Sales',
    'Sales'[Amount] > 1000
)
```

### Using SUMMARIZECOLUMNS

Most common pattern for aggregated results:

```dax
EVALUATE
SUMMARIZECOLUMNS(
    'Products'[Category],
    'Date'[Year],
    "Total Sales", SUM('Sales'[Amount]),
    "Order Count", COUNTROWS('Sales')
)
```

### ORDER BY

Sort query results:

```dax
EVALUATE
SUMMARIZECOLUMNS(
    'Products'[Category],
    "Sales", [Total Sales]
)
ORDER BY [Sales] DESC
```

### TOP N Results

Limit returned rows:

```dax
EVALUATE
TOPN(
    10,
    SUMMARIZECOLUMNS(
        'Products'[Product],
        "Sales", [Total Sales]
    ),
    [Sales], DESC
)
```

## DEFINE Statement

Use DEFINE to create temporary measures, tables, columns, or variables for testing.

### Testing a Measure Before Adding to Model

```dax
DEFINE
    MEASURE Sales[Sales YTD Test] = 
        CALCULATE(
            [Total Sales],
            DATESYTD('Date'[Date])
        )

EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    'Date'[Month],
    "YTD Sales", [Sales YTD Test]
)
```

### Defining Multiple Measures

```dax
DEFINE
    MEASURE Sales[Current Sales] = SUM('Sales'[Amount])
    
    MEASURE Sales[Previous Month] = 
        CALCULATE(
            [Current Sales],
            PREVIOUSMONTH('Date'[Date])
        )
    
    MEASURE Sales[MoM Growth] = 
        [Current Sales] - [Previous Month]

EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year-Month],
    "Current", [Current Sales],
    "Previous", [Previous Month],
    "Growth", [MoM Growth]
)
ORDER BY 'Date'[Year-Month]
```

### Defining Calculated Tables

```dax
DEFINE
    TABLE TopProducts = 
        TOPN(
            10,
            SUMMARIZE(
                Sales,
                Products[Product],
                "Revenue", SUM(Sales[Amount])
            ),
            [Revenue], DESC
        )

EVALUATE TopProducts
```

## User Defined Functions (UDFs)

DAX Query View is the primary way to create and test UDFs (available from September 2024).

### Creating a UDF

```dax
DEFINE
    // Value parameter (VAL) - evaluates once
    FUNCTION CalculateMargin(VAL Revenue, VAL Cost)
        RETURN DIVIDE(Revenue - Cost, Revenue)
    
    // Expression parameter (EXPR) - evaluates in each row context
    FUNCTION GetCategoryTotal(EXPR Category)
        RETURN 
            CALCULATE(
                SUM(Sales[Amount]),
                Products[Category] = Category
            )

EVALUATE
ADDCOLUMNS(
    Products,
    "Margin", CalculateMargin(Products[Price], Products[Cost]),
    "Category Total", GetCategoryTotal(Products[Category])
)
```

### VAL vs EXPR Parameters

| Parameter Type | Behavior | Use Case |
|---------------|----------|----------|
| `VAL` | Evaluated once before function | Fixed values, aggregated results |
| `EXPR` | Evaluated in row context | Per-row calculations |

### Adding UDFs to the Model

After testing in DAX Query View:
1. Validate the function works correctly
2. Use TMDL View or Tabular Editor to add permanently
3. Reference in measures: `[My UDF](parameter)`

## Performance Analysis

### View Query Performance

1. Run your query
2. Click the **Performance** tab (or clock icon)
3. Review:
   - Total execution time
   - Storage Engine queries
   - Formula Engine time

### Using INFO Functions

```dax
// View table sizes
EVALUATE
INFO.TABLES()

// View column cardinality
EVALUATE
INFO.COLUMNS()

// View relationships
EVALUATE
INFO.RELATIONSHIPS()
```

### Query with Performance Metrics

```dax
DEFINE
    VAR QueryStart = NOW()

EVALUATE
ROW(
    "Query Duration", DATEDIFF(QueryStart, NOW(), MILLISECOND)
)
```

## Common Patterns

### Testing Time Intelligence

```dax
DEFINE
    MEASURE Sales[YTD] = CALCULATE([Total Sales], DATESYTD('Date'[Date]))
    MEASURE Sales[QTD] = CALCULATE([Total Sales], DATESQTD('Date'[Date]))
    MEASURE Sales[MTD] = CALCULATE([Total Sales], DATESMTD('Date'[Date]))

EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Date],
    "Sales", [Total Sales],
    "YTD", [YTD],
    "QTD", [QTD],
    "MTD", [MTD]
)
ORDER BY 'Date'[Date]
```

### Comparing Measure Results

```dax
EVALUATE
ADDCOLUMNS(
    VALUES('Products'[Category]),
    "Using SUM", CALCULATE(SUM(Sales[Amount])),
    "Using Measure", [Total Sales],
    "Difference", CALCULATE(SUM(Sales[Amount])) - [Total Sales]
)
```

### Debugging Filter Context

```dax
EVALUATE
CALCULATETABLE(
    ADDCOLUMNS(
        VALUES('Products'[Product]),
        "Sales", [Total Sales],
        "Filter Active", NOT(ISEMPTY(FILTERS('Date'[Year])))
    ),
    'Date'[Year] = 2024
)
```

### Testing Window Functions

```dax
DEFINE
    MEASURE Sales[Prev Month] = 
        CALCULATE(
            [Total Sales],
            OFFSET(-1, ALLSELECTED('Date'[Year-Month]), ORDERBY('Date'[Year-Month]))
        )

EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year-Month],
    "Current", [Total Sales],
    "Previous", [Prev Month],
    "Change", [Total Sales] - [Prev Month]
)
ORDER BY 'Date'[Year-Month]
```

## Multiple Queries

DAX Query View supports multiple EVALUATE statements:

```dax
// Query 1: Summary by Year
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    "Total", [Total Sales]
)

// Query 2: Top Products
EVALUATE
TOPN(5, 
    SUMMARIZECOLUMNS(Products[Product], "Sales", [Total Sales]),
    [Sales], DESC
)

// Query 3: Customer Count
EVALUATE
ROW("Total Customers", DISTINCTCOUNT(Sales[CustomerID]))
```

Each EVALUATE produces a separate result tab.

## Exporting Results

### Copy to Clipboard
1. Run query
2. Select results (or `Ctrl+A` for all)
3. `Ctrl+C` to copy
4. Paste into Excel or other applications

### Export to CSV (via Copy)
1. Copy results
2. Paste into text editor
3. Save as .csv

## Best Practices

### 1. Test Before Adding to Model
Always validate measure logic in DAX Query View before adding permanently.

### 2. Use Variables for Debugging
```dax
DEFINE
    MEASURE Sales[Debug] = 
        VAR Step1 = SUM(Sales[Amount])
        VAR Step2 = CALCULATE(Step1, ALL('Date'))
        VAR Step3 = DIVIDE(Step1, Step2)
        RETURN Step3  -- Change to Step1/Step2 to debug

EVALUATE ROW("Result", [Debug])
```

### 3. Start Simple, Add Complexity
```dax
-- Step 1: Basic query
EVALUATE SUMMARIZE(Sales, 'Date'[Year])

-- Step 2: Add measure
EVALUATE 
SUMMARIZECOLUMNS(
    'Date'[Year],
    "Sales", [Total Sales]
)

-- Step 3: Add filters
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    FILTER(Products, Products[Category] = "Electronics"),
    "Sales", [Total Sales]
)
```

### 4. Comment Your Queries
```dax
// Purpose: Test YoY calculation for fiscal year
// Author: Data Team
// Date: 2024-12-21

DEFINE
    MEASURE Sales[Test YoY] = ...
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+D` | Open DAX Query View |
| `F5` | Run query |
| `Ctrl+Enter` | Run query |
| `Ctrl+Space` | IntelliSense |
| `Ctrl+/` | Comment line |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Ctrl+S` | Save query |

## Troubleshooting

### Query Returns Error
- Check for missing table/column references
- Verify measure names are correct
- Ensure proper use of CALCULATE context

### Slow Query Performance
- Use SUMMARIZECOLUMNS instead of SUMMARIZE + ADDCOLUMNS
- Avoid unnecessary columns in output
- Filter early in the query
- Check for expensive iterators

### IntelliSense Not Working
- Wait for model to fully load
- Press `Ctrl+Space` to trigger
- Restart Power BI Desktop if persistent

## Resources

- [DAX Query View Documentation](https://learn.microsoft.com/power-bi/transform-model/desktop-dax-query-view)
- [EVALUATE Documentation](https://dax.guide/evaluate/)
- [DEFINE Documentation](https://dax.guide/define/)
- [DAX.do - Online Query Playground](https://dax.do)

---

*Last Updated: December 2024*
