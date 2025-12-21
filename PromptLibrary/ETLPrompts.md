# ETL & Data Pipeline Prompts

Prompts for data extraction, transformation, loading, and pipeline design.

## Data Source Connection

```
Write [Power Query/Python/SQL] code to connect to:
- Source: [database type, API, file]
- Authentication: [method]
- Location: [server/URL/path]
Include error handling and connection testing.
```

```
Create a parameterized connection that switches between:
- Development: [dev connection details]
- Production: [prod connection details]
Based on a configuration parameter.
```

## Incremental Loading

```
Design an incremental refresh pattern for:
- Table: [name]
- Size: [row count]
- Update frequency: [how often data changes]
- Key columns: [identify row uniqueness]
- Change tracking: [timestamp/version/CDC available?]
Provide Power Query and refresh policy configuration.
```

```
Implement a watermark-based incremental load:
- Source: [describe]
- Watermark column: [column name and type]
- Historical load: [initial backfill needs]
Include error recovery and duplicate handling.
```

## Data Quality

```
Create data quality checks for [table/pipeline]:
- Completeness: required fields not null
- Validity: values within expected ranges
- Uniqueness: no duplicate keys
- Consistency: referential integrity
Output: validation report with pass/fail per rule.
```

```
Build a data profiling query that returns:
- Row counts and trends
- Null percentages by column
- Distinct value counts
- Statistical summaries (min, max, avg, stddev)
- Outlier detection
For: [describe data structure]
```

## Transformation Patterns

```
Transform source data with these requirements:
Input: [describe source structure]
Output: [describe target structure]
Transformations needed:
- [list transformations: pivot, unpivot, merge, split, etc.]
Provide step-by-step code with comments.
```

```
Create a slowly changing dimension (SCD) implementation:
- Type: [Type 1/Type 2/Type 3]
- Dimension table: [columns]
- Business keys: [columns]
- Tracking columns: [for Type 2]
In: [Power Query/SQL/Python]
```

```
Design a fact table load process:
- Grain: [describe]
- Measures: [list]
- Dimensions to join: [list with keys]
- Degenerate dimensions: [if any]
Handle late-arriving facts and dimension changes.
```

## Pipeline Orchestration

```
Design a data pipeline for:
- Sources: [list all sources]
- Transformations: [describe]
- Destinations: [where data lands]
- Schedule: [frequency]
- Dependencies: [what depends on what]
Tool: [Azure Data Factory/Power Automate/Other]
Include error handling and notifications.
```

```
Create an Azure Data Factory pipeline that:
1. Extracts from [source]
2. Transforms using [method]
3. Loads to [destination]
4. Triggers Power BI dataset refresh
5. Sends notification on completion/failure
Provide JSON template.
```

## Error Handling

```
Implement error handling for this ETL process:
[describe current process]
Requirements:
- Log errors with context
- Retry transient failures [X] times
- Alert on persistent failures
- Allow partial success (process what we can)
- Support restart from failure point
```

```
Create an error logging table and process:
- Capture: timestamp, source, error type, message, affected rows
- Enable: root cause analysis, trend monitoring
- Support: reprocessing failed records
```

## Performance Optimization

```
Optimize this ETL process that currently takes [X hours]:
[describe current process and bottlenecks]
Data volume: [sizes]
Constraints: [time window, resources]
Suggest parallelization, partitioning, and optimization strategies.
```

```
Design a partitioning strategy for:
- Table: [name and size]
- Query patterns: [how data is typically filtered]
- Growth rate: [data accumulation rate]
For: [SQL Server/Azure SQL/Synapse]
```

## Dataflows

```
Create a Power BI Dataflow for:
- Sources: [list]
- Shared entities: [tables to share across datasets]
- Transformations: [describe]
- Refresh schedule: [frequency]
When should I use Dataflows vs Power Query in Desktop?
```

```
Design a dataflow architecture with:
- Staging dataflows (raw data)
- Transformation dataflows (business logic)
- Consumption dataflows (report-ready)
For: [describe scenario]
```

## Real-time / Streaming

```
Implement near-real-time data refresh for:
- Source: [describe]
- Latency requirement: [acceptable delay]
- Data volume: [events per second/minute]
Options: [DirectQuery/Streaming/Push dataset/Hybrid]
Recommend approach with implementation details.
```

## Documentation

```
Create documentation for this ETL process:
[describe or paste process]
Include:
- Data flow diagram
- Source-to-target mapping
- Transformation logic (plain language)
- Schedule and dependencies
- Error handling procedures
- Contact information
```

## Tips for ETL Prompts

Include:
1. Source system details (type, access method, credentials handling)
2. Data volumes and growth rates
3. Refresh frequency requirements
4. Data quality current state and requirements
5. Target system constraints
6. Error handling requirements
7. Monitoring and alerting needs
