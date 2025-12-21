# Report Analysis via MCP

> Analyze, optimize, and enhance Power BI reports using AI assistants

## Overview

AI assistants with MCP access can help analyze report performance, suggest improvements, and identify issues in your Power BI reports by examining underlying queries, measures, and model structure.

## Analysis Workflows

### Workflow 1: Performance Analysis

**Prompt:**
```
"Analyze the performance of my Sales Dashboard report. 
Identify slow queries and optimization opportunities."
```

**AI Investigation:**

1. **Query DAX Studio Log (if available):**
```dax
-- Check measure complexity
EVALUATE
SELECTCOLUMNS(
    INFO.MEASURES(),
    "Measure", [Name],
    "Expression Length", LEN([Expression]),
    "Has CALCULATE", CONTAINSSTRING([Expression], "CALCULATE"),
    "Has Iterator", 
        CONTAINSSTRING([Expression], "SUMX") || 
        CONTAINSSTRING([Expression], "AVERAGEX") ||
        CONTAINSSTRING([Expression], "MAXX")
)
ORDER BY [Expression Length] DESC
```

2. **Identify expensive patterns:**
```dax
EVALUATE
FILTER(
    INFO.MEASURES(),
    CONTAINSSTRING([Expression], "FILTER(") &&
    CONTAINSSTRING([Expression], "ALL(")
)
```

**AI Response:**
```markdown
## Performance Analysis: Sales Dashboard

### Issues Found

#### High Priority
1. **[Complex Margin Calc]** - 847 character expression
   - Nested CALCULATE (3 levels)
   - FILTER with ALL pattern (inefficient)
   - Recommendation: Rewrite using variables

2. **Visual: Sales by Day (Line Chart)**
   - Returns 365 rows per filter context
   - No aggregation - hitting detail level
   - Recommendation: Pre-aggregate to week/month

#### Medium Priority
3. **[Customer Count Distinct]** - Using COUNTROWS(VALUES())
   - Recommendation: Use DISTINCTCOUNT for better performance

### Estimated Impact
Implementing recommendations could improve load time by 40-60%
```

### Workflow 2: Measure Usage Analysis

**Prompt:**
```
"Which measures are used in reports and which are orphaned?"
```

**AI Analysis:**
```markdown
## Measure Usage Report

### Frequently Used (Top 10)
| Measure | Report Count | Visual Count |
|---------|-------------|--------------|
| [Total Sales] | 12 | 47 |
| [Sales YTD] | 8 | 23 |
| [Profit Margin %] | 7 | 19 |

### Orphaned Measures (not in any visual)
| Measure | Last Modified | Recommendation |
|---------|--------------|----------------|
| [Test Measure 1] | 6 months ago | Delete |
| [Old YoY Calc] | 1 year ago | Delete |
| [Sales_backup] | 3 months ago | Review |

### Hidden but Used (in other measures)
| Measure | Used By |
|---------|---------|
| [_BaseSales] | [Sales YTD], [Sales QTD] |
| [_CostBase] | [Profit], [Margin %] |
```

### Workflow 3: Filter Analysis

**Prompt:**
```
"Analyze how filters are being used across the report. 
Are there any conflicting or redundant filters?"
```

**AI Analysis:**
```markdown
## Filter Analysis

### Page-Level Filters
| Page | Filters Applied | Impact |
|------|-----------------|--------|
| Overview | Date[Year] = 2024 | 1.2M → 245K rows |
| Regional | + Geography[Region] = "North" | 245K → 61K rows |
| Product | + Product[Category] = "Electronics" | 61K → 12K rows |

### Potential Issues

#### 1. Redundant Filters
- Page "Sales Detail" has:
  - Slicer: Year = 2024
  - Visual filter: Year = 2024
  - Report filter: Year IN {2023, 2024}
  
  **Impact:** Confusion, no performance gain
  **Fix:** Remove duplicate visual filter

#### 2. Conflicting Filters
- "YoY Comparison" page
  - Visual shows 2024 data
  - But YoY measure calculates from 2023
  - Result: Always shows 0% growth
  
  **Fix:** Adjust visual filter context

#### 3. Missing Filters
- "Executive Summary" has no date filter
  - Shows all-time data (may be slow)
  - **Recommendation:** Add default current year filter
```

### Workflow 4: Data Quality Check

**Prompt:**
```
"Check for data quality issues in the model that might affect report accuracy"
```

**AI Investigation:**
```dax
-- Check for nulls in key columns
EVALUATE
UNION(
    ROW("Table", "Sales", "Column", "CustomerID", "Null Count", 
        CALCULATE(COUNTROWS('Sales'), ISBLANK('Sales'[CustomerID]))),
    ROW("Table", "Sales", "Column", "Amount", "Null Count",
        CALCULATE(COUNTROWS('Sales'), ISBLANK('Sales'[Amount]))),
    ROW("Table", "Product", "Column", "Category", "Null Count",
        CALCULATE(COUNTROWS('Product'), ISBLANK('Product'[Category])))
)

-- Check for orphaned dimension keys
EVALUATE
VAR OrphanedProducts = 
    EXCEPT(
        VALUES('Sales'[ProductID]),
        VALUES('Product'[ProductID])
    )
RETURN
ROW("Orphaned Product Keys", COUNTROWS(OrphanedProducts))

-- Date coverage check
EVALUATE
ROW(
    "Earliest Date", MIN('Date'[Date]),
    "Latest Date", MAX('Date'[Date]),
    "Sales Start", MIN('Sales'[OrderDate]),
    "Sales End", MAX('Sales'[OrderDate]),
    "Missing Dates", 
        COUNTROWS('Date') - COUNTROWS(DISTINCT('Sales'[OrderDate]))
)
```

**AI Response:**
```markdown
## Data Quality Report

### Critical Issues
| Issue | Impact | Records Affected |
|-------|--------|------------------|
| Null CustomerID | Lost customer attribution | 1,247 sales |
| Orphaned ProductIDs | Products not in catalog | 89 sales |
| Future dates in Sales | Invalid data | 12 records |

### Warnings
- 23% of products have no category assigned
- Date table extends to 2030, but no budget data past 2025
- 45 customers have duplicate entries (same email, different ID)

### Recommendations
1. Add data validation rules in source
2. Create "Unknown" category for unassigned products  
3. Deduplicate customer records before next refresh
```

### Workflow 5: Accessibility Analysis

**Prompt:**
```
"Analyze my report for accessibility issues"
```

**AI Analysis:**
```markdown
## Accessibility Report

### Color Contrast Issues
| Visual | Issue | Recommendation |
|--------|-------|----------------|
| KPI Cards | Light gray text on white | Use darker gray (#595959) |
| Bar Chart | Red/green only | Add patterns or use colorblind palette |
| Line Chart | Thin lines (1px) | Increase to 2px minimum |

### Navigation Issues
- No alt text on 7 images
- Tab order not set on 3 pages
- Focus indicators missing on slicers

### Screen Reader Compatibility
- 12 visuals missing titles
- Chart descriptions not set
- Data table has no header row marking

### Color Blindness Simulation
| Mode | Issues Found |
|------|--------------|
| Protanopia | Red/green KPIs indistinguishable |
| Deuteranopia | Same as above |
| Tritanopia | Blue/yellow chart series merge |

### Recommendations
1. Enable high contrast theme support
2. Add data labels to key visuals
3. Use pattern fills in addition to color
4. Add comprehensive alt text
```

### Workflow 6: Best Practice Audit

**Prompt:**
```
"Audit this report against Power BI best practices"
```

**AI Audit:**
```markdown
## Best Practice Audit

### ✅ Passing
- [ ] Semantic model uses star schema
- [ ] Date table properly marked
- [ ] Relationships are single-direction
- [ ] Measures organized in display folders

### ⚠️ Warnings
- [ ] 5 calculated columns could be measures
- [ ] Some measures not using DIVIDE for safety
- [ ] No row-level security implemented
- [ ] Model has 3 bidirectional relationships

### ❌ Violations
- [ ] Report has 23 pages (recommend <15)
- [ ] Single page has 47 visuals (recommend <10)
- [ ] Auto-date hierarchy enabled (disable for production)
- [ ] Contains imported Excel files (use proper data source)

### Performance Impact
Current estimated load time: 8.2 seconds
Potential after fixes: 3.1 seconds

### Security Concerns
- Model contains employee salary data with no RLS
- Email addresses visible in customer table
- Connection strings visible in parameters
```

## Report Enhancement Suggestions

### Visual Recommendations

**Prompt:**
```
"Based on the data in this model, suggest better visualization 
choices for the Sales Overview page"
```

**AI Response:**
```markdown
## Visualization Recommendations

### Current: Pie Chart (Sales by Region)
**Issue:** 8 regions - too many for pie chart
**Recommendation:** Horizontal bar chart or treemap
**Reason:** Easier comparison, better use of space

### Current: Table (Top Products)
**Issue:** 50 rows, minimal interactivity
**Recommendation:** Matrix with conditional formatting
**Alternative:** Bar chart with Top N filter

### Current: Card (Total Sales)
**Issue:** No context, no trend indicator
**Recommendation:** KPI visual with:
- Target comparison
- Trend arrow
- Sparkline
- YoY change %

### Missing Visualizations
Based on available measures, consider adding:
1. Funnel chart for sales pipeline
2. Cohort analysis for customer retention
3. Scatter plot for product margin vs volume analysis
```

## Related Resources

- [Performance Optimization](../../../TipsAndTricks/Performance.md)
- [Conditional Formatting](../../../Queries/DAX/Measures/ConditionalFormatting.dax)
- [Data Exploration](./DataExploration.md)
