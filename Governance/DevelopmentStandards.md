# Power BI Development Standards

> Guidelines and best practices for Power BI development

## Overview

These standards ensure consistency, quality, and maintainability across all Power BI projects.

## Data Model Standards

### Star Schema

**Always** design semantic models using star schema:

```
       ┌─────────────┐
       │   DimDate   │
       └──────┬──────┘
              │
┌─────────────┼─────────────┐
│             │             │
▼             ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│DimProduct│ │FactSales│ │DimCustomer│
└─────────┘ └─────────┘ └─────────┘
```

**Rules:**
- Fact tables contain foreign keys and measures
- Dimension tables contain descriptive attributes
- One-to-many relationships from dimensions to facts
- Single-direction cross-filtering (dimension → fact)

### Date Table Requirements

Every model with date analysis must have:
- [ ] Dedicated date dimension table
- [ ] Continuous date range (no gaps)
- [ ] Marked as "Date Table" in Power BI
- [ ] Primary key on date column
- [ ] Standard attributes: Year, Quarter, Month, Week, Day

### Relationship Guidelines

| Guideline | Reason |
|-----------|--------|
| Use single-direction filtering | Better performance, predictable behavior |
| Avoid bidirectional unless required | Ambiguity and performance issues |
| Name inactive relationships | Document purpose for USERELATIONSHIP |
| One active relationship per table pair | Prevent ambiguity |

## DAX Standards

### Formatting

```dax
// Good: Formatted for readability
Total Sales = 
VAR __CurrentSales = SUM(Sales[Amount])
VAR __Returns = SUM(Sales[Returns])
RETURN
    __CurrentSales - __Returns

// Bad: Hard to read
Total Sales = SUM(Sales[Amount])-SUM(Sales[Returns])
```

### Best Practices

| Practice | Example |
|----------|---------|
| Use variables | `VAR __Value = ... RETURN __Value` |
| Use DIVIDE for division | `DIVIDE(A, B, 0)` not `A/B` |
| Avoid nested CALCULATE | Refactor into separate measures |
| Use TREATAS over FILTER | Better performance for virtual relationships |
| Document complex logic | Add comments explaining business rules |

### Measure Organization

1. **Base Measures**: Simple aggregations
   ```dax
   Total Sales = SUM(Sales[Amount])
   ```

2. **Derived Measures**: Build on base measures
   ```dax
   Sales YTD = TOTALYTD([Total Sales], 'Date'[Date])
   ```

3. **Helper Measures**: Hidden, prefixed with underscore
   ```dax
   _BaseFilter = IF(HASONEVALUE(Dim[Column]), 1, 0)
   ```

## Power Query Standards

### Query Organization

```
📁 Data Sources
   └── SQL_Server_Connection
   └── SharePoint_Connection
📁 Staging
   └── stg_Sales
   └── stg_Products
📁 Transformations
   └── tfm_CleanSales
   └── tfm_ProductHierarchy
📁 Final
   └── Sales
   └── Products
📁 Parameters
   └── p_ServerName
   └── p_StartDate
```

### Best Practices

| Practice | Reason |
|----------|--------|
| Enable query folding | Better performance at source |
| Use parameters for connections | Environment flexibility |
| Add query documentation | Describe purpose and transformations |
| Remove unused columns early | Reduce memory footprint |
| Use reference queries | Don't duplicate logic |

### Error Handling

Always wrap potentially failing operations:
```powerquery
try Source{[Name="Products"]}[Data] otherwise null
```

## Report Standards

### Page Layout

- **KPI Cards**: Top of page
- **Primary Visual**: Center/left
- **Secondary Visuals**: Right side
- **Filters/Slicers**: Top or left panel
- **Details**: Bottom or drill-through pages

### Visual Guidelines

| Visual Type | When to Use |
|-------------|-------------|
| Card | Single KPI values |
| Line Chart | Trends over time |
| Bar Chart | Category comparisons |
| Table/Matrix | Detailed data |
| Scatter Plot | Correlation analysis |
| Map | Geographic data |

### Accessibility

- [ ] Alt text on all visuals
- [ ] Tab order defined
- [ ] High contrast color support
- [ ] Data labels where appropriate
- [ ] Avoid red/green only indicators

### Performance

- Limit visuals per page (< 10 recommended)
- Use drill-through instead of filters for detail
- Avoid high-cardinality columns in filters
- Pre-aggregate where possible

## Version Control Standards

### What to Track

| Include | Exclude |
|---------|---------|
| TMDL files | .pbix files (large) |
| Documentation | Local settings |
| Config templates | Credentials |
| Scripts | Build artifacts |

### Commit Messages

```
type(scope): description

feat(measures): add YTD time intelligence measures
fix(model): correct relationship cardinality
docs(readme): update setup instructions
refactor(queries): optimize customer dimension
```

### Branch Strategy

```
main (protected)
├── develop
│   ├── feature/add-budget-measures
│   ├── feature/new-customer-dashboard
│   └── bugfix/fix-ytd-calculation
└── release/2024.12
```

## Testing Standards

### Required Tests

| Test Type | What to Verify |
|-----------|---------------|
| Data Validation | Row counts match source |
| Measure Logic | Calculations are correct |
| Relationships | No orphan records |
| Performance | Visuals load < 3 seconds |
| RLS | Users see only their data |

### Test Queries

```dax
-- Verify row count
EVALUATE ROW("Sales Count", COUNTROWS('Sales'))

-- Check for orphans
EVALUATE
EXCEPT(
    DISTINCT('Sales'[ProductID]),
    DISTINCT('Product'[ProductID])
)
```

## Security Standards

### Row-Level Security

- [ ] Define clear roles based on business needs
- [ ] Use DAX for dynamic filtering
- [ ] Test with "View as Role" feature
- [ ] Document role assignments

### Object-Level Security (Premium)

- Hide sensitive tables/columns at object level
- Use for PII protection
- Document OLS configuration

### Data Classification

| Level | Description | Example |
|-------|-------------|---------|
| Public | Shareable externally | Product catalog |
| Internal | Company employees only | Sales totals |
| Confidential | Need-to-know basis | Employee salaries |
| Restricted | Highly regulated | PII, financial data |

## Review Checklist

Before deployment, verify:

### Data Model
- [ ] Star schema design
- [ ] Date table marked
- [ ] Relationships are single-direction
- [ ] No bidirectional without justification

### DAX
- [ ] Uses variables
- [ ] Uses DIVIDE function
- [ ] Measures documented
- [ ] Display folders assigned

### Performance
- [ ] No calculated columns where measures work
- [ ] Query folding enabled
- [ ] Visuals load quickly

### Security
- [ ] RLS implemented if needed
- [ ] No exposed credentials
- [ ] Sensitive data classified

## Related Resources

- [Naming Conventions](./NamingConventions.md)
- [BPA Rules](../Scripts/CSharp/TabularEditor/BestPracticeRules.json)
- [Performance Tips](../TipsAndTricks/Performance.md)
