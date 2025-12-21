# Composite Model Patterns

> **Purpose:** Patterns for combining Import and DirectQuery modes in Power BI composite models

---

## Overview

Composite models allow combining multiple storage modes in a single semantic model:
- **Import** - Data loaded into memory
- **DirectQuery** - Queries sent to source
- **Dual** - Both Import and DirectQuery

---

## When to Use Composite Models

| Scenario | Recommended Pattern |
|----------|---------------------|
| Large fact table, small dimensions | DirectQuery fact + Import dimensions |
| Real-time + historical | DirectQuery recent + Import historical |
| Multiple sources | Mix based on source characteristics |
| Aggregations | Import aggregations + DirectQuery detail |

---

## Architecture Patterns

### Pattern 1: Import Dimensions + DirectQuery Facts

Most common pattern for enterprise models.

```
┌────────────────────┐     ┌─────────────────────┐
│ DimDate (Import)   │     │ FactSales (DQ)      │
│ DimProduct (Import)│◄────│ 100M+ rows          │
│ DimCustomer (Import│     │ DirectQuery to DW   │
│ DimStore (Import)  │     │                     │
└────────────────────┘     └─────────────────────┘
```

**Benefits:**
- Fast dimension filtering
- Good slicer performance
- Real-time fact data

**Implementation:**
```
1. Import dimension tables first
2. Add DirectQuery connection to fact table
3. Create relationships (cross-source)
4. Set relationship as "Assume Referential Integrity"
```

### Pattern 2: Aggregations + Detail

Use aggregated import tables for common queries.

```
┌─────────────────────────┐
│ SalesAgg (Import)       │
│ Aggregated by Month,    │
│ Product Category        │
│ ~10K rows               │
└───────────┬─────────────┘
            │ Falls back when
            │ detail needed
            ▼
┌─────────────────────────┐
│ FactSales (DirectQuery) │
│ Full detail             │
│ ~500M rows              │
└─────────────────────────┘
```

See [Aggregations Guide](#aggregation-setup) below.

### Pattern 3: Hot/Cold Data Split

Recent data via DirectQuery, historical via Import.

```
┌──────────────────────┐    ┌──────────────────────┐
│ Sales_Current (DQ)   │    │ Sales_Archive (Imp)  │
│ Last 90 days         │    │ Older than 90 days   │
│ Real-time updates    │    │ Refreshed nightly    │
└──────────┬───────────┘    └──────────┬───────────┘
           │                           │
           └───────────┬───────────────┘
                       ▼
              Combined in measures
```

**DAX Pattern:**
```dax
Total Sales = 
    CALCULATE(
        SUM(Sales_Current[Amount]),
        Sales_Current[Date] >= TODAY() - 90
    ) +
    CALCULATE(
        SUM(Sales_Archive[Amount]),
        Sales_Archive[Date] < TODAY() - 90
    )
```

### Pattern 4: Multi-Source Integration

Combine different data sources.

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ SQL Server      │  │ Databricks      │  │ Excel/CSV       │
│ DirectQuery     │  │ DirectQuery     │  │ Import          │
│ Transactional   │  │ Analytics       │  │ Targets         │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              ▼
                    Unified Semantic Model
```

---

## Aggregation Setup

### Step 1: Create Aggregation Table

In source database or via Power Query:
```sql
-- Create aggregation in source
CREATE TABLE Sales_Agg AS
SELECT 
    YEAR(SalesDate) as Year,
    MONTH(SalesDate) as Month,
    ProductCategory,
    Region,
    COUNT(*) as SalesCount,
    SUM(Amount) as TotalAmount,
    SUM(Quantity) as TotalQuantity
FROM FactSales
GROUP BY 
    YEAR(SalesDate),
    MONTH(SalesDate),
    ProductCategory,
    Region
```

### Step 2: Import Aggregation Table

1. Connect to aggregation table
2. Set storage mode to Import
3. Create relationships to dimensions

### Step 3: Configure Aggregation Mapping

1. Select aggregation table in model view
2. Go to Properties > Manage aggregations
3. Map columns:

| Agg Column | Summarization | Detail Table | Detail Column |
|------------|---------------|--------------|---------------|
| TotalAmount | Sum | FactSales | Amount |
| TotalQuantity | Sum | FactSales | Quantity |
| SalesCount | Count | FactSales | SalesId |
| Year | GroupBy | DimDate | Year |
| Month | GroupBy | DimDate | Month |
| ProductCategory | GroupBy | DimProduct | Category |
| Region | GroupBy | DimGeography | Region |

### Step 4: Hide Aggregation Table

1. Right-click aggregation table
2. Select "Hide in report view"
3. Users query normally, aggregations used automatically

### Step 5: Verify Aggregation Hits

Use Performance Analyzer:
1. View > Performance Analyzer
2. Start recording
3. Run queries
4. Check if "Aggregation" used (vs DirectQuery)

---

## Relationship Configuration

### Cross-Source Relationships

When connecting Import to DirectQuery:

1. **Assume Referential Integrity**
   - Enable for better performance
   - Requires data integrity in source

2. **Cardinality**
   - Typically Many-to-One (Fact to Dim)
   - Star schema preferred

3. **Cross-Filter Direction**
   - Single preferred for performance
   - Bi-directional only if necessary

### Limited Relationships

Some relationships have limitations:
- Many-to-many between storage modes
- Calculated tables to DirectQuery

---

## Performance Optimization

### Storage Mode Selection

| Table Type | Recommended Mode | Reason |
|------------|------------------|--------|
| Small dimension (<100K) | Import | Best performance |
| Large dimension (>1M) | DirectQuery or Dual | Memory efficiency |
| Fact table (any size) | DirectQuery | Real-time, no refresh |
| Aggregation | Import | Query acceleration |
| Bridge table | Dual | Supports both modes |

### Query Optimization

1. **Filter early**
   ```dax
   // Good - filter before aggregation
   CALCULATE(
       SUM(FactSales[Amount]),
       DimDate[Year] = 2024
   )
   ```

2. **Use aggregation-friendly patterns**
   ```dax
   // Aggregation-compatible
   Total Sales = SUM(FactSales[Amount])
   
   // May not use aggregation
   Distinct Count = DISTINCTCOUNT(FactSales[CustomerId])
   ```

3. **Limit detail queries**
   - Use Top N filters
   - Avoid showing detail rows
   - Pre-aggregate where possible

### Dual Mode Strategy

Use Dual for tables needed by both Import and DirectQuery:
```
DimDate (Dual)
├── Connects to FactSales_Detail (DirectQuery)
└── Connects to SalesAgg (Import)
```

---

## Common Issues and Solutions

### Issue: Slow Slicer Performance

**Cause:** Dimension in DirectQuery mode

**Solution:** Change dimension to Import or Dual mode

### Issue: Aggregation Not Used

**Causes:**
- Unsupported DAX pattern
- Missing dimension mapping
- Filter on unmapped column

**Solution:** Check aggregation mapping, simplify DAX

### Issue: Relationship Errors

**Cause:** Cross-source relationship limitations

**Solution:**
- Use Dual mode for bridge tables
- Ensure referential integrity
- Check cardinality settings

### Issue: Inconsistent Results

**Cause:** Data not synchronized between modes

**Solution:**
- Align refresh schedules
- Use same data source where possible
- Document data latency expectations

---

## Monitoring

### Performance Analyzer

1. Enable in View tab
2. Start Recording
3. Refresh visuals
4. Analyze:
   - DirectQuery queries
   - Aggregation hits
   - Query duration

### Query Diagnostics

In Power Query:
1. Tools > Start Diagnostics
2. Refresh
3. Stop Diagnostics
4. Review query patterns

### DAX Studio

For detailed analysis:
```dax
// Check storage engine queries
-- View Server Timings
-- Check if aggregations used
```

---

## Best Practices Summary

1. **Start with Import** for dimensions
2. **Use DirectQuery** only for large/real-time facts
3. **Add aggregations** for common query patterns
4. **Enable Assume Referential Integrity**
5. **Use Dual mode** for shared tables
6. **Monitor performance** regularly
7. **Document** storage mode decisions
8. **Test** at production scale

---

## Related Documents

- [Performance Tips](../TipsAndTricks/Performance.md)
- [Direct Lake Setup](../Integrations/Fabric/DirectLake.md)
- [DAX Optimization](../TipsAndTricks/DAX.md)

---

*Last Updated: December 2024*
