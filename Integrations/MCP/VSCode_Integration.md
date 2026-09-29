---
title: "VS Code as an MCP Host for Power BI"
tags: [mcp, agentic, ai]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# VS Code as an MCP Host for Power BI

VS Code is the most direct way to use the Power BI MCP server: it is an MCP
**host**, and GitHub Copilot is the **client** inside it that connects to the
server.

> This page previously documented a package `@anthropic/powerbi-mcp`, a
> repository `github.com/anthropics/powerbi-mcp`, and CLI flags (`--model`,
> `--debug`, `--log-level`, `--config`) that do not exist. It has been
> rewritten against the real server. See
> [Server Guide](./ServerGuide.md) for which server to use and
> [Setup Guide](./Setup_Guide.md) for the four installation methods.

---

## Prerequisites

| Requirement | Detail |
|---|---|
| VS Code | Latest |
| GitHub Copilot extension | The MCP client |
| Node.js 18+ | Only for the local server |
| **Write** permission on the model | Build alone allows queries but no changes |
| External tools enabled in Desktop | File → Options → Security → *Allow external tools to access semantic model* |
| A model to connect to | Desktop, PBIP folder, or Fabric workspace |

---

## The extension route (easiest)

Install the Power BI Modeling MCP extension and skip the config file:

1. `Ctrl+Shift+X` → search for **Power BI Modeling MCP**
2. Install [analysis-services.powerbi-modeling-mcp](https://marketplace.visualstudio.com/items?itemName=analysis-services.powerbi-modeling-mcp)
3. Open Copilot chat and confirm the tools appear

> If the tools do not appear, check that **MCP servers in Copilot** is enabled
> in your GitHub settings. It is **off by default on enterprise accounts** and
> an administrator has to enable it.

---

## The config file route

Open `Ctrl+Shift+P` → **Preferences: Open User Settings (JSON)**, or use the
MCP settings UI. Add the server under `servers`:

```json
{
  "mcp": {
    "servers": {
      "powerbi-authoring-local": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start"]
      }
    }
  }
}
```

For the hosted server, no install and no Node.js:

```json
{
  "mcp": {
    "servers": {
      "powerbi-authoring-remote": {
        "type": "http",
        "url": "https://api.fabric.microsoft.com/v1/mcp/powerbi/authoring"
      }
    }
  }
}
```

> **Root key depends on the client.** VS Code uses `mcp.servers`. Other MCP
> clients use `servers` or `mcpServers` at the top level.
>
> **Register one, not both.** Two servers means two overlapping tool sets,
> ambiguous routing, and wasted tokens on every request.

A workspace-scoped `.vscode/mcp.json` keeps the configuration with the project
so a team shares it:

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

Pin the version in a shared file. `@latest` in a committed config means
everyone's agent behaviour can change without a commit.

---

## The three roles, in VS Code terms

| MCP role | In VS Code |
|---|---|
| Host | VS Code |
| Client | GitHub Copilot |
| Server | Power BI (local server on your machine, or the hosted endpoint) |

---

## Connect to a model

With a model open in Power BI Desktop:

```text
Connect to 'AdventureWorks' in Power BI Desktop
```

With a PBIP project on disk — start Copilot **in the project folder** so the
agent can read the files:

```text
Open semantic model from PBIP folder './MyModel.SemanticModel/definition'
```

With a model in Fabric:

```text
Connect to semantic model 'SalesModel' in Fabric workspace 'SalesAnalytics'
```

Then confirm with a read-only request before asking for anything destructive:

```text
List the tables and measures in this model
```

---

## First prompts worth trying

| Goal | Prompt |
|---|---|
| Inventory | `List the tables and measures, grouped by display folder` |
| Relationships | `Which relationships are active, which are inactive, and why?` |
| Audit | `Analyze the model against best practices and report findings by severity` |
| Document | `Add descriptions to all measures explaining their business purpose in plain language` |
| Naming | `Analyse the naming convention of the 'Sales' table and apply the same pattern model-wide` |
| Refactor | `Refactor 'Sales Amount 12M Avg' and '6M Avg' into a calculation group, adding 24M and 3M` |
| Query | `Evaluate [Sales Amount] for 2026 and show the result` |

More in [Use Cases](./UseCases/README.md).

---

## Working with a PBIP project in VS Code

The strongest pattern: keep the model in a PBIP project under Git, point
Copilot at the project folder, and let the MCP server edit TMDL on disk.

```text
cd path/to/your/pbip-project
code .
```

Changes become plain-text diffs you can review and revert — the main reason
to prefer this over pointing the agent at a published model. See
[Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md).

For the report half, PBIR files are also plain JSON with published schemas:

```json
{
  "json.schemas": {
    "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json": "**/*.Report/definition.pbir"
  }
}
```

That maps VS Code's JSON language service onto the PBIR schemas, so it
validates as you type. See [PBIR](../../Documentation/UserGuides/PBIR.md).

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| No Power BI tools in Copilot | Server not registered, or the Copilot MCP setting is off | Check the config path; enable **MCP servers in Copilot** in GitHub settings |
| `npx` not found | Node.js missing or not on PATH | Install Node.js 18+ and restart VS Code |
| Server starts, model not found | External tools disabled, or Desktop not open | Enable the security option; open the model |
| Reads work, writes fail | Build instead of Write; or read-only XMLA endpoint | Request Write; set the capacity's XMLA endpoint to Read Write |
| PBIP folder not found | Copilot started in the wrong directory | Open the project folder, then start Copilot there |
| Agent reconnects every operation | Hosted server; client not returning `mcp-Session-Id` | Use a session-preserving client, or switch to local |
| Local server fails on macOS | Not supported | Use the hosted server |

Check the server directly from the CLI:

```bash
copilot mcp show
```

---

## Related

- [Server Guide](./ServerGuide.md) — which server, permissions, security
- [Setup Guide](./Setup_Guide.md) — installation methods
- [Use Cases](./UseCases/README.md)
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md)
- [PBIR](../../Documentation/UserGuides/PBIR.md)
- [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md)
- [Environment Setup](../../Documentation/Setup/EnvironmentSetup.md)
