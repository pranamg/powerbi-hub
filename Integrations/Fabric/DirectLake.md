---
title: Direct Lake Setup Guide
tags: [fabric, data-connections]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Direct Lake Setup Guide

> **Purpose:** Configure and optimize Direct Lake semantic models in Microsoft Fabric

---

## Overview

Direct Lake is a storage mode that reads Parquet files directly from OneLake
into memory, combining the speed of Import with the freshness of DirectQuery.

### Status as of 2026

| Variant | Status |
|---------|--------|
| Direct Lake on SQL | GA since November 2023 |
| Direct Lake on OneLake, model creation from Desktop | Introduced March 2025 |
| **Direct Lake on OneLake** | **GA** — now with OneLake security compatibility, more modeling features, and faster query performance |
| Direct Lake **calculated columns** | Preview |

The GA of Direct Lake on OneLake matters for security design: models respect
OneLake security, so lakehouse permissions now flow through to report
visibility rather than needing a parallel mechanism.

### How Direct Lake Works

```
OneLake (Delta/Parquet)  →  VertiPaq (In-Memory)  →  Power BI Visual
     Files                    Columnar Engine           Report
```

- No data copy/import process
- Data loaded on-demand
- Automatic cache management
- Transactional consistency (Delta Lake)

> Direct Lake is covered here only where Power BI depends on it. For the wider
> Fabric platform, see the
> [Direct Lake overview](https://learn.microsoft.com/en-us/fabric/fundamentals/direct-lake-overview).

### Choosing between the two variants

| | Direct Lake on OneLake | Direct Lake on SQL endpoints |
|---|---|---|
| Connector in TMDL view | Azure Data Lake Storage | SQL Server or `OneLake.SqlAnalytics()` |
| OneLake security | Supported — tighter integration, and DAX plans skip SQL security checks | Not applicable |
| DirectQuery fallback | **Not supported** | Supported |
| Composite models | Yes — combine with Import and DirectQuery tables | No — cannot mix Direct Lake with DirectQuery or Dual in one model |
| Licensing | Fabric capacity (F SKUs) only | Fabric capacity (F SKUs) only |

**The fallback difference is the one to plan around.** On SQL endpoints, a
Direct Lake query that exceeds a SKU limit or uses an unsupported feature
silently falls back to DirectQuery so reports keep working. On OneLake it does
not — the query fails. Size OneLake models against the SKU limit deliberately
rather than relying on a graceful degradation that is not there.

Both variants require a Fabric capacity subscription (F SKUs), unlike Import
and DirectQuery, which work on any Power BI licence including Fabric Free.

---

## Prerequisites

- Microsoft Fabric capacity (F2+) or Power BI Premium (P1+)
- Data stored in Fabric Lakehouse or Warehouse
- Delta table format (Lakehouse) or supported types (Warehouse)
- Fabric workspace (not classic)

---

## Setup Steps

### Step 1: Prepare Data in Lakehouse

Ensure tables are in Delta format with V-Order:

```python
# In Notebook
df.write.format("delta") \
    .option("vorder", "true") \
    .mode("overwrite") \
    .saveAsTable("SalesTable")
```

### Step 2: Create Default Semantic Model

Every Lakehouse/Warehouse automatically creates a default semantic model:

1. Open Lakehouse/Warehouse in Fabric
2. See "SQL analytics endpoint"
3. Default model includes all tables

### Step 3: Create Custom Semantic Model

**Option A: From Lakehouse**

1. Open Lakehouse
2. Click "New semantic model"
3. Select tables to include
4. Model opens in web modeling

**Option B: From Power BI Desktop (March 2024+)**

1. Get Data → OneLake data hub
2. Select Lakehouse/Warehouse
3. Choose Direct Lake mode
4. Select tables
5. Build model and publish

### Step 4: Add Relationships

In Web Modeling or Desktop:

```
FactSales[DateKey] → DimDate[DateKey]
FactSales[ProductKey] → DimProduct[ProductKey]
FactSales[CustomerKey] → DimCustomer[CustomerKey]
```

### Step 5: Create Measures

```dax
Total Sales = SUM(FactSales[SalesAmount])

Sales YTD = TOTALYTD([Total Sales], DimDate[Date])

Sales vs LY = 
[Total Sales] - CALCULATE([Total Sales], SAMEPERIODLASTYEAR(DimDate[Date]))
```

---

## Supported vs Unsupported Features

### Supported Features

| Feature | Status |
|---------|--------|
| Star schema relationships | ✓ |
| DAX measures | ✓ |
| Calculation groups | ✓ |
| RLS (Row-Level Security) | ✓ |
| Aggregations | ✓ |
| Q&A | ✓ |
| Quick Insights | ✓ |

### Unsupported/Limited Features

| Feature | Status | Workaround |
|---------|--------|------------|
| Calculated columns | ✗ | Create in Lakehouse |
| Calculated tables | ✗ | Create in Lakehouse |
| Many-to-many relationships | Limited | Use bridge tables |
| Composite models (mix modes) | Limited | Separate models |
| Incremental refresh | ✗ | Delta Lake handles |
| Power Query transforms | ✗ | Use Dataflow Gen2 |

---

## Performance Optimization

### Data Preparation

1. **Use V-Order optimization**

   ```python
   df.write.format("delta").option("vorder", "true").save("Tables/MyTable")
   ```

2. **Optimize file sizes**
   - Target: 128MB-1GB per file
   - Run OPTIMIZE regularly

   ```sql
   OPTIMIZE MyTable
   ```

3. **Maintain statistics**

   ```sql
   ANALYZE TABLE MyTable COMPUTE STATISTICS
   ```

### Model Design

1. **Star schema preferred**
   - Single fact table to dimension relationships
   - Avoid snowflake where possible

2. **Column cardinality**
   - High cardinality columns load slower
   - Consider grouping or bucketing

3. **Relationship design**
   - Use integer keys
   - Single-direction relationships
   - Active relationships only where needed

### Framing Optimization

Framing determines which columns load into memory:

```
Automatic Framing:
- Only columns used in visual are loaded
- Changes dynamically per query
- Memory efficient
```

Force specific framing (advanced):

```dax
// Pre-warm specific columns
EVALUATE
ROW(
    "Warmup", COUNTROWS(DimProduct),
    "Warmup2", COUNTROWS(FactSales)
)
```

---

## Monitoring

### Check Storage Mode

```dax
// In DAX Query View
EVALUATE
INFO.STORAGETABLECOLUMNSEGMENTS()
```

### Fallback Detection

**Direct Lake on SQL endpoints** may fall back to DirectQuery for:

- Unsupported DAX patterns
- Memory pressure
- Large cardinality columns
- Exceeding a SKU limit

**Direct Lake on OneLake does not support DirectQuery fallback.** A query that
would have degraded gracefully on a SQL endpoint fails instead. If you are
seeing failures rather than slow queries, check whether the model is on
OneLake and whether the query exceeds a SKU limit or uses an unsupported
feature.

Check in Fabric Monitoring Hub or:

```dax
EVALUATE
INFO.METRICS()
```

### Performance Monitoring

1. Open semantic model settings
2. View "Refresh history"
3. Check "Framing" status

---

## Refresh Behavior

### Automatic Refresh

Direct Lake doesn't use traditional refresh:

- Data reflects latest Delta version
- ~1-5 second latency typically
- No scheduled refresh needed

### Manual Sync

Force metadata sync:

```powershell
# PowerShell
Invoke-PowerBIRestMethod `
    -Url "datasets/{datasetId}/refresh" `
    -Method Post `
    -Body '{"type": "full"}'
```

### Delta Lake Maintenance

```sql
-- Regular maintenance in Lakehouse
OPTIMIZE FactSales;
VACUUM FactSales RETAIN 168 HOURS;
```

---

## Common Issues

### Issue: Fallback to DirectQuery

**Symptoms:** Slow queries, DirectQuery icon in visual

**Causes:**

- Complex DAX patterns
- Very high cardinality columns
- Memory limits reached

**Solutions:**

1. Simplify DAX
2. Aggregate data in Lakehouse
3. Increase capacity size

### Issue: Stale Data

**Symptoms:** Data not updating

**Causes:**

- Delta transaction not committed
- Streaming table delays

**Solutions:**

1. Check Delta table version
2. Run manual sync
3. Verify data pipeline completion

### Issue: Missing Tables

**Symptoms:** Tables not available in model

**Causes:**

- Table not in Delta format
- Permission issues

**Solutions:**

1. Convert to Delta format
2. Check workspace permissions

---

## Best Practices Summary

1. **Always use V-Order** for Parquet optimization
2. **Star schema design** for best performance
3. **Regular OPTIMIZE** to maintain file sizes
4. **Monitor fallbacks** and address patterns
5. **Use Dataflow Gen2** for transformations, not model
6. **Test at scale** before production

---

## Related Documents

- [Lakehouse Patterns](./Lakehouse.md)
- [Dataflow Gen2](./DataflowGen2.md)
- [OneLake Integration](./OneLake.md)
