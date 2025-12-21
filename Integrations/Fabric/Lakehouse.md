# Lakehouse Integration Patterns

> **Purpose:** Best practices for integrating Power BI with Fabric Lakehouse

---

## Overview

Fabric Lakehouse combines the flexibility of a data lake with the structure of a data warehouse, storing data in Delta Lake format.

---

## Architecture Patterns

### Pattern 1: Medallion Architecture

```
Bronze (Raw)          Silver (Cleansed)       Gold (Curated)
┌─────────────┐      ┌─────────────────┐     ┌──────────────┐
│ Raw Files   │ ──►  │ Validated       │ ──► │ Star Schema  │
│ JSON, CSV   │      │ Typed           │     │ Dimensions   │
│ Parquet     │      │ Deduplicated    │     │ Facts        │
└─────────────┘      └─────────────────┘     └──────────────┘
                                                    │
                                                    ▼
                                            ┌──────────────┐
                                            │ Direct Lake  │
                                            │ Semantic     │
                                            │ Model        │
                                            └──────────────┘
```

**Implementation:**
```python
# Bronze to Silver (Notebook)
df_bronze = spark.read.parquet("Files/Bronze/sales/*.parquet")

df_silver = (df_bronze
    .dropDuplicates(["TransactionId"])
    .withColumn("SalesDate", to_date("SalesDateStr", "yyyy-MM-dd"))
    .filter(col("Amount") > 0)
)

df_silver.write.format("delta").mode("overwrite").save("Tables/Silver/Sales")
```

### Pattern 2: Real-Time + Batch Hybrid

```
Eventstream          Lakehouse           Semantic Model
┌──────────┐        ┌──────────────┐    ┌──────────────┐
│ Streaming│ ──────►│ Hot Table    │───►│ Real-Time    │
│ Data     │        │ (Recent)     │    │ Dashboard    │
└──────────┘        └──────────────┘    └──────────────┘
                           │
Batch Pipeline            │
┌──────────┐        ┌──────────────┐
│ Daily    │ ──────►│ Cold Table   │
│ Load     │        │ (Historical) │
└──────────┘        └──────────────┘
```

### Pattern 3: Department-Specific Lakehouses

```
Central Lakehouse (Governed)
├── Shared Dimensions
├── Master Data
└── Enterprise Facts
        │
        ▼ Shortcuts
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ Sales         │  │ Finance       │  │ Marketing     │
│ Lakehouse     │  │ Lakehouse     │  │ Lakehouse     │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        ▼                  ▼                  ▼
  Sales Reports     Finance Reports    Marketing Reports
```

---

## Data Loading Patterns

### Load from Files

```python
# Load CSV with schema inference
df = spark.read.format("csv") \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .load("Files/Incoming/sales_*.csv")

# Save as Delta table
df.write.format("delta") \
    .mode("overwrite") \
    .saveAsTable("Sales")
```

### Load from External Sources

```python
# From Azure SQL
df = spark.read.format("jdbc") \
    .option("url", "jdbc:sqlserver://server.database.windows.net") \
    .option("dbtable", "Sales.Orders") \
    .option("user", spark.conf.get("spark.sql.credentials.user")) \
    .option("password", spark.conf.get("spark.sql.credentials.password")) \
    .load()

df.write.format("delta").saveAsTable("Orders")
```

### Incremental Load

```python
# Get last loaded timestamp
last_load = spark.sql("SELECT MAX(LoadTimestamp) FROM SalesHistory").collect()[0][0]

# Load only new records
df_new = spark.read.parquet("Files/Bronze/sales/") \
    .filter(col("ModifiedDate") > last_load)

# Merge into target
df_new.createOrReplaceTempView("new_sales")

spark.sql("""
    MERGE INTO Sales AS target
    USING new_sales AS source
    ON target.SalesId = source.SalesId
    WHEN MATCHED THEN UPDATE SET *
    WHEN NOT MATCHED THEN INSERT *
""")
```

---

## Optimization Tips

### V-Order Optimization

V-Order is automatically applied in Fabric Lakehouse for optimal Power BI performance.

```python
# V-Order is default, but can be explicit
df.write.format("delta") \
    .option("vorder", "true") \
    .mode("overwrite") \
    .saveAsTable("OptimizedTable")
```

### Partitioning Strategy

```python
# Partition large tables by date
df.write.format("delta") \
    .partitionBy("Year", "Month") \
    .mode("overwrite") \
    .saveAsTable("LargeSalesTable")
```

### Table Maintenance

```sql
-- Optimize table (compaction + V-Order)
OPTIMIZE Sales;

-- Clean up old files
VACUUM Sales RETAIN 168 HOURS;

-- Analyze for statistics
ANALYZE TABLE Sales COMPUTE STATISTICS;
```

---

## Connecting to Power BI

### Via SQL Analytics Endpoint

```
Connection String:
Server: <workspace-name>.sql.fabric.microsoft.com
Database: <lakehouse-name>
Authentication: Azure Active Directory
```

### Via Direct Lake

See [DirectLake.md](./DirectLake.md) for detailed setup.

### Via Dataflow Gen2

1. Create Dataflow Gen2 in workspace
2. Connect to Lakehouse tables
3. Apply transformations
4. Load to semantic model or another Lakehouse

---

## Sample Notebook: Star Schema Creation

```python
# Create Date Dimension
from pyspark.sql.functions import *
from datetime import date, timedelta

# Generate date range
start_date = date(2020, 1, 1)
end_date = date(2025, 12, 31)
dates = [(start_date + timedelta(days=i),) for i in range((end_date - start_date).days + 1)]

df_dates = spark.createDataFrame(dates, ["Date"])

df_dim_date = df_dates \
    .withColumn("DateKey", date_format("Date", "yyyyMMdd").cast("int")) \
    .withColumn("Year", year("Date")) \
    .withColumn("Quarter", quarter("Date")) \
    .withColumn("Month", month("Date")) \
    .withColumn("MonthName", date_format("Date", "MMMM")) \
    .withColumn("Day", dayofmonth("Date")) \
    .withColumn("DayOfWeek", dayofweek("Date")) \
    .withColumn("DayName", date_format("Date", "EEEE")) \
    .withColumn("WeekOfYear", weekofyear("Date")) \
    .withColumn("IsWeekend", when(dayofweek("Date").isin(1, 7), True).otherwise(False)) \
    .withColumn("YearMonth", date_format("Date", "yyyy-MM")) \
    .withColumn("YearQuarter", concat(year("Date"), lit("-Q"), quarter("Date")))

df_dim_date.write.format("delta").mode("overwrite").saveAsTable("DimDate")

# Create Fact Table
df_fact_sales = spark.sql("""
    SELECT
        s.SalesId,
        CAST(date_format(s.SalesDate, 'yyyyMMdd') AS INT) as DateKey,
        s.ProductId as ProductKey,
        s.CustomerId as CustomerKey,
        s.StoreId as StoreKey,
        s.Quantity,
        s.UnitPrice,
        s.Quantity * s.UnitPrice as SalesAmount,
        s.Cost,
        (s.Quantity * s.UnitPrice) - s.Cost as Profit
    FROM Silver_Sales s
""")

df_fact_sales.write.format("delta").mode("overwrite").saveAsTable("FactSales")
```

---

## Related Documents

- [Direct Lake Setup](./DirectLake.md)
- [Dataflow Gen2](./DataflowGen2.md)
- [OneLake Integration](./OneLake.md)

---

*Last Updated: December 2024*
