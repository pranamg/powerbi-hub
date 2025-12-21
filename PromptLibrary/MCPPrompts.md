# MCP Server Prompts

> Specialized prompts for AI assistants connected to Power BI via MCP Server

## Model Discovery

### Initial Exploration
```
I've connected to a Power BI model. Give me a complete overview:
1. List all tables with row counts
2. Identify fact vs dimension tables
3. Show all relationships
4. Count measures per table
5. Highlight any potential issues (bidirectional relationships, missing keys)
```

### Table Deep Dive
```
Analyze the [TableName] table in detail:
- All columns with data types
- Sample of 5 rows
- Unique value counts for text columns
- Min/max/avg for numeric columns
- Null percentage per column
```

### Measure Inventory
```
Create a measure inventory:
1. List all measures organized by display folder
2. Categorize by type (base, time intelligence, ratio, etc.)
3. Show expression length as complexity indicator
4. Identify measures with no display folder
```

### Relationship Analysis
```
Map all relationships in this model:
- From table/column to table/column
- Cardinality (1:1, 1:N, N:N)
- Cross-filter direction
- Active vs inactive
- Identify role-playing dimensions
```

## Query Assistance

### Natural Language to DAX
```
Translate to DAX and execute: "[Natural language question]"
Show me:
1. The DAX query you'll run
2. The results
3. Any assumptions made
```

### Complex Analysis
```
Help me answer this business question by running appropriate queries:
"[Complex question like: Which customer segments are growing fastest 
and what products are driving that growth?]"
Break it down into steps and show intermediate results.
```

### Comparative Analysis
```
Compare [Dimension A values] vs [Dimension B values] for [Metric]:
1. Side-by-side comparison
2. Calculate differences
3. Statistical significance if applicable
4. Visualize the comparison
```

## Measure Development

### Create with Context
```
I need a measure that calculates [requirement].
Using the connected model:
1. Identify the right tables and columns
2. Check for existing similar measures
3. Write the DAX
4. Test with a sample query
5. Validate against expected results
```

### Measure Testing Suite
```
For the measure [MeasureName]:
1. Show the current DAX expression
2. Execute tests:
   - Basic aggregation test
   - Filter context test (by different dimensions)
   - Edge case test (nulls, zeros, empty)
3. Report pass/fail for each test
```

### Optimize Existing Measure
```
Optimize [MeasureName]:
1. Show current expression
2. Profile with sample query (note execution time)
3. Identify performance issues
4. Propose optimized version
5. Compare results (should be identical)
6. Compare performance
```

## Documentation

### Model Documentation
```
Generate comprehensive model documentation:

## Overview
- Model name and description
- Table count and total rows
- Last refresh time

## Tables
For each table: name, type, rows, key columns

## Measures  
For each measure: name, expression, description

## Relationships
Visual diagram or detailed list

Export as markdown.
```

### Measure Documentation
```
Document all measures in [TableName] with:
- Name
- Business description (infer from expression)
- DAX expression (formatted)
- Input dependencies
- Example usage
- Related measures
```

### Data Dictionary
```
Create a data dictionary for [TableName]:
- Column name
- Data type
- Business description (infer)
- Sample values
- Constraints (PK, FK, not null)
```

## Data Quality

### Validation Checks
```
Run data quality checks:
1. Null/blank values in key columns
2. Orphaned dimension keys
3. Date continuity (gaps in date table)
4. Duplicate records in dimensions
5. Referential integrity
Report issues found with counts and examples.
```

### Anomaly Detection
```
Detect anomalies in [Metric]:
1. Calculate statistical bounds (mean, std dev)
2. Identify outliers (>2 std dev)
3. Show anomalous records with context
4. Suggest possible causes
```

### Data Profiling
```
Profile [TableName]:
- Total rows
- Column statistics
- Value distributions
- Pattern analysis for text columns
- Completeness percentage
```

## Performance Analysis

### Query Performance
```
Analyze query performance:
1. Execute: [DAX query]
2. Note execution time
3. Identify bottlenecks
4. Suggest optimizations
5. Test optimized version
```

### Measure Complexity
```
Rank measures by complexity:
1. List all measures
2. Score by: expression length, CALCULATE depth, iterator count
3. Flag potentially slow measures
4. Prioritize optimization candidates
```

## Report Analysis

### Usage Patterns
```
Analyze measure usage:
- Which measures are used together frequently?
- Which have high cardinality dimensions?
- Which should be cached vs calculated?
```

### Visual Optimization
```
For a report with [describe visuals]:
1. Query the underlying data
2. Estimate row counts per visual
3. Identify heavy queries
4. Suggest simplifications
```

## Prompt Templates

### Standard Format
```
Context: [Brief context about what you're trying to achieve]
Model: Connected via MCP
Request: [Specific ask]
Output: [Desired format - table, markdown, JSON, etc.]
```

### Iterative Analysis
```
Session goal: [High-level objective]
Step 1: [First question]
[Wait for response]
Step 2: Based on above, [follow-up question]
[Continue iterating]
```

### Comparison Template
```
Compare:
- A: [First item/period/dimension]
- B: [Second item/period/dimension]
Metrics: [List of metrics to compare]
Format: [Side-by-side table / chart description / narrative]
```

## Best Practices

### Effective Prompting
1. **Be specific** - Use exact table/column names when known
2. **Set expectations** - Specify output format desired
3. **Iterate** - Start broad, then drill down
4. **Validate** - Ask for test queries to verify results
5. **Document** - Request documentation alongside code

### Security Reminders
- Don't expose sensitive column names in shared prompts
- Be aware data results flow through AI service
- MCP respects your Power BI permissions
- Review AI-generated queries before production use

## Related Resources

- [MCP Setup Guide](../Integrations/MCP/Setup_Guide.md)
- [MCP Use Cases](../Integrations/MCP/UseCases/)
- [DAX Query View Guide](../Documentation/UserGuides/DAXQueryView.md)
