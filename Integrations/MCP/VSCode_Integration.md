# VS Code Integration for Power BI MCP

> Configure Visual Studio Code to use AI assistants with your Power BI semantic models via MCP.

## Overview

This guide covers integrating the Power BI MCP server with VS Code, enabling AI assistants like Claude and GitHub Copilot to directly interact with your semantic models.

## Prerequisites

- VS Code installed (latest version recommended)
- Power BI MCP Server installed (see [Setup_Guide.md](./Setup_Guide.md))
- Power BI Desktop with an open .pbix file
- One of the supported AI extensions installed

## Supported Extensions

| Extension | Provider | MCP Support |
|-----------|----------|-------------|
| Claude for VS Code | Anthropic | Native |
| GitHub Copilot | GitHub/Microsoft | Via MCP plugin |
| Continue | Continue.dev | Native |
| Cody | Sourcegraph | Via MCP adapter |

---

## Method 1: Claude Extension (Recommended)

### Install Claude Extension

1. Open VS Code
2. Go to Extensions (`Ctrl+Shift+X`)
3. Search for "Claude" by Anthropic
4. Click **Install**

### Configure MCP Server

**Option A: Via Settings UI**

1. Open Settings (`Ctrl+,`)
2. Search for "MCP"
3. Click "Edit in settings.json"
4. Add the Power BI MCP configuration

**Option B: Edit settings.json Directly**

Press `Ctrl+Shift+P` → "Preferences: Open Settings (JSON)"

Add this configuration:

```json
{
    "claude.mcp.servers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp"],
            "env": {
                "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
            }
        }
    }
}
```

### Alternative: Using Global Install

If you installed globally:

```json
{
    "claude.mcp.servers": {
        "powerbi": {
            "command": "powerbi-mcp",
            "args": [],
            "env": {
                "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
            }
        }
    }
}
```

### Verify Connection

1. Open Claude panel in VS Code
2. Check for "powerbi" in connected servers
3. Send a test message: "List tables in my Power BI model"

---

## Method 2: GitHub Copilot with MCP

### Install Copilot Extensions

1. Install "GitHub Copilot" extension
2. Install "GitHub Copilot Chat" extension
3. Sign in with your GitHub account

### Configure MCP for Copilot

Create or edit `.vscode/settings.json` in your workspace:

```json
{
    "github.copilot.chat.mcp.servers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp"],
            "env": {
                "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
            }
        }
    }
}
```

### Using with Copilot Chat

1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Use `@powerbi` to invoke the MCP server
3. Example: `@powerbi what measures are in the Sales table?`

---

## Method 3: Continue Extension

### Install Continue

1. Extensions → Search "Continue"
2. Install "Continue - Codestral, Claude, and more"
3. Complete initial setup

### Configure MCP in Continue

Edit Continue's config file (`~/.continue/config.json`):

```json
{
    "models": [...],
    "mcpServers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp"],
            "env": {
                "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
            }
        }
    }
}
```

---

## Workspace Configuration

### Per-Project Settings

Create `.vscode/settings.json` in your project for project-specific config:

```json
{
    "claude.mcp.servers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp", "--config", "${workspaceFolder}/mcp-config.json"],
            "env": {
                "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
            }
        }
    }
}
```

### Multi-Root Workspace

For workspaces with multiple Power BI projects:

```json
{
    "folders": [
        { "path": "./Sales" },
        { "path": "./Finance" }
    ],
    "settings": {
        "claude.mcp.servers": {
            "powerbi-sales": {
                "command": "npx",
                "args": ["@anthropic/powerbi-mcp", "--model", "Sales.pbix"]
            },
            "powerbi-finance": {
                "command": "npx",
                "args": ["@anthropic/powerbi-mcp", "--model", "Finance.pbix"]
            }
        }
    }
}
```

---

## Tasks Integration

Create VS Code tasks to manage the MCP server:

**.vscode/tasks.json:**

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Start Power BI MCP",
            "type": "shell",
            "command": "npx @anthropic/powerbi-mcp",
            "isBackground": true,
            "problemMatcher": [],
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        },
        {
            "label": "Stop Power BI MCP",
            "type": "shell",
            "command": "pkill -f powerbi-mcp || taskkill /F /IM node.exe /FI \"WINDOWTITLE eq powerbi-mcp*\"",
            "problemMatcher": []
        },
        {
            "label": "Restart Power BI MCP",
            "dependsOn": ["Stop Power BI MCP", "Start Power BI MCP"],
            "dependsOrder": "sequence"
        }
    ]
}
```

Run tasks via `Ctrl+Shift+P` → "Tasks: Run Task"

---

## Keybindings

Add custom keybindings for quick access:

**keybindings.json:**

```json
[
    {
        "key": "ctrl+shift+p b",
        "command": "workbench.action.tasks.runTask",
        "args": "Start Power BI MCP"
    },
    {
        "key": "ctrl+shift+alt+m",
        "command": "claude.openChat"
    }
]
```

---

## Recommended Extensions Bundle

Install these for the best Power BI + VS Code experience:

```json
// .vscode/extensions.json
{
    "recommendations": [
        "anthropic.claude",
        "github.copilot",
        "github.copilot-chat",
        "continue.continue",
        "ms-vscode.vscode-node-azure-pack",
        "formulahendry.auto-rename-tag",
        "esbenp.prettier-vscode"
    ]
}
```

---

## Snippets for Power BI Prompts

Create custom snippets for common MCP prompts:

**.vscode/powerbi.code-snippets:**

```json
{
    "List Model Tables": {
        "prefix": "pbi-tables",
        "body": "List all tables in my Power BI model with their row counts",
        "description": "MCP prompt: List tables"
    },
    "Show Measures": {
        "prefix": "pbi-measures",
        "body": "Show me all measures in the ${1:Sales} table with their DAX formulas",
        "description": "MCP prompt: Show measures"
    },
    "Create Measure": {
        "prefix": "pbi-create-measure",
        "body": [
            "Create a DAX measure called '${1:Measure Name}' that:",
            "${2:description of what the measure should do}",
            "",
            "Requirements:",
            "- Use best practices",
            "- Include error handling with DIVIDE or IFERROR",
            "- Add appropriate formatting"
        ],
        "description": "MCP prompt: Create measure"
    },
    "Optimize Measure": {
        "prefix": "pbi-optimize",
        "body": [
            "Optimize this DAX measure for better performance:",
            "",
            "```dax",
            "${1:paste measure here}",
            "```",
            "",
            "Explain what changes you made and why."
        ],
        "description": "MCP prompt: Optimize DAX"
    },
    "Document Model": {
        "prefix": "pbi-document",
        "body": "Generate documentation for the ${1|entire model,Sales table,all measures,relationships|} in markdown format",
        "description": "MCP prompt: Generate documentation"
    }
}
```

Use snippets: Type prefix (e.g., `pbi-tables`) and press Tab.

---

## Troubleshooting

### Extension Not Connecting

**Check MCP Server Status:**
1. Open Output panel (`Ctrl+Shift+U`)
2. Select "Claude" or "MCP" from dropdown
3. Look for connection errors

**Verify Settings:**
```bash
# In VS Code terminal, test manually
npx @anthropic/powerbi-mcp --debug
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "Server not found" | Check command path in settings |
| "Connection refused" | Ensure Power BI Desktop is running |
| "Model not available" | Open a .pbix file in Desktop |
| "Timeout" | Increase timeout in MCP config |
| "Permission denied" | Run VS Code as administrator (first time) |

### Reset VS Code Settings

If things aren't working, try resetting:

1. `Ctrl+Shift+P` → "Preferences: Open Settings (JSON)"
2. Remove the MCP configuration
3. Restart VS Code
4. Re-add configuration

### Debug Logging

Enable verbose logging:

```json
{
    "claude.mcp.servers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp", "--debug", "--log-level", "debug"],
            "env": {
                "POWERBI_DESKTOP_PATH": "...",
                "DEBUG": "*"
            }
        }
    }
}
```

---

## Security Best Practices

1. **Don't commit credentials** - Use environment variables
2. **Workspace settings** - Keep sensitive configs in user settings, not workspace
3. **Network security** - MCP runs locally by default
4. **Data governance** - Follow your organization's data policies

### Secure Configuration

Use VS Code's secret storage for sensitive values:

```json
{
    "claude.mcp.servers": {
        "powerbi": {
            "command": "npx",
            "args": ["@anthropic/powerbi-mcp"],
            "env": {
                "POWERBI_DESKTOP_PATH": "${env:POWERBI_DESKTOP_PATH}"
            }
        }
    }
}
```

---

## Additional Resources

- [Claude Extension Documentation](https://marketplace.visualstudio.com/items?itemName=anthropic.claude)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Power BI MCP GitHub Repository](https://github.com/anthropics/powerbi-mcp)

---

*Last Updated: December 2024*
