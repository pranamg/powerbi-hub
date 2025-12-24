# MCP Configuration Examples

> Ready-to-use configurations for different AI applications

## Claude Code Configuration

### Basic Setup

Add the MCP server via command line:

```bash
claude mcp add powerbi-modeling-mcp \
  --transport stdio \
  --env PBI_MODELING_MCP_CLIENT_ID=ea0616ba-638b-4df5-95b9-636659ae5121 \
  -- "C:/Program Files/PowerBI-Modeling-MCP/powerbi-modeling-mcp.exe" --start
```

### Verify Configuration

```bash
# List configured MCP servers
claude mcp list

# Test connection
claude mcp test powerbi-modeling-mcp
```

### Project-Level Configuration

Create `.claude/mcp.json` in your project root:

```json
{
  "servers": {
    "powerbi-modeling": {
      "command": "powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121",
        "PBI_MODELING_MCP_TMDL_PATH": "./Model.SemanticModel/definition"
      },
      "transport": "stdio"
    }
  }
}
```

## VS Code Configuration

### User Settings

Add to `settings.json` (Ctrl+Shift+P → "Preferences: Open User Settings (JSON)"):

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
  },
  "mcp.enable": true,
  "mcp.logLevel": "info"
}
```

### Workspace Settings

Create `.vscode/settings.json` in your project:

```json
{
  "mcp.servers": {
    "powerbi-modeling": {
      "command": "${workspaceFolder}/.tools/powerbi-modeling-mcp.exe",
      "args": ["--start", "--tmdl", "${workspaceFolder}/Model.SemanticModel/definition"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    }
  }
}
```

## Claude Desktop Configuration

Edit `%APPDATA%\Claude\claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "C:/Program Files/PowerBI-Modeling-MCP/powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    },
    "microsoft-docs": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-docs-server", "https://learn.microsoft.com"]
    }
  }
}
```

## Multiple Server Configuration

Configure multiple MCP servers for comprehensive capabilities:

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

## Environment-Specific Configurations

### Development Environment

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "powerbi-modeling-mcp.exe",
      "args": ["--start", "--desktop"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121",
        "PBI_MODELING_MCP_LOG_LEVEL": "debug"
      }
    }
  }
}
```

### Production/Shared Environment

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "powerbi-modeling-mcp.exe",
      "args": ["--start", "--service"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121",
        "PBI_MODELING_MCP_WORKSPACE_ID": "your-workspace-id",
        "PBI_MODELING_MCP_DATASET_ID": "your-dataset-id"
      }
    }
  }
}
```

### TMDL-Only Mode

For working with local TMDL files without Power BI Desktop:

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "powerbi-modeling-mcp.exe",
      "args": ["--start", "--tmdl-only"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121",
        "PBI_MODELING_MCP_TMDL_PATH": "C:/Projects/MyModel/Model.SemanticModel/definition"
      }
    }
  }
}
```

## Connection Modes

### Desktop Mode

Connect to a model open in Power BI Desktop:

```json
{
  "args": ["--start", "--desktop"],
  "env": {
    "PBI_DESKTOP_PORT": "auto"
  }
}
```

### Service Mode (XMLA Endpoint)

Connect to a published model:

```json
{
  "args": ["--start", "--service"],
  "env": {
    "PBI_MODELING_MCP_XMLA_ENDPOINT": "powerbi://api.powerbi.com/v1.0/myorg/WorkspaceName",
    "PBI_MODELING_MCP_DATABASE": "DatasetName"
  }
}
```

### TMDL Mode

Work directly with TMDL files:

```json
{
  "args": ["--start", "--tmdl"],
  "env": {
    "PBI_MODELING_MCP_TMDL_PATH": "./Model.SemanticModel/definition"
  }
}
```

## Authentication Options

### Interactive (Default)

User authenticates via browser popup:

```json
{
  "env": {
    "PBI_MODELING_MCP_AUTH": "interactive"
  }
}
```

### Service Principal

For automated scenarios:

```json
{
  "env": {
    "PBI_MODELING_MCP_AUTH": "serviceprincipal",
    "PBI_MODELING_MCP_TENANT_ID": "your-tenant-id",
    "PBI_MODELING_MCP_CLIENT_ID": "your-app-client-id",
    "PBI_MODELING_MCP_CLIENT_SECRET": "your-client-secret"
  }
}
```

## Troubleshooting Configurations

### Enable Debug Logging

```json
{
  "env": {
    "PBI_MODELING_MCP_LOG_LEVEL": "debug",
    "PBI_MODELING_MCP_LOG_FILE": "C:/logs/mcp-debug.log"
  }
}
```

### Common Issues

| Issue | Configuration Fix |
|-------|-------------------|
| Can't find Desktop | Set explicit `PBI_DESKTOP_PATH` |
| Timeout errors | Add `"PBI_MODELING_MCP_TIMEOUT": "60000"` |
| Auth failures | Check `_AUTH` and credential env vars |
| Wrong model | Specify `_DATABASE` explicitly |

## Sample AGENTS.md for MCP Usage

Create this file in your project root:

```markdown
# Agent Instructions

## Available MCP Servers

### powerbi-modeling
Use this MCP server for all semantic model operations:
- `list_tables`, `list_measures` for exploration
- `add_measure`, `update_measure` for modifications
- `execute_dax` for queries

## Workflow

1. Always use `list_tables` first to understand the model
2. Use `get_measure` to read existing DAX before modifying
3. Use `validate_dax` before `add_measure`
4. After bulk changes, save the TMDL files to commit

## Conventions

- Measure names: PascalCase
- Display folders: Use "/" for hierarchy (e.g., "Revenue/Time Intelligence")
- Descriptions: Required for all new measures
```
