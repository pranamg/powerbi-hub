# Power BI Modeling MCP Server

> Microsoft's official MCP server for semantic model development

## Overview

The `powerbi-modeling-mcp` server from Microsoft provides comprehensive tools for AI agents to interact with Power BI semantic models through the Tabular Object Model (TOM).

**Repository:** [github.com/microsoft/powerbi-modeling-mcp](https://github.com/microsoft/powerbi-modeling-mcp)

## Prerequisites

- Windows 10/11 (TOM libraries require Windows)
- Power BI Desktop (November 2024 or later)
- .NET Runtime
- AI application with MCP support (Claude Code, VS Code, etc.)

## Installation

### Option 1: VS Code Extension

1. Install the Power BI Modeling MCP extension from VS Code Marketplace
2. Extension includes the MCP server executable
3. Configure in VS Code settings

### Option 2: Manual Download

1. Download from GitHub releases
2. Extract `powerbi-modeling-mcp.exe`
3. Note the path for configuration

### Option 3: Build from Source

```bash
git clone https://github.com/microsoft/powerbi-modeling-mcp.git
cd powerbi-modeling-mcp
dotnet build
```

## Available Tools

### Connection Tools

| Tool | Description |
|------|-------------|
| `connect_desktop` | Connect to Power BI Desktop instance |
| `connect_service` | Connect to published model via XMLA |
| `connect_tmdl` | Connect to local TMDL folder |
| `disconnect` | Close current connection |
| `get_connection_info` | Show current connection status |

### Model Exploration

| Tool | Description |
|------|-------------|
| `list_tables` | List all tables in the model |
| `list_measures` | List measures (optionally filtered by table) |
| `list_columns` | List columns in a table |
| `list_relationships` | Show all relationships |
| `get_measure` | Get measure details including DAX |
| `get_table` | Get table details |

### Model Modification

| Tool | Description |
|------|-------------|
| `add_measure` | Create a new measure |
| `update_measure` | Modify existing measure |
| `delete_measure` | Remove a measure |
| `add_calculated_column` | Create calculated column |
| `set_property` | Set any object property |
| `set_display_folder` | Organize objects in folders |
| `set_description` | Add/update descriptions |

### DAX Operations

| Tool | Description |
|------|-------------|
| `execute_dax` | Run a DAX query |
| `validate_dax` | Check DAX syntax without executing |
| `format_dax` | Format DAX expression |

### Bulk Operations

| Tool | Description |
|------|-------------|
| `bulk_set_property` | Set property on multiple objects |
| `bulk_add_measures` | Create multiple measures |
| `apply_pattern` | Apply DAX pattern to measures |

## Resources

The MCP server provides these resources for agent context:

| Resource | Content |
|----------|---------|
| `dax_functions` | DAX function reference with syntax |
| `model_schema` | Current model structure |
| `best_practices` | BPA rules and guidelines |
| `time_intelligence` | TI patterns and calendars |
| `format_strings` | Common format string patterns |

## Example Tool Usage

### List Tables

```json
{
  "tool": "list_tables",
  "arguments": {}
}

// Response
{
  "tables": [
    {"name": "Sales", "type": "Table", "rows": 1000000},
    {"name": "Products", "type": "Table", "rows": 500},
    {"name": "Date", "type": "CalculatedTable", "rows": 3652}
  ]
}
```

### Add Measure

```json
{
  "tool": "add_measure",
  "arguments": {
    "table": "Sales",
    "name": "Total Revenue YTD",
    "expression": "TOTALYTD([Total Revenue], 'Date'[Date])",
    "displayFolder": "Time Intelligence",
    "formatString": "$#,##0.00",
    "description": "Year-to-date total revenue"
  }
}
```

### Execute DAX Query

```json
{
  "tool": "execute_dax",
  "arguments": {
    "query": "EVALUATE SUMMARIZECOLUMNS('Date'[Year], \"Revenue\", [Total Revenue])"
  }
}

// Response
{
  "results": [
    {"Year": 2023, "Revenue": 1500000},
    {"Year": 2024, "Revenue": 1800000}
  ]
}
```

## Configuration

### Claude Code

```bash
claude mcp add powerbi-modeling-mcp \
  --transport stdio \
  --env PBI_MODELING_MCP_CLIENT_ID=ea0616ba-638b-4df5-95b9-636659ae5121 \
  -- "C:/path/to/powerbi-modeling-mcp.exe" --start
```

### VS Code Settings

```json
{
  "mcp.servers": {
    "powerbi-modeling": {
      "command": "C:/path/to/powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    }
  }
}
```

### Claude Desktop

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "C:/path/to/powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    }
  }
}
```

## Context Window Usage

The Power BI Modeling MCP consumes approximately **29% of the context window** with all tools and resources loaded.

### Optimization Tips

1. **Disable unused resources**: If you don't need time intelligence patterns, disable that resource
2. **Limit tool scope**: Some tools can be disabled if not needed
3. **Use sessions wisely**: Start fresh sessions for different tasks
4. **Combine with TMDL**: Use direct file editing for simple changes, MCP for bulk

## Guardrails

The MCP server includes safety features:

| Guardrail | Description |
|-----------|-------------|
| DAX validation | Validates DAX before applying changes |
| Naming check | Warns about non-standard names |
| Dependency check | Warns when deleting referenced objects |
| Backup suggestion | Reminds to save/commit before bulk changes |

## Limitations

1. **Windows Only**: TOM libraries require Windows
2. **Single Connection**: One model at a time
3. **No Direct Service Write**: Can't write directly to Power BI Service (use deployment instead)
4. **Context Heavy**: Uses significant context window

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Connection fails | Ensure Power BI Desktop is open with a model |
| Tools not appearing | Check MCP server is running |
| Slow responses | Large models take longer; increase timeout |
| DAX errors | Use validate_dax before add_measure |

## Related

- [MCP Configuration Examples](./ConfigurationExamples.md)
- [MCP Overview](./README.md)
- [Existing MCP Setup](../../Integrations/MCP/Setup_Guide.md)
