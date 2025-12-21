# Dataflow Gen2 Patterns

> **Purpose:** Templates and patterns for Power Query transformations in Dataflow Gen2

---

## Overview

Dataflow Gen2 is the next generation of Power BI Dataflows, running on Fabric infrastructure with improved performance and integration with Lakehouse/Warehouse.

### Key Differences from Gen1

| Feature | Dataflow Gen1 | Dataflow Gen2 |
|---------|---------------|---------------|
| Compute | Shared | Dedicated (Fabric) |
| Output | CDM/Dataverse | Lakehouse/Warehouse/CDM |
| Staging | Azure Data Lake | OneLake |
| Refresh | Sequential | Parallel |
| Scale | Limited | High |

---

## Common Patterns

### Pattern 1: Source to Lakehouse

```
External Source → Dataflow Gen2 → Lakehouse Table → Direct Lake Model
```

**M Code Template:**
```powerquery
let
    // Connect to source
    Source = Sql.Database("server.database.windows.net", "SourceDB"),
    Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    
    // Apply transformations
    FilteredRows = Table.SelectRows(Sales, each [Status] = "Completed"),
    TypedColumns = Table.TransformColumnTypes(FilteredRows, {
        {"SalesDate", type date},
        {"Amount", type number},
        {"Quantity", Int64.Type}
    }),
    
    // Add calculated columns
    WithCalculations = Table.AddColumn(TypedColumns, "Revenue", 
        each [Amount] * [Quantity], type number)
in
    WithCalculations
```

### Pattern 2: Incremental Refresh

```powerquery
let
    // Parameters for incremental refresh
    StartDate = #date(2023, 1, 1),
    EndDate = DateTime.Date(DateTime.LocalNow()),
    
    // Source with date filter
    Source = Sql.Database("server", "db", [
        Query = "SELECT * FROM Sales WHERE ModifiedDate >= '" & 
                Date.ToText(StartDate, "yyyy-MM-dd") & "' AND ModifiedDate < '" &
                Date.ToText(EndDate, "yyyy-MM-dd") & "'"
    ]),
    
    Result = Source
in
    Result
```

### Pattern 3: Multiple Output Tables

```
                    ┌──► DimProduct (Lakehouse)
Dataflow Gen2 ──────┼──► DimCustomer (Lakehouse)
                    └──► FactSales (Lakehouse)
```

**Implementation:**
Create multiple queries in same dataflow, each outputting to different table.

---

## Transformation Templates

### Clean Text Data

```powerquery
let
    Source = YourSourceTable,
    
    // Standardize text
    CleanedNames = Table.TransformColumns(Source, {
        {"CustomerName", each Text.Proper(Text.Trim(_)), type text},
        {"Email", each Text.Lower(Text.Trim(_)), type text},
        {"Phone", each Text.Remove(_, {"-", "(", ")", " "}), type text}
    }),
    
    // Remove duplicates
    UniqueRecords = Table.Distinct(CleanedNames, {"CustomerId"})
in
    UniqueRecords
```

### Date Table Generation

```powerquery
let
    StartDate = #date(2020, 1, 1),
    EndDate = #date(2025, 12, 31),
    
    // Generate date list
    DateList = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    
    // Convert to table
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    
    // Change type
    TypedDate = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),
    
    // Add columns
    WithColumns = Table.AddColumn(TypedDate, "DateKey", each Number.From(Date.ToText([Date], "yyyyMMdd")), Int64.Type),
    AddYear = Table.AddColumn(WithColumns, "Year", each Date.Year([Date]), Int64.Type),
    AddQuarter = Table.AddColumn(AddYear, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddQuarter, "Month", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonth, "MonthName", each Date.MonthName([Date]), type text),
    AddDay = Table.AddColumn(AddMonthName, "Day", each Date.Day([Date]), Int64.Type),
    AddDayName = Table.AddColumn(AddDay, "DayName", each Date.DayOfWeekName([Date]), type text),
    AddWeek = Table.AddColumn(AddDayName, "WeekOfYear", each Date.WeekOfYear([Date]), Int64.Type),
    AddYearMonth = Table.AddColumn(AddWeek, "YearMonth", each Date.ToText([Date], "yyyy-MM"), type text)
in
    AddYearMonth
```

### Unpivot Columns

```powerquery
let
    Source = YourSourceTable,
    // Columns: Product, Jan, Feb, Mar, Apr, ...
    
    // Select columns to unpivot
    UnpivotedColumns = Table.UnpivotOtherColumns(Source, {"Product"}, "Month", "Sales"),
    
    // Convert month names to dates
    AddDate = Table.AddColumn(UnpivotedColumns, "SalesDate", 
        each Date.FromText([Month] & " 1, 2024"), type date)
in
    AddDate
```

### Merge Tables (Lookup)

```powerquery
let
    FactTable = YourFactTable,
    DimTable = YourDimTable,
    
    // Left join
    MergedTables = Table.NestedJoin(
        FactTable, {"ProductId"},
        DimTable, {"ProductId"},
        "DimProduct", JoinKind.LeftOuter
    ),
    
    // Expand columns needed
    ExpandedColumns = Table.ExpandTableColumn(MergedTables, "DimProduct", 
        {"ProductName", "Category"}, {"ProductName", "Category"})
in
    ExpandedColumns
```

### Handle Errors

```powerquery
let
    Source = YourSourceTable,
    
    // Replace errors with null
    CleanedTable = Table.ReplaceErrorValues(Source, {
        {"Amount", null},
        {"Quantity", 0}
    }),
    
    // Or remove error rows
    // NoErrors = Table.RemoveRowsWithErrors(Source)
in
    CleanedTable
```

---

## Performance Optimization

### Enable Staging

Always enable staging for better performance:
1. Right-click query
2. Enable "Enable staging"
3. Data loads to OneLake first, then transforms

### Query Folding

Ensure transformations fold to source:
```powerquery
let
    // Foldable - pushed to SQL
    Source = Sql.Database("server", "db"),
    Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    Filtered = Table.SelectRows(Sales, each [Year] >= 2023),
    Sorted = Table.Sort(Filtered, {{"SalesDate", Order.Descending}}),
    TopRows = Table.FirstN(Sorted, 1000)
in
    TopRows
```

### Partition Large Tables

```powerquery
// Create separate queries for each partition
let
    // Query 1: 2023 data
    Source = Sql.Database("server", "db", [
        Query = "SELECT * FROM Sales WHERE YEAR(SalesDate) = 2023"
    ])
in
    Source

// Query 2: 2024 data
let
    Source = Sql.Database("server", "db", [
        Query = "SELECT * FROM Sales WHERE YEAR(SalesDate) = 2024"
    ])
in
    Source
```

---

## Output Configuration

### To Lakehouse Table

1. Select query
2. Click "+ Add data destination"
3. Choose Lakehouse
4. Select workspace and Lakehouse
5. Choose table name
6. Configure update method (Replace/Append)

### To Warehouse Table

1. Same process as Lakehouse
2. Select Data Warehouse instead
3. Choose schema and table

### Update Methods

| Method | Behavior | Use Case |
|--------|----------|----------|
| Replace | Drop and recreate | Full refresh |
| Append | Add new rows | Incremental |

---

## Best Practices

1. **Enable staging** for all queries
2. **Check query folding** for source queries
3. **Use parameters** for environment-specific values
4. **Split large dataflows** into logical units
5. **Document queries** with descriptions
6. **Test incrementally** before full refresh

---

## Related Documents

- [Lakehouse Patterns](./Lakehouse.md)
- [Direct Lake Setup](./DirectLake.md)
- [Power Query Functions](../../Queries/PowerQuery/CustomFunctions/README.md)

---

*Last Updated: December 2024*
