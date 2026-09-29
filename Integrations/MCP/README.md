---
title: Power BI MCP (Model Context Protocol)
tags: [mcp, agentic, ai]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Power BI MCP (Model Context Protocol)

MCP lets an AI agent call tools on your Power BI semantic model — read its
metadata, run DAX against it, and change its objects.

> **Start here:** [Server Guide](./ServerGuide.md) — which server to use, and
> how to set it up. This page covers what the pieces in this folder are for.

## There are now three MCP options

The landscape was restructured recently, and older tutorials describe a
different setup. The short version:

| You want | Use |
|---|---|
| **Author** — create or change model objects | Power BI **Authoring** MCP server (local is GA; hosted is preview) |
| **Consume** — answer business questions in natural language | **Fabric IQ** |
| Maintain an existing consumption integration | Legacy Power BI Consumption MCP server |

Microsoft's guidance is explicit: **do not use the Authoring server for
consumption.** It can run DAX to validate a model you are building, but it is
not designed to answer end-user questions.

Full comparison, configuration, permissions, and troubleshooting are in
[Server Guide](./ServerGuide.md).

---

## Documents in this folder

| Document | Covers |
|---|---|
| [Server Guide](./ServerGuide.md) | **Which server, hosted vs local, permissions, config, security, troubleshooting** |
| [Setup Guide](./Setup_Guide.md) | Step-by-step local setup and connection |
| [VS Code Integration](./VSCode_Integration.md) | Copilot as an MCP host in VS Code |
| [Use Cases](./UseCases/README.md) | Worked agent workflows against a model |

## What an agent can do

| Capability | Example |
|---|---|
| Explore the model | "List the tables and measures, grouped by display folder" |
| Understand relationships | "Which relationships are active, and which are inactive?" |
| Run DAX | "Evaluate this measure for 2026 and show the result" |
| Create and modify objects | "Add a measure for net revenue after returns" |
| Bulk operations | "Standardise column names across all fact tables" |
| Apply best practices | "Audit this model and report findings by severity" |
| Generate documentation | "Document every measure in plain business language" |
| Work with source files | Edit TMDL in a PBIP project, with changes flowing through Git |

Worked examples for each of these are in [Use Cases](./UseCases/README.md).

---

## Prerequisites

| Requirement | Detail |
|---|---|
| Node.js 18+ | Only for the local server |
| An MCP client in agent mode | GitHub Copilot in VS Code. **"MCP servers in Copilot" is off by default on enterprise accounts** |
| **Write** permission on the model | Build alone permits DAX queries but no changes |
| XMLA endpoint Read Write | Local server against a Fabric workspace |
| A deep-reasoning model | Model choice materially affects result quality |

---

## Operating safely

An agent writes to your model, and its changes may be irreversible.

1. **Back up before you start.**
2. **Work in PBIP under Git.** Plain-text files give you a reviewable diff and
   a way to revert — the strongest safeguard available. See
   [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md).
3. **Verify with a read-only request first.** "List the tables" before "rename
   everything".
4. **Mind what reaches the LLM provider.** Metadata and query results enter the
   conversation and go to whichever provider your client is configured with.

---

## Related

- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — Microsoft's
  plugin bundles the Authoring server and the skills that drive it
- [pbir-cli](../../AgenticDevelopment/AgentSkills/pbir-cli.md) — the report layer
- [Preparing a Semantic Model for AI](../../Data/AIReadiness/PrepForAI.md)
- [MCP Prompts](../../PromptLibrary/MCPPrompts.md)
- [Service Principal Setup](../../Governance/ServicePrincipalSetup.md) — CI auth
- [Microsoft Learn — MCP servers](https://learn.microsoft.com/en-us/power-bi/developer/mcp)
