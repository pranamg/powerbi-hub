# MCP Tools: Model Context Protocol for Semantic Models

> Powerful integrations and servers for agentic development

## Overview

The Model Context Protocol (MCP) is a standard for extending LLM capabilities by providing tools, resources, and prompts. For semantic models, MCP servers enable programmatic interaction with the Tabular Object Model (TOM).

## How MCP Works with Semantic Models

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI Application                            │
│                  (Claude Code, VS Code, etc.)                   │
└─────────────────────────────┬───────────────────────────────────┘
                              │ MCP Protocol
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      MCP Server                                  │
│              (powerbi-modeling-mcp)                             │
├─────────────────────────────────────────────────────────────────┤
│  Tools         │  Resources        │  Prompts                   │
│  - list_tables │  - DAX functions  │  - Create measure          │
│  - add_measure │  - Model schema   │  - Optimize DAX            │
│  - query_model │  - Best practices │  - Document model          │
└─────────────────────────────┬───────────────────────────────────┘
                              │ TOM / XMLA
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     Semantic Model                               │
│         (Power BI Desktop / Published / TMDL files)             │
└─────────────────────────────────────────────────────────────────┘
```

## Available MCP Servers

### Microsoft's Power BI Modeling MCP

The official MCP server from Microsoft for semantic model development.

**GitHub:** [microsoft/powerbi-modeling-mcp](https://github.com/microsoft/powerbi-modeling-mcp)

**Features:**
- Connect to Power BI Desktop, published models, or local TMDL
- Comprehensive tools for model manipulation
- Built-in resources for DAX functions and patterns
- Guardrails to prevent common mistakes

### Community MCP Servers

| Server | Author | Focus |
|--------|--------|-------|
| PowerBI-Desktop-MCP | Maxim Anatsko | Desktop-specific operations |
| semantic-model-mcp | Community | Lightweight alternative |

## MCP Components

### Tools

Functions the agent can call to interact with the model.

| Tool Category | Examples |
|---------------|----------|
| **Read** | list_tables, get_measure, get_relationships |
| **Write** | add_measure, update_property, delete_object |
| **Query** | execute_dax, evaluate_expression |
| **Deploy** | deploy_model, refresh_table |

### Resources

Pre-defined context that enriches agent understanding.

| Resource | Purpose |
|----------|---------|
| DAX function reference | Help agent write correct DAX |
| Model schema | Current model structure |
| Best practices | Guidelines for quality |
| Custom calendars | Time intelligence patterns |

### Prompts

Pre-configured prompts for common scenarios.

| Prompt | Purpose |
|--------|---------|
| create_time_intelligence | Generate TI measures |
| document_measures | Auto-document all measures |
| optimize_model | Find performance issues |

## Benefits of MCP Approach

1. **Tools for Agents**: MCP servers provide well-defined tools with descriptions of when and how to use them
2. **Portable Context**: Resources and prompts travel with the server
3. **Validation**: Tools can validate inputs and catch errors before they happen
4. **Bulk Operations**: Efficient for making many changes at once
5. **Consistent Interface**: Same tools work across different AI applications

## Limitations

1. **Context Usage**: MCP servers consume significant context window space (~30% in some cases)
2. **Tool Rigidity**: You can only use tools as designed; can't modify them
3. **Opacity**: May not see exactly what a tool is doing internally
4. **Windows Dependency**: TOM libraries require Windows (for now)

## When to Use MCP

### Good For

- Bulk operations (create many measures, update many properties)
- Operations requiring validation (DAX syntax, model consistency)
- Repeatable workflows (perspectives, translations)
- When you want agent to "just work" without detailed instructions

### Not Ideal For

- Single simple changes (faster to edit TMDL directly)
- Very custom operations not covered by tools
- When context window is already constrained
- Deterministic, scriptable operations (use CLI instead)

## Connection Modes

MCP servers can connect to semantic models in different ways:

| Mode | Description | Use Case |
|------|-------------|----------|
| Power BI Desktop | Connect to open PBIX | Local development |
| Published Model | Connect via XMLA endpoint | Testing, validation |
| Local TMDL | Work on metadata files | Source-controlled development |

## Related Documentation

- [Power BI Modeling MCP Setup](./PowerBI_Modeling_MCP.md)
- [Configuration Examples](./ConfigurationExamples.md)
- [Existing MCP Integration](../../Integrations/MCP/)
