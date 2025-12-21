# Power Query Tips & Tricks

Essential M language patterns, performance tips, and common solutions.

## Query Folding - Critical for Performance

Query folding pushes transformations to the data source. Check if folding is active:
- Right-click any step > "View Native Query"
- If grayed out, folding has broken

### Steps that BREAK query folding:
- Adding custom columns with M functions
- Merging queries (in some cases)
- Sorting after certain operations
- Using `Table.Buffer()`
- Pivoting/Unpivoting (sometimes)
- Grouping with custom aggregations

### Keep folding alive:
```m
// Do filtering FIRST (folds to WHERE clause)
= Table.SelectRows(Source, each [Status] = "Active")

// Then do operations that break folding LAST
= Table.AddColumn(Filtered, "Custom", each [A] + [B])
```

## Common Transformations

### Remove Duplicates (Keep First)
```m
= Table.Distinct(Source, {"KeyColumn"})
```

### Remove Duplicates (Keep Last)
```m
= Table.Distinct(Table.ReverseRows(Source), {"KeyColumn"})
```

### Conditional Column
```m
= Table.AddColumn(Source, "Category", each 
    if [Amount] >= 1000 then "High"
    else if [Amount] >= 500 then "Medium"
    else "Low"
)
```

### Unpivot All Except Key Columns
```m
= Table.UnpivotOtherColumns(
    Source, 
    {"ID", "Name"},  // Columns to keep
    "Attribute", 
    "Value"
)
```

## Working with Dates

### Create Date from Components
```m
= #date([Year], [Month], [Day])
```

### Get Last Day of Month
```m
= Date.EndOfMonth([DateColumn])
```

### Add Fiscal Year Column
```m
// Fiscal year starts July
= Table.AddColumn(Source, "FiscalYear", each 
    if Date.Month([Date]) >= 7 
    then Date.Year([Date]) + 1 
    else Date.Year([Date])
)
```

## Error Handling

### Replace Errors with Null
```m
= Table.ReplaceErrorValues(Source, {
    {"Column1", null},
    {"Column2", 0}
})
```

### Try-Otherwise Pattern
```m
= Table.AddColumn(Source, "SafeResult", each 
    try [Column] / [Divisor] otherwise null
)
```

## Performance Optimizations

### 1. Buffer Tables Used Multiple Times
```m
BufferedTable = Table.Buffer(Source)
```

### 2. Select Columns Early
```m
= Table.SelectColumns(Source, {"ID", "Name", "Amount"})
```

### 3. Filter Early
```m
= Table.SelectRows(Source, each [Year] >= 2020)
```

## Combining Data

### Merge (Join) Patterns
```m
// Left Join
= Table.NestedJoin(Table1, "Key", Table2, "Key", "Joined", JoinKind.LeftOuter)

// Inner Join
= Table.NestedJoin(Table1, "Key", Table2, "Key", "Joined", JoinKind.Inner)
```

### Expand Joined Table
```m
= Table.ExpandTableColumn(JoinedTable, "Joined", {"Column1", "Column2"})
```

## Text Operations

### Clean Whitespace
```m
= Table.TransformColumns(Source, {{"Text", each Text.Trim(Text.Clean(_))}})
```

### Extract Between Delimiters
```m
= Text.BetweenDelimiters([Column], "(", ")")
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + Enter` | Load & Close |
| `F5` | Refresh Preview |
| `Ctrl + Z` | Undo Step |

## Best Practices Checklist

- [ ] Check query folding on each step
- [ ] Remove unused columns early
- [ ] Filter data at the source
- [ ] Use proper data types
- [ ] Handle errors gracefully
- [ ] Name steps descriptively
