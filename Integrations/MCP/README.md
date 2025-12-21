# Power BI MCP (Model Context Protocol)

Connect AI assistants to your Power BI semantic models.

> **Released:** November 2025  
> **Status:** Generally Available

## What is MCP?

The Model Context Protocol (MCP) enables AI assistants (Claude, ChatGPT, Copilot, etc.) to directly interact with Power BI semantic models. This allows:

- Querying your data model through natural language
- Getting AI assistance for measure creation
- Model documentation generation
- Data exploration and analysis

## Quick Start

### Prerequisites

1. Power BI Desktop (November 2025 or later)
2. VS Code with Claude/Copilot extension
3. Node.js (for MCP server)

### Installation

```bash
# Install the official Power BI MCP server
npm install -g @anthropic/powerbi-mcp

# Or using npx (no install)
npx @anthropic/powerbi-mcp
```

### VS Code Configuration

Add to your VS Code `settings.json`:

```json
{
    "mcp.servers": {
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

### Connecting to a Model

1. Open your PBIX file in Power BI Desktop
2. Start MCP server in VS Code
3. The AI assistant now has access to your model

## Capabilities

| Feature | Description |
|---------|-------------|
| Model Exploration | Query tables, columns, measures, relationships |
| DAX Assistance | Get help writing or optimizing DAX |
| Documentation | Auto-generate model documentation |
| Data Queries | Run DAX queries through natural language |
| Measure Creation | Create and modify measures via AI |

## Example Prompts

```
"What tables are in my model?"

"Show me the DAX for the Sales YTD measure"

"Create a measure that calculates year-over-year growth"

"What relationships does the Sales table have?"

"Optimize this measure for better performance: [paste measure]"

"Document all measures in the Revenue folder"
```

## Security Considerations

- MCP runs locally - data doesn't leave your machine
- Only accessible while Power BI Desktop is open
- No cloud data transmission unless explicitly configured
- Use with appropriate data governance policies

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Connection fails | Ensure PBIX file is open in Desktop |
| Model not found | Check Desktop path in settings |
| Slow responses | Large models may need more time |

## Resources

- [Official Power BI MCP Documentation](https://powerbi.microsoft.com/blog/)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [VS Code MCP Extension](https://marketplace.visualstudio.com/items?itemName=anthropic.mcp)

---

*See setup guides in this folder for detailed configuration instructions.*
