# Agentic Development for Power BI Semantic Models

> Use AI agents to augment and accelerate semantic model development

## Overview

Agentic development refers to using AI agents with tools to read, query, and modify Power BI semantic models. This approach can augment (not replace) traditional development workflows when applied situationally.

**Key Concept:** An agent is an AI system where a large language model (LLM) can generate and execute code using tools in a loop.

## Types of Semantic Model Agents

| Type | Purpose | Examples |
|------|---------|----------|
| **Query Agents** | Explore metadata, generate queries, answer data questions | Copilot, Fabric Data Agents |
| **Modify Agents** | Read and modify model metadata, deploy and manage models | Claude Code, GitHub Copilot |

## Three Approaches to Agentic Development

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENTIC DEVELOPMENT                          │
├─────────────────┬─────────────────┬─────────────────────────────┤
│  Direct TMDL    │   MCP Servers   │   CLI Tools & Code          │
│  Modification   │                 │                             │
├─────────────────┼─────────────────┼─────────────────────────────┤
│ • Read/Write    │ • Programmatic  │ • Tabular Editor CLI        │
│   files         │   TOM access    │ • C# Scripts                │
│ • Fast search   │ • Bulk ops      │ • Maximum flexibility       │
│ • Source ctrl   │ • Validation    │ • Deterministic results     │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

## When to Use Agentic Development

### Good Use Cases

- **Search & Summarize**: Finding objects, patterns, or issues in unfamiliar models
- **Bulk Operations**: Creating time intelligence measures, setting properties in bulk
- **Repetitive Tasks**: Generating descriptions, translations, display folders
- **Refactoring**: Renaming objects, refactoring DAX to use new functions
- **Model Organization**: Addressing anti-patterns, separating thick reports

### When Traditional Tools Are Better

- Single changes that are faster in Power BI Desktop or Tabular Editor
- Changes requiring immediate validation
- Security-sensitive environments without approved AI tools
- Highly complex DAX requiring expert human review

## Key Considerations

### Security & Privacy

- Most coding agents require enterprise subscriptions for corporate data
- Local model metadata is generally safer than published models
- Always verify AI tool terms align with data governance policies

### Context is Everything

- Agents need detailed instructions in markdown files (AGENTS.md, CLAUDE.md)
- Context creation is a writing/communication skill, not technical
- Don't let AI write your context files—it leads to worse results

### Source Control is Essential

- Always use PBIP format with Git for version control
- Use agent checkpoints AND commits for safety
- Agents can make destructive changes—ability to revert is critical

## Folder Contents

| Folder | Description |
|--------|-------------|
| [Hooks](./Hooks/) | Automated triggers and quality gates |
| [AgentsAndSkills](./AgentsAndSkills/) | Coding agents and their capabilities |
| [MCPTools](./MCPTools/) | Model Context Protocol servers and tools |
| [Workflows](./Workflows/) | Enterprise-ready development patterns |
| [CustomCommands](./CustomCommands/) | Tabular Editor CLI and automation |

## Quick Start

1. **Setup**: Install a coding agent (Claude Code recommended)
2. **Prepare**: Save your model as PBIP with TMDL format
3. **Context**: Create instruction files for your agent
4. **Connect**: Configure MCP server or CLI tools
5. **Develop**: Start with search/summarize tasks, then bulk operations

## References

- [Power BI MCP Integration](../Integrations/MCP/)
- [Agentic Development Blog Series (Tabular Editor)](https://tabulareditor.com/blog/agentic-development-of-semantic-models-in-simple-terms)
- [AI Workflows for Power BI (SQLBI)](https://www.sqlbi.com/articles/introducing-ai-and-agentic-development-for-business-intelligence/)

---

*Based on Tabular Editor's agentic development blog series by Kurt Buhler*
