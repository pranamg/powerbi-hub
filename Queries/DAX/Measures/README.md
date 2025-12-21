# DAX Measures Library

Reusable DAX measure templates organized by category.

## Available Measure Files

| File | Category | Contents |
|------|----------|----------|
| `TimeIntelligence.dax` | Time Analysis | YTD, QTD, MTD, PY, YoY, Rolling periods, Moving averages |
| `Rankings.dax` | Ranking & Analysis | RANKX, Top N, Pareto, ABC classification, Percentiles |
| `ConditionalFormatting.dax` | Visual Formatting | RAG status, color codes, icons, data bars, heat maps |
| `WindowFunctions.dax` | Window Calculations | INDEX, OFFSET, WINDOW, RANK, ROWNUMBER, running totals, lead/lag |

## Window Functions (New in 2024)

The `WindowFunctions.dax` file contains examples of the new DAX window functions introduced in 2024:

### Core Functions
- **INDEX** - Access a row by position in a table
- **OFFSET** - Access a row relative to current row
- **WINDOW** - Define a window frame for calculations
- **RANK** - Rank rows within a partition
- **ROWNUMBER** - Assign sequential numbers to rows

### Common Patterns Included
- Moving averages (3-month, 12-month)
- Running totals with partitions
- Year-over-year using OFFSET
- Lead/Lag calculations
- Previous/Next row access
- Percentile rankings

### Key Syntax Pattern
```dax
INDEX(
    <position>,
    <relation>,
    <orderBy>,
    <partitionBy>,    -- Optional
    <matchBy>         -- Optional
)
```

See `WindowFunctions.dax` for complete examples with detailed comments.

## Usage Instructions

1. Open the relevant `.dax` file
2. Find the measure pattern you need
3. Copy and modify for your data model:
   - Replace `[Sales Amount]` with your measure
   - Replace `'Date'` with your date table name
   - Replace `'Product'` with your dimension table

## Naming Convention

Measures follow this pattern:
```
[Base Measure] [Time Intelligence] [Comparison]

Examples:
- Sales YTD
- Sales PY (Prior Year)
- Sales YoY % (Year over Year Percentage)
- Sales Rolling 12M
```

## Prerequisites

Most Time Intelligence measures require:
- A properly configured Date table
- The Date table marked as a Date table in the model
- Active relationships between Date and fact tables
