# Power Query / M Language Prompts

Use these prompts with AI assistants for Power Query development.

## Data Transformation

### Basic Transformations
```
Write Power Query M code to:
1. Load data from [source type]
2. Remove columns: [column list]
3. Filter rows where [Column] [condition]
4. Rename columns: [old name] to [new name]
5. Change types appropriately
```

```
Create a Power Query step that unpivots columns [Col1, Col2, Col3...] 
into Attribute and Value columns, then filters out null values.
```

```
Write M code to split [FullName] column into [FirstName] and [LastName],
handling cases with middle names, suffixes (Jr, Sr), and single names.
```

### Date/Time Operations
```
Generate a complete date table in Power Query from [StartDate] to [EndDate] with:
- Year, Quarter, Month, Week columns
- Month and Day names
- Fiscal year (starting month: [X])
- IsWeekend, IsHoliday flags
- Relative date flags (IsCurrentMonth, IsPriorYear)
```

```
Convert this Unix timestamp column to proper datetime,
accounting for timezone [timezone].
```

### Merging & Appending
```
Write M code to merge [Table1] with [Table2] using a fuzzy match on [Column],
with a similarity threshold of [X]%.
```

```
Create a function that appends all Excel files from folder [path],
where each file has [describe structure],
and adds a column with the source filename.
```

## Custom Functions

```
Create a reusable Power Query function that:
- Takes parameters: [list parameters]
- Performs: [describe logic]
- Returns: [describe output]
Include proper function documentation.
```

```
Write an error handling wrapper function that:
- Tries to execute a transformation
- Returns null or default value on error
- Optionally logs the error details to a separate table
```

```
Create a Power Query function that connects to REST API [URL],
handles pagination (page parameter: [param]),
and combines all pages into a single table.
```

## Performance & Optimization

```
Review this Power Query code for query folding compatibility:
[paste your M code]
Which steps break query folding? 
How can I rewrite to maintain query folding?
```

```
My Power Query takes [X] minutes to refresh.
Source: [describe source]
Steps: [describe transformations]
How can I optimize this? Consider:
- Query folding
- Reducing data early
- Avoiding expensive operations
```

## Debugging

```
This Power Query returns an error:
Error message: [paste error]
Code: [paste M code]
What's causing this and how do I fix it?
```

```
My Power Query shows [X] rows in the preview but [Y] rows after load.
Here's my code: [paste]
Why the difference and how do I diagnose?
```

## Dynamic Queries

```
Create a Power Query that:
- Uses parameter [ParamName] for [purpose]
- Dynamically builds the source path/query
- Handles when parameter is null/empty
```

```
Write M code that dynamically selects columns based on a config table,
where the config table has columns: [SourceColumn], [TargetColumn], [Include].
```

## Data Quality

```
Create Power Query steps to:
1. Identify and flag duplicate rows based on [key columns]
2. Standardize text formatting in [column] (trim, proper case)
3. Validate [column] matches pattern [regex pattern]
4. Replace invalid values with null
```

```
Write a data profiling query that returns:
- Column names and types
- Null counts
- Distinct value counts
- Min/Max for numeric columns
- Sample values
```

## API & Web Connections

```
Write Power Query to connect to [API name]:
- Authentication: [type - API key, OAuth, Basic]
- Endpoint: [URL pattern]
- Handle rate limiting
- Parse JSON response into table
```

```
Create a web scraping query for [website] that:
- Extracts table from HTML
- Handles pagination
- Cleans extracted data
```

## Tips for Better Prompts

Include when asking:
1. Source type (SQL, Excel, API, etc.)
2. Sample data structure (column names, types)
3. Expected output format
4. Any constraints (query folding needed, refresh frequency)
5. Error messages if debugging
