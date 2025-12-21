# Power BI Naming Conventions

> Standardized naming guidelines for Power BI artifacts

## Overview

Consistent naming improves discoverability, maintainability, and collaboration. Apply these conventions across all Power BI development.

## Workspace Naming

### Pattern
```
{BusinessArea} - {Purpose} [{Environment}]
```

### Examples
| Workspace Name | Description |
|---------------|-------------|
| Sales Analytics - Reports | Production reports for sales |
| Sales Analytics - DEV | Development workspace |
| Finance - Executive Dashboard | Finance leadership reports |
| HR - Headcount Tracking - TEST | Testing workspace |

### Rules
- Use title case with spaces
- Include environment suffix for non-production
- Keep names under 50 characters
- Avoid special characters except hyphen and spaces

## Semantic Model Naming

### Tables

| Type | Pattern | Example |
|------|---------|---------|
| Fact Tables | Fact_{Name} or just {Name} | FactSales, Sales |
| Dimension Tables | Dim_{Name} or just {Name} | DimProduct, Product |
| Bridge Tables | Bridge_{Name} | Bridge_ProductCategory |
| Date Table | Date or Calendar | Date |
| Calculation Tables | Calc_{Name} | Calc_DateParameters |

### Columns

| Type | Pattern | Example |
|------|---------|---------|
| Keys (Primary) | {TableName}ID or {TableName}Key | ProductID, ProductKey |
| Keys (Foreign) | {RelatedTable}ID | CustomerID (in Sales) |
| Dates | {Description}Date | OrderDate, ShipDate |
| Amounts | {Metric}Amount | SalesAmount, CostAmount |
| Flags | Is{Description} | IsActive, IsCurrentYear |
| Counts | {Item}Count | OrderCount, ItemCount |
| Descriptions | {Entity}Name or {Entity}Description | ProductName, CategoryDescription |

### Measures

| Category | Prefix/Pattern | Example |
|----------|---------------|---------|
| Base Metrics | {Metric} | Total Sales, Order Count |
| Time Intelligence | {Metric} {Period} | Sales YTD, Revenue QTD |
| Comparisons | {Metric} {Comparison} | Sales PY, Revenue vs Budget |
| Percentages | {Metric} % | Margin %, Growth % |
| Ratios | {Metric} Ratio | Conversion Ratio |
| Rankings | {Entity} Rank | Product Rank, Customer Rank |
| Internal/Helper | _{Metric} | _BaseSales, _TempCalc |

### Display Folders

Standard folder structure:
```
📁 Base Metrics
📁 Time Intelligence
   └── YTD
   └── Prior Period
   └── Growth
📁 Ratios & Percentages
📁 Rankings
📁 KPIs
📁 _Technical (hidden)
```

## Report Naming

### Reports
```
{Subject} - {Type} [{Version}]
```

| Example | Description |
|---------|-------------|
| Sales Performance - Dashboard | Main sales dashboard |
| Inventory - Detail Report | Detailed inventory analysis |
| Finance - Monthly Review - v2 | Versioned report |

### Pages
- Use descriptive names (not "Page 1")
- Start with navigation/summary pages
- Group related pages together

| Page Name | Purpose |
|-----------|---------|
| Executive Summary | High-level KPIs |
| Sales Overview | Sales metrics and trends |
| Regional Analysis | Geographic breakdown |
| Product Deep Dive | Product-level analysis |

## Parameters & Variables

### Parameters
```
{Scope}_{Description}
```

| Parameter | Purpose |
|-----------|---------|
| Connection_ServerName | Data source server |
| Connection_DatabaseName | Database name |
| Filter_StartDate | Report start date |
| Filter_TopN | Number of items to show |

### DAX Variables
```
VAR __{DescriptiveName}
```

| Variable | Example |
|----------|---------|
| `__CurrentSales` | Current period sales |
| `__PriorYearSales` | Same period last year |
| `__FilteredTable` | Filtered table reference |

## File Naming

### PBIX Files
```
{Subject}_{Type}_{YYYYMMDD}.pbix
```

| File | Purpose |
|------|---------|
| SalesAnalytics_Dashboard_20241221.pbix | Dated version |
| FinanceReporting_Model_PROD.pbix | Production model |

### TMDL Folders
```
{ModelName}.Dataset/
├── model.tmdl
├── tables/
│   ├── Sales.tmdl
│   └── Product.tmdl
└── measures/
```

## Git Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | feature/{ticket}-{description} | feature/JIRA123-add-ytd-measures |
| Bugfix | bugfix/{ticket}-{description} | bugfix/JIRA456-fix-margin-calc |
| Release | release/{version} | release/2024.12 |

## Abbreviations

### Approved Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| YTD | Year to Date |
| QTD | Quarter to Date |
| MTD | Month to Date |
| PY | Prior Year |
| PM | Prior Month |
| YoY | Year over Year |
| MoM | Month over Month |
| Avg | Average |
| Qty | Quantity |
| Amt | Amount |
| Pct | Percentage |
| Num | Number |
| Desc | Description |

### Avoid
- Single letters (except loop counters in DAX)
- Organization-specific jargon without documentation
- Inconsistent abbreviations (pick one and stick with it)

## Checklist

Before deploying, verify:

- [ ] Workspace name follows convention
- [ ] All tables have clear, consistent names
- [ ] Measures are in display folders
- [ ] Helper measures are hidden (prefixed with _)
- [ ] Key columns are hidden
- [ ] Column names use spaces (not underscores)
- [ ] Report pages have descriptive names
- [ ] Parameters follow naming pattern
- [ ] No hardcoded values without documentation

## Related Resources

- [Development Standards](./DevelopmentStandards.md)
- [BPA Rules](../Scripts/CSharp/TabularEditor/BestPracticeRules.json)
