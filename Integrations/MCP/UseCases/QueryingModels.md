# Querying Semantic Models via MCP

> Use natural language to query Power BI semantic models through AI assistants

## Overview

The Power BI MCP Server allows AI assistants to execute DAX queries directly against your semantic models. This enables conversational data analysis without writing DAX manually.

## Basic Queries

### Example 1: Simple Aggregation
**Prompt:**
```
"What are the total sales for 2024?"
```

**AI generates and executes:**
```dax
EVALUATE
ROW(
    "Total Sales 2024",
    CALCULATE(
        [Total Sales],
        'Date'[Year] = 2024
    )
)
```

### Example 2: Grouped Data
**Prompt:**
```
"Show me sales by product category, sorted highest to lowest"
```

**Generated DAX:**
```dax
EVALUATE
TOPN(
    100,
    SUMMARIZECOLUMNS(
        'Product'[Category],
        "Total Sales", [Total Sales]
    ),
    [Total Sales], DESC
)
```

### Example 3: Time Comparison
**Prompt:**
```
"Compare this month's sales to last month"
```

**Generated DAX:**
```dax
EVALUATE
ROW(
    "Current Month", [Sales MTD],
    "Previous Month", CALCULATE([Sales MTD], DATEADD('Date'[Date], -1, MONTH)),
    "Change %", DIVIDE([Sales MTD] - CALCULATE([Sales MTD], DATEADD('Date'[Date], -1, MONTH)), 
                       CALCULATE([Sales MTD], DATEADD('Date'[Date], -1, MONTH)))
)
```

## Advanced Queries

### Example 4: Multi-Filter Analysis
**Prompt:**
```
"What were the top 10 products by profit margin in North America 
for customers with Gold membership status?"
```

**Generated DAX:**
```dax
EVALUATE
TOPN(
    10,
    CALCULATETABLE(
        ADDCOLUMNS(
            SUMMARIZE(
                Sales,
                'Product'[Product Name]
            ),
            "Profit Margin", [Profit Margin %]
        ),
        'Geography'[Region] = "North America",
        'Customer'[Membership] = "Gold"
    ),
    [Profit Margin], DESC
)
```

### Example 5: Period-over-Period with Ranking
**Prompt:**
```
"Show year-over-year growth by region and rank them"
```

**Generated DAX:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        Sales,
        'Geography'[Region]
    ),
    "Current Year", [Sales YTD],
    "Previous Year", CALCULATE([Sales YTD], SAMEPERIODLASTYEAR('Date'[Date])),
    "YoY Growth %", [YoY Growth %],
    "Rank", RANKX(
        ALL('Geography'[Region]),
        [YoY Growth %],
        ,
        DESC,
        DENSE
    )
)
ORDER BY [Rank]
```

### Example 6: Running Totals with Partitions
**Prompt:**
```
"Show cumulative sales by month within each product category"
```

**Generated DAX:**
```dax
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS(
        'Product'[Category],
        'Date'[Year Month],
        "Monthly Sales", [Total Sales]
    ),
    "Running Total",
    WINDOW(
        1, ABS,
        0, REL,
        SUMMARIZECOLUMNS(
            'Product'[Category],
            'Date'[Year Month],
            "Sales", [Total Sales]
        ),
        ORDERBY('Date'[Year Month]),
        KEEP,
        PARTITIONBY('Product'[Category])
    )
)
ORDER BY 'Product'[Category], 'Date'[Year Month]
```

## Schema Discovery Queries

### List Tables
**Prompt:**
```
"What tables are in this model?"
```

**AI uses INFO functions:**
```dax
EVALUATE INFO.TABLES()
```

### List Measures
**Prompt:**
```
"Show me all measures in the Sales table"
```

```dax
EVALUATE
FILTER(
    INFO.MEASURES(),
    [TableID] = "Sales"
)
```

### Show Relationships
**Prompt:**
```
"What are the relationships in this model?"
```

```dax
EVALUATE INFO.RELATIONSHIPS()
```

## Query Optimization Tips

### Use TOPN for Large Results
Instead of returning all rows, limit results:
```dax
-- Bad: Can return millions of rows
EVALUATE 'Sales'

-- Good: Limit to manageable size
EVALUATE TOPN(1000, 'Sales', 'Sales'[Date], DESC)
```

### Prefer Measures Over Calculated Columns
```dax
-- Efficient: Use existing measure
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    "Sales", [Total Sales]
)

-- Less efficient: Calculate inline
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    "Sales", SUM(Sales[Amount])
)
```

### Filter Early
```dax
-- Better: Filter in CALCULATETABLE
EVALUATE
CALCULATETABLE(
    SUMMARIZECOLUMNS(
        'Product'[Category],
        "Sales", [Total Sales]
    ),
    'Date'[Year] = 2024
)
```

## Prompt Engineering Tips

### Be Specific About Columns
```
Good: "Show sales by the 'Product Category' column"
Bad: "Show sales by category"
```

### Specify Time Periods
```
Good: "Sales for fiscal year 2024 (starts April)"
Bad: "Last year's sales"
```

### Indicate Sort Order
```
Good: "Top 10 customers by revenue, highest first"
Bad: "Show top customers"
```

### Request Format When Needed
```
"Show profit margin as a percentage with 2 decimal places"
```

## Error Handling

Common errors and how to address them:

| Error | Cause | Solution |
|-------|-------|----------|
| Column not found | Typo in column name | Ask AI to list available columns |
| Circular dependency | Measure references itself | Review measure logic |
| Query timeout | Too much data | Add filters or use TOPN |
| Function not supported | Older model compatibility | Use alternative function |

## Related Resources

- [Data Exploration Use Cases](./DataExploration.md)
- [DAX Query View Guide](../../../Documentation/UserGuides/DAXQueryView.md)
- [Window Functions Examples](../../../Queries/DAX/Measures/WindowFunctions.dax)
