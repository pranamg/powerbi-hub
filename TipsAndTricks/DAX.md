# DAX Tips & Tricks

Essential DAX patterns, common pitfalls, and optimization techniques.

## Golden Rules

1. **Always use DIVIDE()** instead of `/` to handle division by zero
2. **Use Variables (VAR)** to improve readability and performance
3. **Avoid FILTER() with ALL()** - use CALCULATE with filter arguments instead
4. **Never use CALCULATE inside iterators** without understanding context transition

## Variables - Best Practice

```dax
// BAD - Calculates [Sales Amount] twice
Gross Margin % = 
([Sales Amount] - [Cost Amount]) / [Sales Amount]

// GOOD - Calculate once, use twice
Gross Margin % = 
VAR TotalSales = [Sales Amount]
VAR TotalCost = [Cost Amount]
RETURN
DIVIDE(TotalSales - TotalCost, TotalSales)
```

## CALCULATE vs CALCULATETABLE

- **CALCULATE** - Returns a scalar value
- **CALCULATETABLE** - Returns a table
- Both modify filter context the same way

```dax
// Use CALCULATE for measures
Sales YTD = CALCULATE([Sales Amount], DATESYTD('Date'[Date]))

// Use CALCULATETABLE when you need a table
Top Products Table = 
CALCULATETABLE(
    TOPN(10, Products, [Sales Amount]),
    'Date'[Year] = 2024
)
```

## Filter Context Modifiers

| Function | Purpose |
|----------|---------|
| `ALL()` | Remove all filters |
| `ALLEXCEPT()` | Remove all filters except specified |
| `ALLSELECTED()` | Remove filters from visual, keep page/report filters |
| `REMOVEFILTERS()` | Same as ALL() but clearer intent |
| `KEEPFILTERS()` | Intersect with existing filter instead of replace |

## Common Pitfalls

### Pitfall 1: Blank vs Zero
```dax
// Returns BLANK if no sales (might cause visual issues)
Total Sales = SUM(Sales[Amount])

// Returns 0 if no sales (explicit)
Total Sales = SUM(Sales[Amount]) + 0

// Best: Handle explicitly
Total Sales = 
IF(ISBLANK(SUM(Sales[Amount])), 0, SUM(Sales[Amount]))
```

### Pitfall 2: Context Transition
```dax
// This WON'T filter correctly inside SUMX
Wrong = SUMX(Products, Sales[Amount])

// This WILL filter correctly (context transition)
Correct = SUMX(Products, [Sales Amount])  // Measure, not column
```

### Pitfall 3: DISTINCTCOUNT vs COUNTROWS
```dax
// DISTINCTCOUNT - counts unique values in a column
Unique Customers = DISTINCTCOUNT(Sales[CustomerID])

// COUNTROWS - counts rows in a table
// Often needs DISTINCT wrapper for unique counting
Unique Customers = COUNTROWS(DISTINCT(Sales[CustomerID]))
```

## Performance Tips

### 1. Move filters to CALCULATE arguments
```dax
// SLOWER
Sales High Value = 
CALCULATE(
    [Sales Amount],
    FILTER(ALL(Sales), Sales[Amount] > 1000)
)

// FASTER (if column is in model)
Sales High Value = 
CALCULATE(
    [Sales Amount],
    Sales[Amount] > 1000
)
```

### 2. Avoid nested iterators
```dax
// SLOW - O(n^2) complexity
Bad Pattern = 
SUMX(Products,
    SUMX(Customers, [Sales Amount])
)

// FASTER - Let the engine optimize
Better Pattern = 
SUMX(
    SUMMARIZE(Sales, Products[Product], Customers[Customer]),
    [Sales Amount]
)
```

### 3. Use SUMMARIZE carefully
```dax
// SUMMARIZE should only be used for grouping
// Use ADDCOLUMNS + SUMMARIZE for adding columns
Correct Pattern = 
ADDCOLUMNS(
    SUMMARIZE(Sales, Products[Category]),
    "Total", [Sales Amount]
)
```

## Useful Patterns

### Running Total
```dax
Running Total = 
CALCULATE(
    [Sales Amount],
    FILTER(
        ALL('Date'),
        'Date'[Date] <= MAX('Date'[Date])
    )
)
```

### Percentage of Parent
```dax
% of Category = 
DIVIDE(
    [Sales Amount],
    CALCULATE([Sales Amount], ALLEXCEPT(Products, Products[Category]))
)
```

### New vs Returning Customers
```dax
New Customers = 
VAR CurrentDate = MAX('Date'[Date])
RETURN
COUNTROWS(
    FILTER(
        Customers,
        CALCULATE(MIN(Sales[Date])) = CurrentDate
    )
)
```

### Dynamic Measure Selection
```dax
Selected Measure = 
SWITCH(
    SELECTEDVALUE('Measure Selector'[Measure]),
    "Sales", [Sales Amount],
    "Quantity", [Total Quantity],
    "Profit", [Profit Amount],
    [Sales Amount]  // Default
)
```

## Keyboard Shortcuts (DAX Editor)

| Shortcut | Action |
|----------|--------|
| `Ctrl + /` | Comment/Uncomment |
| `Ctrl + D` | Duplicate line |
| `Alt + Up/Down` | Move line |
| `Ctrl + Space` | IntelliSense |
| `Shift + Alt + F` | Format DAX |

## Window Functions (New in 2024)

DAX window functions provide SQL-like window operations for powerful row-level calculations.

### Core Functions

| Function | Purpose | SQL Equivalent |
|----------|---------|----------------|
| `INDEX` | Access specific row by position | `FIRST_VALUE` / `LAST_VALUE` |
| `OFFSET` | Access relative row (before/after) | `LAG` / `LEAD` |
| `WINDOW` | Define frame boundaries | Window frame clause |
| `RANK` | Rank with gaps for ties | `RANK()` |
| `ROWNUMBER` | Sequential number, no ties | `ROW_NUMBER()` |

### INDEX - Access by Position

```dax
// Get the first month's sales
First Month Sales = 
CALCULATE(
    [Sales Amount],
    INDEX(1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)

// Get the last (most recent) value
Latest Sales = 
CALCULATE(
    [Sales Amount],
    INDEX(-1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)
```

### OFFSET - Relative Row Access

```dax
// Previous month (equivalent to LAG)
Previous Month Sales = 
CALCULATE(
    [Sales Amount],
    OFFSET(-1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)

// Month-over-Month Change
MoM Change = 
VAR CurrentSales = [Sales Amount]
VAR PrevSales = CALCULATE(
    [Sales Amount],
    OFFSET(-1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)
RETURN
CurrentSales - PrevSales
```

### WINDOW - Define Frame Boundaries

```dax
// 3-Month Moving Average
Moving Avg 3M = 
AVERAGEX(
    WINDOW(-2, 0, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month])),
    [Sales Amount]
)

// Year-to-Date Running Total
YTD Running = 
SUMX(
    WINDOW(1, 0, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month])),
    [Sales Amount]
)
```

### RANK and ROWNUMBER

```dax
// Rank products by sales (with ties)
Product Rank = 
RANK(
    ALLSELECTED(Products[Product]),
    ORDERBY([Sales Amount], DESC)
)

// Row number (no ties, deterministic)
Product Row = 
ROWNUMBER(
    ALLSELECTED(Products[Product]),
    ORDERBY([Sales Amount], DESC, Products[Product], ASC)
)
```

### Window Function Pitfalls

**Pitfall 1: Missing ALLSELECTED**
```dax
// WRONG - No table context
Bad = OFFSET(-1, 'Date'[Month], ORDERBY('Date'[Month]))

// CORRECT - Use ALLSELECTED or ALL
Good = OFFSET(-1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
```

**Pitfall 2: Non-deterministic ROWNUMBER**
```dax
// BAD - Ties produce unpredictable results
Unstable = ROWNUMBER(Products, ORDERBY([Sales]))

// GOOD - Add unique column for stable ordering
Stable = ROWNUMBER(Products, ORDERBY([Sales], DESC, Products[ProductID], ASC))
```

**Pitfall 3: Mixing window functions with context**
```dax
// Window functions evaluate in the current filter context
// Be careful with CALCULATE modifiers
Correct Pattern = 
VAR WindowResult = 
    CALCULATE(
        [Sales Amount],
        OFFSET(-1, ALLSELECTED('Date'), ORDERBY('Date'[Date]))
    )
RETURN
[Sales Amount] - WindowResult
```

### Window Function Performance Tips

1. **Keep window tables small** - Filter before applying window functions
2. **Use MATCHBY for complex relationships** - When row identification is ambiguous
3. **Prefer OFFSET over WINDOW** for single-row access - OFFSET is optimized
4. **Cache repeated window calculations in variables**
5. **Add unique columns to ORDERBY** for deterministic results

### Window Functions vs Traditional DAX

| Task | Traditional DAX | Window Function |
|------|-----------------|-----------------|
| Previous Value | `CALCULATE + FILTER + EARLIER` | `OFFSET(-1, ...)` |
| Running Total | `CALCULATE + FILTER ALL` | `SUMX(WINDOW(1, 0, ...))` |
| Ranking | `RANKX(ALL(...), ...)` | `RANK(...)` |
| Moving Average | Complex DATESINPERIOD | `AVERAGEX(WINDOW(-2, 0, ...))` |

**Recommendation:** Window functions are cleaner and often faster for these scenarios. Use them when available (Power BI Dec 2023+).

---

## Resources

- [DAX.do](https://dax.do) - Online DAX playground
- [DAX Formatter](https://daxformatter.com) - Format your DAX
- [DAX Patterns](https://daxpatterns.com) - Common patterns
- [DAX Guide](https://dax.guide) - Function reference
- [SQLBI Window Functions Whitepaper](https://www.sqlbi.com/whitepapers/windows-functions-in-dax/) - Comprehensive guide
