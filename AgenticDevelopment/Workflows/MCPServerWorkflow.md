# MCP Server Workflow

> Using MCP servers for bulk operations and validated changes

## Overview

In this workflow, the agent uses MCP server tools to interact with the semantic model programmatically through the Tabular Object Model (TOM). This provides validation and is efficient for bulk operations.

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│                    MCP SERVER WORKFLOW                        │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│    User Prompt                                                │
│        │                                                      │
│        ▼                                                      │
│    ┌───────────────┐                                         │
│    │ Agent reads   │                                         │
│    │ MCP tools     │                                         │
│    └───────┬───────┘                                         │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐      ┌─────────────┐                   │
│    │ Agent calls   │ ───► │ MCP Server  │                   │
│    │ MCP tools     │ ◄─── │ (validates) │                   │
│    └───────┬───────┘      └──────┬──────┘                   │
│            │                     │                           │
│            │                     ▼                           │
│            │              ┌─────────────┐                   │
│            │              │ TOM/XMLA    │                   │
│            │              │ Operations  │                   │
│            │              └──────┬──────┘                   │
│            │                     │                           │
│            │                     ▼                           │
│            │              ┌─────────────┐                   │
│            │              │ Semantic    │                   │
│            │              │ Model       │                   │
│            │              └─────────────┘                   │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐                                         │
│    │ User validates│                                         │
│    │ changes       │                                         │
│    └───────────────┘                                         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **MCP Server**: powerbi-modeling-mcp installed and configured
2. **Power BI Desktop** or **Published Model** or **TMDL files**
3. **Coding Agent**: With MCP support (Claude Code, VS Code, etc.)
4. **Windows**: TOM libraries require Windows

## Setup

### Configure MCP Server

See [Configuration Examples](../MCPTools/ConfigurationExamples.md) for detailed setup.

Quick start for Claude Code:

```bash
claude mcp add powerbi-modeling-mcp \
  --transport stdio \
  --env PBI_MODELING_MCP_CLIENT_ID=ea0616ba-638b-4df5-95b9-636659ae5121 \
  -- "path/to/powerbi-modeling-mcp.exe" --start
```

### Verify Connection

```
User: List all tables in the model

Agent: [Calls list_tables tool]

Tables in the model:
- Sales (1,000,000 rows)
- Products (500 rows)
- Customers (10,000 rows)
- Date (3,652 rows)
```

## Best Use Cases

### 1. Bulk Measure Creation

Creating multiple measures efficiently:

```
User: Create time intelligence measures for [Total Revenue]:
      YTD, MTD, QTD, PY, and YoY %

Agent: [Calls add_measure multiple times]

Created measures:
1. [Total Revenue YTD] - TOTALYTD([Total Revenue], 'Date'[Date])
2. [Total Revenue MTD] - TOTALMTD([Total Revenue], 'Date'[Date])
3. [Total Revenue QTD] - TOTALQTD([Total Revenue], 'Date'[Date])
4. [Total Revenue PY] - CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('Date'[Date]))
5. [Total Revenue YoY %] - DIVIDE([Total Revenue] - [Total Revenue PY], [Total Revenue PY])

All measures validated and added successfully.
```

### 2. Bulk Property Updates

Updating properties across many objects:

```
User: Set display folder "Time Intelligence" for all YTD measures

Agent: [Calls list_measures to find YTD measures]
       [Calls bulk_set_property for displayFolder]

Updated 12 measures with displayFolder = "Time Intelligence"
```

### 3. Adding Descriptions

Generating and setting descriptions:

```
User: Add descriptions to all measures in the Revenue folder

Agent: [Calls list_measures with filter]
       [Analyzes each measure's DAX]
       [Calls set_description for each]

Updated descriptions for 8 measures:
- [Total Revenue]: "Sum of all revenue from sales transactions"
- [Revenue YTD]: "Year-to-date cumulative revenue"
...
```

### 4. Creating Perspectives

Setting up perspectives for different user groups:

```
User: Create a "Finance" perspective with only financial measures and the Date table

Agent: [Calls create_perspective]
       [Calls add_to_perspective for relevant objects]

Created "Finance" perspective with:
- Tables: Date, FinancialMetrics
- Measures: 15 financial measures
```

### 5. DAX Query Execution

Running queries for validation:

```
User: Query the top 10 products by revenue

Agent: [Calls execute_dax with query]

Results:
| ProductName | Revenue |
|-------------|---------|
| Product A   | $1.2M   |
| Product B   | $980K   |
...
```

## Advantages

### Validation

MCP tools validate changes before applying:

```
User: Add measure [Bad Calc] = SUM(Sales[FakeColumn])

Agent: [Calls add_measure]

Error: Column 'FakeColumn' not found in table 'Sales'.
Measure not created. Would you like me to check available columns?
```

### Efficiency for Bulk Operations

One tool call can affect many objects:

```json
{
  "tool": "bulk_set_property",
  "arguments": {
    "objects": ["[Revenue YTD]", "[Revenue MTD]", "[Revenue QTD]"],
    "property": "formatString",
    "value": "$#,##0.00"
  }
}
```

### Portable Context

MCP server provides built-in resources:

- DAX function reference
- Best practice guidelines
- Common patterns

## Limitations

### Context Window Usage

The MCP server consumes ~29% of context window:

```
┌────────────────────────────────────────┐
│ Context Window Usage                    │
├────────────────────────────────────────┤
│ ████████████░░░░░░░░ MCP Server (29%) │
│ ██████░░░░░░░░░░░░░░ System (15%)     │
│ ░░░░░░░░░░░░░░░░░░░░ Available (56%)  │
└────────────────────────────────────────┘
```

### Tool Rigidity

You can only do what the tools allow:

- Can't modify tool behavior
- May not support your specific use case
- Workaround: Combine with direct TMDL editing

### Visibility

Harder to see exactly what changed:

- No inline diffs like direct file editing
- Must check model in external tool
- Or save to TMDL and check git diff

## Tips for Success

### 1. Verify Connection First

Always confirm you're connected to the right model:

```
User: What model am I connected to?

Agent: [Calls get_connection_info]

Connected to: SalesAnalysis.pbix
Connection type: Power BI Desktop
Tables: 15
Measures: 47
```

### 2. Use Validation Tools

Before creating measures:

```
User: Validate this DAX: SUMX(Sales, Sales[Qty] * Sales[Price])

Agent: [Calls validate_dax]

DAX syntax is valid. Ready to use in a measure.
```

### 3. Save to TMDL After Changes

For source control:

```
User: Save the model to TMDL after these changes

Agent: [MCP saves to TMDL folder]

Model saved to ./Model.SemanticModel/definition/
You can now review changes with git diff and commit.
```

### 4. Combine with Direct TMDL

Use MCP for bulk ops, direct editing for simple changes:

```
User: Use MCP to create 10 measures, then directly edit TMDL 
      to fix the typo in one description

Agent: [Uses MCP for measure creation]
       [Uses file edit for description fix]
```

### 5. Manage Context Window

Disable unused tools/resources:

```json
{
  "env": {
    "PBI_MODELING_MCP_DISABLE_RESOURCES": "time_intelligence,format_strings"
  }
}
```

## Example Session

```
User: I need to add format strings to all percentage measures
      and organize them into a "Ratios" display folder

Agent: Let me first identify all percentage measures...

[Calls list_measures]

Found 8 measures that appear to be percentages:
- [Gross Margin %]
- [Net Margin %]
- [YoY Growth %]
- [Market Share %]
- [Conversion Rate %]
- [Return Rate %]
- [Discount %]
- [Utilization %]

I'll update their format strings and display folders.

[Calls bulk_set_property for formatString = "0.00%"]
[Calls bulk_set_property for displayFolder = "Ratios"]

Done! Updated 8 measures:
- Format string: 0.00%
- Display folder: Ratios

Would you like me to save the model to TMDL for review?
```

## When NOT to Use This Workflow

- **Single simple edits**: Direct TMDL is faster
- **Search operations**: Direct TMDL is more efficient
- **Deterministic scripts**: Use CLI for repeatability
- **Context-constrained sessions**: MCP uses too much context

## Related

- [MCP Tools Overview](../MCPTools/)
- [Direct Metadata Modification](./DirectMetadataModification.md)
- [CLI Tools Workflow](./CLIToolsWorkflow.md)
