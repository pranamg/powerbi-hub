---
title: User Guides
tags: [documentation]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# User Guides

> Task-oriented walkthroughs of Power BI and related tooling.

## Guides

| Guide | Covers |
|-------|--------|
| [PBIR.md](./PBIR.md) | The Power BI Enhanced Report Format — folder structure, `definition.pbir`, JSON schemas, migration |
| [DAXQueryView.md](./DAXQueryView.md) | Writing and testing DAX queries in Desktop, and measuring performance |
| [TMDLView.md](./TMDLView.md) | Viewing and editing semantic model metadata as TMDL |
| [Copilot.md](./Copilot.md) | Using Copilot features in Power BI |
| [FabricGitIntegration.md](./FabricGitIntegration.md) | Git-based source control for Fabric content |
| [TeamCollaboration.md](./TeamCollaboration.md) | Workspaces, permissions, and review workflows |

## Source control, in order

PBIP has two halves and both need to be understood before you commit either:

1. [TMDL View](./TMDLView.md) — the semantic model side
2. [PBIR](./PBIR.md) — the report side
3. [Fabric Git Integration](./FabricGitIntegration.md) — round-tripping through the service

## Related

- [Setup](../Setup/) — installation and configuration
- [AI Readiness](../../Data/AIReadiness/) — preparing a model for Copilot
- [Agentic development](../../AgenticDevelopment/) — AI-assisted development workflows
- [Scripts](../../Scripts/) — automation referenced by several guides
