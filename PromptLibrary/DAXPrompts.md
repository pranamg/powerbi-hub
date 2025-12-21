# DAX Prompts for AI Assistance

Use these prompts with AI assistants (ChatGPT, Copilot, Claude) to help with DAX development.

## Measure Creation

### Time Intelligence
```
Create a DAX measure for [YTD/QTD/MTD] calculation for [measure name] 
using a date table called [DateTable] with date column [Date].
The fiscal year starts in [month].
```

```
Write a DAX measure that calculates year-over-year growth percentage 
for [Sales Amount], comparing current period to same period last year.
Handle division by zero gracefully.
```

```
Create a rolling 12-month average measure for [Revenue] that works 
with any date selection in the filter context.
```

### Rankings & Top N
```
Create a dynamic Top N measure that:
1. Ranks [Products] by [Sales]
2. Uses a parameter table for N selection
3. Groups remaining items as "Others"
```

```
Write a Pareto (80/20) analysis measure that calculates 
cumulative percentage of [Sales] for [Products], 
and classifies items as "Vital Few" or "Trivial Many".
```

### Conditional Logic
```
Create a DAX measure with the following business logic:
- If [Status] = "Active" AND [Amount] > 1000, return "High Priority"
- If [Status] = "Active" AND [Amount] <= 1000, return "Normal"  
- If [Status] = "Inactive", return "Archive"
Include error handling for nulls.
```

## Debugging & Optimization

### Debugging
```
My DAX measure returns BLANK when I expect a value:
[paste your measure]
The data model has these relationships: [describe relationships]
What could cause this and how do I fix it?
```

```
This measure works in a card visual but not in a matrix:
[paste your measure]
How does filter context affect this and what's the fix?
```

### Performance
```
Optimize this DAX measure for better performance.
It currently takes [X] seconds to render:
[paste your measure]
Table [TableName] has [X] million rows.
Suggest alternatives using variables, avoiding iterators, or other techniques.
```

```
Review this DAX for best practices and suggest improvements:
[paste your measure]
Consider: variable usage, CALCULATE placement, iterator efficiency.
```

## Data Modeling Questions

```
I have these tables and need to create a measure:
- FactSales: [columns]
- DimProduct: [columns]  
- DimDate: [columns]
Relationships: [describe]
How do I write a measure that [describes requirement]?
```

```
I need to handle a many-to-many relationship between 
[Table1] and [Table2] through [BridgeTable].
What's the correct DAX pattern for calculating [metric]?
```

## Advanced Patterns

### Row-Level Security
```
Create a DAX expression for row-level security that:
- Filters [SalesTable] based on user's region
- Users are in [UserTable] with columns [Email], [Region]
- Allow managers to see all regions
```

### Calculation Groups
```
Design a calculation group for time intelligence that includes:
- Current Period
- Prior Year
- YoY Change
- YoY % Change
Show the TMSL/Tabular Editor code.
```

## MCP Server Prompts

> Use these with AI assistants connected to Power BI via MCP Server

### Model Exploration
```
Using the connected Power BI model:
1. List all tables and their row counts
2. Show the relationships between tables
3. Identify the fact and dimension tables
4. List all measures grouped by table
```

```
Analyze the [TableName] table:
- Column names and data types
- Sample values for each column
- Identify primary key candidates
- Show relationships to other tables
```

### Query Execution
```
Execute this DAX query against the connected model:
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year],
    'Product'[Category],
    "Total Sales", [Total Sales]
)
```

```
Query the model to answer: "[Business question]"
Show me the DAX you generate and the results.
```

### Measure Development with MCP
```
Using the connected model, create a measure for [requirement].
1. First, show me the relevant tables and columns
2. Generate the DAX measure
3. Test it with a sample query
4. Explain any assumptions made
```

```
I want to create a [YTD/Ranking/etc] measure.
Query the model to find:
- The appropriate date table and column
- Related fact table
- Existing similar measures to reference
Then create the measure.
```

### Documentation Generation
```
Generate documentation for all measures in [TableName]:
- Measure name and display folder
- DAX expression
- Brief description of what it calculates
- Dependencies (tables/columns used)
Format as markdown table.
```

```
Create a data dictionary for this model:
1. List all tables with descriptions
2. Document key columns
3. Map relationships
4. Export as [markdown/JSON/HTML]
```

### Performance Analysis
```
Analyze the [MeasureName] measure:
1. Show its DAX expression
2. Identify potential performance issues
3. Test execution time with sample query
4. Suggest optimizations
```

### Data Validation
```
Validate data quality in the connected model:
1. Check for null values in key columns
2. Identify orphaned foreign keys
3. Verify date ranges
4. Check for duplicates in dimension tables
```

## Context Tips

When asking about DAX, always provide:
1. Table names and relevant column names
2. Existing relationships (one-to-many direction)
3. Filter context (what slicers/filters are applied)
4. Expected vs actual results
5. Sample data if possible

### With MCP Connected
When your AI assistant has MCP access:
- Reference columns exactly as they appear in the model
- Ask the AI to verify assumptions by querying metadata
- Request test queries to validate measure logic
- Use INFO.* functions for model discovery
