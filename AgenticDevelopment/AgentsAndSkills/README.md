# Agents, Subagents & Skills

> Specialized AI team members for semantic model development

## Overview

In agentic development, different AI systems serve different purposes. Understanding their capabilities helps you choose the right tool for each task.

## Agent Categories

### Query Agents (Conversational BI)

Explore and query semantic models to answer data questions.

| Agent | Description |
|-------|-------------|
| Copilot in Power BI | Data Q&A, DAX query generation |
| Fabric Data Agents | Custom agents on semantic models |
| ChatGPT/Claude (with context) | Ad-hoc data exploration |

### Modify Agents (Agentic Development)

Read and modify semantic model metadata.

| Agent | Description |
|-------|-------------|
| Claude Code | Terminal-based coding agent |
| GitHub Copilot (Agent Mode) | VS Code integrated agent |
| Gemini CLI | Google's command-line agent |
| Cursor Composer | Fast model modifications |

## Recommended Agent: Claude Code

Based on current capabilities, Claude Code provides the best experience for agentic semantic model development:

**Strengths:**
- Lives in terminal (faster, more flexible)
- Excellent tool discovery and usage
- Good context window management visibility
- Strong DAX and C# code generation
- Checkpoint support for reverting changes

**Setup:**
```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Add MCP server for Power BI
claude mcp add powerbi-modeling-mcp \
  --transport stdio \
  --env PBI_MODELING_MCP_CLIENT_ID=ea0616ba-638b-4df5-95b9-636659ae5121 \
  -- "path/to/powerbi-modeling-mcp.exe" --start
```

## Skills (Specialized Capabilities)

Skills are reusable capabilities that agents can invoke. In the context of semantic models:

### DAX Skills
- Measure creation and optimization
- Time intelligence patterns
- Calculation group development
- Format string generation

### Model Management Skills
- Bulk property updates
- Relationship management
- Partition configuration
- Deployment automation

### Documentation Skills
- Description generation
- Model documentation
- Lineage documentation
- Translation management

## Subagents

Subagents are specialized agents that handle specific subtasks:

```
┌─────────────────────────────────────────────────┐
│              Main Agent (Claude Code)           │
├─────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  Search  │  │   DAX    │  │ Documentation│  │
│  │ Subagent │  │ Subagent │  │   Subagent   │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
└─────────────────────────────────────────────────┘
```

### Common Subagent Patterns

1. **Research Subagent**: Uses web search to find DAX patterns, documentation
2. **Validation Subagent**: Runs BPA, checks syntax, verifies changes
3. **Deployment Subagent**: Handles CLI commands for deployment

## Context Files for Agents

Create instruction files that agents read at session start:

### AGENTS.md (Universal)
```markdown
# Semantic Model Development Instructions

## Model Overview
- Name: Sales Analysis
- Purpose: Revenue and sales performance tracking
- Key tables: Sales, Products, Customers, Date

## DAX Conventions
- Use DIVIDE() instead of /
- Prefix measures with table name abbreviation
- Use variables for readability

## Forbidden Operations
- Never delete existing measures without confirmation
- Don't modify partition queries
- Don't change data source credentials
```

### CLAUDE.md (Claude-specific)
```markdown
# Claude Code Instructions

## Tools Available
- MCP server: powerbi-modeling-mcp
- CLI: TabularEditor.exe in PATH
- Scripts: ./Scripts/CSharp/

## Workflow
1. Always search model before making changes
2. Use MCP for bulk operations
3. Use direct TMDL edit for single changes
4. Validate with BPA after modifications
```

## Agent Capabilities Matrix

| Capability | Claude Code | GitHub Copilot | Cursor | Gemini CLI |
|------------|-------------|----------------|--------|------------|
| TMDL File Editing | ✅ | ✅ | ✅ | ✅ |
| MCP Server Support | ✅ | ✅ | ✅ | ⚠️ |
| CLI Tool Execution | ✅ | ⚠️ | ✅ | ✅ |
| Checkpoint/Undo | ✅ | ⚠️ | ✅ | ❌ |
| Context Visibility | ✅ | ❌ | ⚠️ | ❌ |
| Multi-file Parallel | ✅ | ✅ | ✅ | ✅ |

## Best Practices

1. **One Agent, One Task**: Don't ask an agent to do too many things at once
2. **Validate Frequently**: Check changes in Tabular Editor after each operation
3. **Use Checkpoints**: Save progress before risky operations
4. **Provide Examples**: Show the agent what good output looks like
5. **Iterate on Context**: Improve instruction files based on agent mistakes

## Related Documentation

- [Coding Agents Deep Dive](./CodingAgents.md)
- [Semantic Model Agent Types](./SemanticModelAgents.md)
- [MCP Tools](../MCPTools/)
