# Performance Optimization Tips & Tricks

Comprehensive guide to making Power BI reports faster.

## The Performance Pyramid

Most impact at the top:
1. **Data Model** - Most Impact
2. **DAX Measures**
3. **Visuals**
4. **Report Design** - Least Impact

## Data Model Optimization

### 1. Reduce Data Volume
- Remove unused columns
- Filter historical data
- Pre-aggregate if possible
- Consolidate duplicate tables

### 2. Choose Optimal Data Types
| Instead of... | Use... | Savings |
|---------------|--------|---------|
| Text (varying) | Text (fixed) | ~30% |
| Float | Whole Number | ~50% |
| DateTime | Date only | ~50% |

### 3. Star Schema Design
- Fewer relationships to traverse
- Better compression
- Simpler DAX

### 4. Avoid Bidirectional Relationships
- Use single direction where possible
- Consider DAX alternatives

### 5. Remove Auto Date/Time
File > Options > Data Load > Uncheck "Auto date/time"

## DAX Performance

### Optimization Checklist
- [ ] Use variables to avoid recalculation
- [ ] Move filters to CALCULATE arguments
- [ ] Avoid nested iterators
- [ ] Use DIVIDE instead of /
- [ ] Avoid FORMAT in measures

### Fast vs Slow Patterns
```dax
// SLOW
CALCULATE([Sales], FILTER(ALL(Products), Products[Category] = "Electronics"))

// FAST
CALCULATE([Sales], Products[Category] = "Electronics")
```

## Visual Performance

### Reduce Visual Count
| Visuals per Page | Performance |
|------------------|-------------|
| 1-5 | Excellent |
| 6-10 | Good |
| 11-15 | Degraded |
| 16+ | Poor |

### Optimize Visuals
- Limit data points (< 3,500)
- Avoid high cardinality legends
- Use hierarchies
- Turn off animations

## Performance Analyzer

1. View > Performance Analyzer
2. Start Recording
3. Interact with report
4. Review results

| Metric | Good | Investigate |
|--------|------|-------------|
| DAX Query | < 120ms | > 500ms |
| Visual Display | < 50ms | > 200ms |

## Quick Wins Summary

1. **Remove unused columns and tables**
2. **Disable auto date/time**
3. **Use whole numbers where possible**
4. **Limit visuals to 8-10 per page**
5. **Use variables in DAX**
6. **Check query folding in Power Query**
7. **Enable Performance Analyzer regularly**
