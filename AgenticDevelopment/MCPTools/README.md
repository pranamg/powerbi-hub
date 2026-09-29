---
title: MCP Tools and Servers
tags: [agentic, mcp, ai]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# MCP Tools and Servers

MCP (Model Context Protocol) is an open standard that lets an AI agent call
tools on a Power BI semantic model. This page is the map of what exists.

> **Start with the [Server Guide](../../Integrations/MCP/ServerGuide.md)** for
> which server to use and how to set it up. This page explains the components.

## What an MCP server is made of

```
AI Application  (Claude Code, Copilot CLI, VS Code)
       │  MCP protocol
       ▼
  MCP Server
   ├─ Tools      — actions: edit a measure, run a DAX query
   ├─ Resources  — read-only context: model schema, DAX docs
   └─ Prompts    — prepared workflows the agent can invoke
       │  TOM / XMLA / TMDL
       ▼
  Semantic Model  (Power BI Desktop, Fabric, PBIP files)
```

**Tools are the *what*; skills are the *how*.** A server full of tools does not
make an agent good at Power BI — see
[Agent Skills](../AgentSkills/README.md) for the guidance layer.

---

## The three things

| | Use | Status |
|---|---|---|
| **Authoring** — create or change model objects | Power BI Authoring MCP server | Local **GA**, hosted preview |
| **Consumption** — answer business questions in natural language | Fabric IQ | Current path |
| Legacy consumption | Power BI Consumption MCP server | Existing integrations only |

Microsoft's guidance is explicit: **do not use the Authoring server for
consumption.** It can run DAX to validate a model you are building, but it is
not designed to answer end-user questions.

---

## The Power BI Authoring server

Microsoft's server, documented in
[PowerBI_Modeling_MCP.md](./PowerBI_Modeling_MCP.md). It exposes tools grouped by
object type — `table_operations`, `measure_operations`,
`calculation_group_operations`, `dax_query_operations`, and around fifteen more
— plus built-in prompts for connecting and running queries.

One deployment, two options:

| | Hosted | Local |
|---|---|---|
| Transport | Streamable HTTP | `stdio` |
| Install | None | VS Code extension, npm, or executable |
| Power BI Desktop | No | Yes |
| PBIP / TMDL on disk | No | Yes |
| Transactions, traces | No | Yes |
| macOS | Yes | No |

**Register one, never both** — two servers means ambiguous routing.

---

## Community servers

Community MCP servers exist, but treat them as a supply-chain decision rather
than an install-and-forget.

| Server | Focus |
|---|---|
| [powerbi-modeling-mcp](https://github.com/microsoft/powerbi-modeling-mcp) | Microsoft's official authoring server (the reference implementation) |
| [powerbi-report-mcp](https://github.com/jonathan-pap/powerbi-report-mcp) | Report authoring against PBIR |
| [pbi-search](https://github.com/data-goblin/pbi-search) | Documentation search; used by the Data Goblins plugins |

Before installing a community server, check that it publishes source, states its
licence, and says what it does with your model metadata. A server runs with your
credentials and can transmit what it reads to whatever LLM your client is
configured with.

> **This list is deliberately short.** Earlier revisions of this page listed
> "PowerBI-Desktop-MCP", "semantic-model-mcp", and "superbi-mcp"; none could be
> verified as existing and all three are removed. Every entry above is checked
> by the scheduled external link check, so a repo that disappears is caught
> rather than left to rot.

---

## MCP in three roles

| Role | What it is | In practice |
|---|---|---|
| **Host** | The application running an MCP client | VS Code |
| **Client** | The component that connects to servers | GitHub Copilot |
| **Server** | The program exposing tools | Power BI Authoring MCP server |

With Copilot in VS Code: VS Code is the host, Copilot the client, Power BI the
server.

---

## Configuration

Real, working configuration lives in
[ConfigurationExamples.md](./ConfigurationExamples.md). The essentials:

```json
{
  "servers": {
    "powerbi-authoring-local": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start"]
    }
  }
}
```

> The root key differs by client: `servers` for VS Code and most clients,
> `mcp.servers` inside VS Code settings, `mcpServers` elsewhere. The npm
> package name still says "modeling" because it predates the rename to
> Authoring.

---

## When MCP is the right tool

**Good for:**

- Exploring an unfamiliar model
- Bulk changes — renaming, description writing, translation
- Refactoring many measures at once
- Generating model documentation
- Applying best-practice fixes consistently

**Not ideal for:**

- Single changes you can make faster in Desktop or Tabular Editor
- Anything needing immediate validation
- Report layout — the server cannot touch report pages or visuals
- Consumption — use Fabric IQ

---

## Security

- The server runs with **your** credentials and does not bypass Power BI
  security, but it **can transmit** what it reads to your LLM provider
- Review the whole chain — server, client, model provider — against your
  regulations
- Apply least privilege; `--readonly` exists for safe exploration
- No tenant setting blocks the MCP server specifically. It connects through the
  XMLA endpoint, so blocking it means disabling the XMLA endpoint

---

## Related

- [Server Guide](../../Integrations/MCP/ServerGuide.md) — the current state of play
- [PowerBI_Modeling_MCP.md](./PowerBI_Modeling_MCP.md) — the Microsoft server in detail
- [ConfigurationExamples.md](./ConfigurationExamples.md)
- [Agent Skills](../AgentSkills/README.md)
- [Use Cases](../../Integrations/MCP/UseCases/README.md)
- [MCP Prompts](../../PromptLibrary/MCPPrompts.md)
