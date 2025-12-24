# Coding Agents for Semantic Model Development

> Deep dive into Claude Code, GitHub Copilot, and other coding agents

## What is a Coding Agent?

A coding agent is an AI system where the LLM can generate and execute code using tools in a loop. Unlike chatbots, coding agents can:

- Read and write files
- Execute shell commands
- Use external tools (MCP servers, CLIs)
- Iterate based on results

## Claude Code

### Overview

Claude Code is Anthropic's terminal-based coding agent. It's currently the recommended choice for agentic semantic model development.

### Installation

```bash
# Install via npm
npm install -g @anthropic-ai/claude-code

# Or use directly via npx
npx @anthropic-ai/claude-code
```

### Key Features

| Feature | Description |
|---------|-------------|
| Terminal-based | Fast, no UI overhead |
| Tool calling | Can use MCP servers, bash, file I/O |
| Checkpoints | Save and restore session state |
| Context visibility | See exactly what's in the context window |
| Multi-turn | Iterative problem solving |

### Configuration for Power BI

Create `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "powerbi-modeling": {
      "command": "path/to/powerbi-modeling-mcp.exe",
      "args": ["--start"],
      "env": {
        "PBI_MODELING_MCP_CLIENT_ID": "ea0616ba-638b-4df5-95b9-636659ae5121"
      }
    }
  }
}
```

### Example Session

```
You: Search the model for measures that use DIVIDE and show me which ones 
     don't handle division by zero properly

Claude: I'll search through the TMDL files for DIVIDE usage patterns...

[Reads files, analyzes DAX]

Found 3 measures that may have issues:
1. [Sales Growth %] - Uses / instead of DIVIDE
2. [Margin Ratio] - DIVIDE with no alternate result
3. [Unit Price Avg] - Nested division without protection

Would you like me to refactor these to use DIVIDE with proper error handling?
```

## GitHub Copilot (Agent Mode)

### Overview

GitHub Copilot's agent mode works within VS Code and can modify files, run commands, and use MCP servers.

### Setup

1. Install VS Code GitHub Copilot extension
2. Enable Agent Mode in settings
3. Configure MCP servers in VS Code settings

### VS Code Settings

```json
{
  "github.copilot.chat.agent.enabled": true,
  "mcp.servers": {
    "powerbi": {
      "command": "npx",
      "args": ["powerbi-modeling-mcp"],
      "env": {
        "POWERBI_DESKTOP_PATH": "C:\\Program Files\\Microsoft Power BI Desktop\\bin\\PBIDesktop.exe"
      }
    }
  }
}
```

### Strengths & Limitations

**Strengths:**
- Integrated in VS Code (familiar UI)
- Good for code-heavy tasks
- Inline suggestions while editing

**Limitations:**
- Heavier UI overhead
- Less visibility into context usage
- MCP server support still maturing

## Gemini CLI

### Overview

Google's command-line agent with strong reasoning capabilities.

### Installation

```bash
npm install -g @google/gemini-cli
```

### Usage with Semantic Models

```bash
gemini "Analyze the DAX patterns in this TMDL folder and suggest optimizations"
```

### Considerations

- MCP support is limited
- Strong at analysis, less proven for modifications
- May require more explicit instructions

## Cursor (with Composer)

### Overview

Cursor is a VS Code fork with AI deeply integrated. Composer mode enables agentic workflows.

### Key Features

- Fast model (Composer uses efficient models)
- Good for bulk file operations
- Integrated diff view

### Best For

- Rapid iteration on TMDL files
- Search and replace operations
- Quick refactoring tasks

## Agent Comparison for Semantic Models

| Task | Best Agent | Reason |
|------|------------|--------|
| Model exploration | Claude Code | Best search, context management |
| Bulk measure creation | GitHub Copilot | Good MCP + UI integration |
| DAX optimization | Claude Code | Strong reasoning |
| Quick edits | Cursor | Fast, good diffs |
| CI/CD scripting | Any | Terminal capability |

## Common Workflows

### Workflow 1: Model Documentation

```
1. Agent reads all TMDL files
2. Identifies measures without descriptions
3. Generates descriptions based on DAX logic
4. Updates TMDL files or uses MCP to set properties
5. Human reviews and commits
```

### Workflow 2: DAX Refactoring

```
1. Human provides refactoring goal (e.g., "use new time intelligence")
2. Agent searches for affected measures
3. Agent proposes changes (shows diffs)
4. Human approves each change
5. Agent applies changes
6. Human validates in Tabular Editor
```

### Workflow 3: Model Audit

```
1. Agent runs BPA via CLI
2. Analyzes violations
3. Proposes fixes for each violation
4. Human selects which fixes to apply
5. Agent implements selected fixes
```

## Tips for Success

1. **Start Small**: Begin with read-only tasks (search, summarize)
2. **Use PBIP Format**: Always save models as PBIP for version control
3. **Validate Frequently**: Open model in Tabular Editor after changes
4. **Checkpoint Often**: Use agent checkpoints before risky operations
5. **Invest in Context**: Good AGENTS.md files pay dividends
6. **Choose the Right Model**: Use faster models (Haiku) for search, stronger models (Sonnet/Opus) for generation
