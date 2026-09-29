---
title: "MCP Servers"
tags: [mcp, agentic, ai, tooling]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# MCP Servers

MCP (Model Context Protocol) lets an AI agent call tools on your Power BI
semantic model. This page is the current-state map of which server to use.

> **This area was restructured recently, and older guidance is now wrong.**
> If you have followed a tutorial that sets up a "Power BI MCP server (remote)"
> for querying data, it is describing the legacy path. See
> [Which server](#which-server) below.

---

## Which server

There are three distinct things, and picking the wrong one wastes a lot of time.

| You want to… | Use | Status |
|---|---|---|
| **Create or change** model objects — tables, columns, measures, relationships, calculation groups, translations, security roles | [Power BI Authoring MCP server](#1-power-bi-authoring-mcp-server) | Local: **GA**. Hosted: preview |
| **Answer business questions** over governed data in natural language | [Fabric IQ](#2-fabric-iq--consumption) | Current path for consumption |
| Ground a custom agent, Copilot Studio agent, or M365 Copilot in Power BI data | [Fabric IQ](#2-fabric-iq--consumption) | Current path for consumption |
| Use a pre-existing consumption integration | [Power BI Consumption MCP server](#3-legacy-consumption-mcp) | Legacy — existing integrations only |

> **Do not use the Authoring server for consumption.** It can run DAX to
> validate the model you are building, but it is not designed to answer
> business questions for end users. For consumption, use Fabric IQ.

A common and sensible pattern: **author with the Authoring server, then let
Fabric IQ serve consumption** of the model you built.

---

## 1. Power BI Authoring MCP server

Gives an agent the tools to read and write semantic models. One server, two
deployment options.

| Capability | Hosted | Local |
|---|:---:|:---:|
| Transport | Streamable HTTP | `stdio` |
| Installation | None | VS Code extension, npm, or executable |
| Updates | Managed by Microsoft | You manage them |
| Authentication | Entra ID, signed-in user | Entra ID interactive, or service principal |
| Semantic models in a Fabric workspace | Yes | Yes |
| Models open in Power BI Desktop | **No** | Yes |
| PBIP and TMDL files on disk | **No** | Yes |
| Transactions | No | Yes |
| Analysis Services traces | No | Yes |
| macOS | Yes | **No** |

### Choosing

**Hosted** when you work against Fabric workspaces. Nothing to install, and
Microsoft manages updates. This is the recommended option where it fits.

**Local** when you need any of:

- A model open in Power BI Desktop
- PBIP or TMDL files on disk
- Service principal auth in CI
- Transactions or traces

> **Never register both.** The agent then sees two overlapping tool sets,
> routing becomes ambiguous, and every request wastes tokens.

### Prerequisites

| Requirement | Detail |
|---|---|
| **Write** permission on the model | With only **Build**, the server can run DAX but not change anything |
| An MCP client in agent mode | GitHub Copilot in VS Code; check that "MCP servers in Copilot" is enabled — it is **off by default on enterprise accounts** |
| A deep-reasoning model | Model choice materially affects result quality. GPT-5 or Claude Sonnet-class |
| Local + Fabric workspace | Capacity's **XMLA endpoint set to Read Write** |
| Hosted | Tenant setting **Users can use the Power BI Model Context Protocol server endpoint** |

The two permission failures produce the same confusing symptom — the agent
reads the model fine, but every change fails. That means Build-not-Write, or a
read-only XMLA endpoint.

### Hosted setup

```json
{
  "servers": {
    "powerbi-authoring-remote": {
      "type": "http",
      "url": "https://api.fabric.microsoft.com/v1/mcp/powerbi/authoring"
    }
  }
}
```

The first tool call prompts for Entra sign-in. The server then acts with your
permissions.

**The hosted server is stateful.** It keeps your model connection in a session
and expects your client to return the `mcp-Session-Id` header on every
subsequent request. A client that opens a new session per call will make the
agent reconnect before every operation. If you see that symptom, either switch
to a session-preserving client or move to the local server.

It also requires Entra OAuth. Some MCP clients depend on **dynamic OAuth
client registration**, which Entra ID does not support — those clients cannot
connect. Use the local server, or register an Entra app yourself.

### Local setup

Via `npx` — nothing to install permanently; the package is fetched on first run:

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

> **Config shape differs by client.** VS Code and Visual Studio use `servers`
> as the root object; other MCP clients use `mcpServers`.

Requires **Node.js 18+**. Or install the
[VS Code extension](https://marketplace.visualstudio.com/items?itemName=analysis-services.powerbi-modeling-mcp),
which is the easiest path if you are using Copilot in VS Code anyway.

To confirm registration: `copilot mcp show`.

### Connect to a model

```text
Connect to semantic model 'SalesModel' in Fabric workspace 'SalesAnalytics'
```

Local only:

```text
Connect to 'AdventureWorks' in Power BI Desktop
```

```text
Open semantic model from PBIP folder './MyModel.SemanticModel/definition'
```

Then verify with a **read-only** request before asking for changes:

```text
List the tables and measures in this model
```

### Example prompts

| Scenario | Prompt |
|---|---|
| Standardise naming | `Analyze the naming convention of the 'Sales' table and apply the same pattern across the entire model.` |
| Document the model | `Add descriptions to all measures, columns, and tables that explain their purpose and the logic behind the DAX in plain business terms.` |
| Translate the model | `Generate a French translation for my model, including tables, columns, and measures.` |
| Refactor to calculation groups | `Refactor measures 'Sales Amount 12M Avg' and 'Sales Amount 6M Avg' into a calculation group, and add 24M and 3M variants.` |
| Create a Direct Lake model | `Create a Direct Lake semantic model against lakehouse 'LH_CorpData' using tables 'Product', 'Sales', 'Store'` |

### Working safely

An agent writes to your model and its changes may be irreversible.

- **Back up first.** A language model can produce unexpected results.
- **Work in PBIP under Git.** Files are plain text, so you get a reviewable
  diff and a way to revert. This is the strongest safeguard available.
- **Mind what reaches the LLM provider.** Model metadata and query results
  enter the conversation and go to whichever provider your client is
  configured with.

---

## 2. Fabric IQ — consumption

Fabric IQ is the consumption layer: natural language answers grounded in
semantic models and ontologies, respecting the permissions, RLS, and OLS
already defined on those models.

It is the supported path for data answers in Microsoft 365 Copilot, Copilot
Studio, Microsoft Foundry, and custom agents.

```text
https://fabriciq.svc.cloud.microsoft/v1/mcp/FabricIQ
```

Because it respects model security, consuming through Fabric IQ does not create
a new access path — the same RLS and OLS apply that apply in a report.

---

## 3. Legacy consumption MCP

The earlier Power BI consumption MCP server (three tools: Execute Query, Get
Semantic Model Schema, Generate Query) is still documented, but only for
integrations that already use it. It is not the path for new work — use
Fabric IQ.

Its three tools, for reference if you are maintaining an existing integration:

| Tool | Does |
|---|---|
| Execute Query | Runs a DAX query and returns results |
| Get Semantic Model Schema | Returns tables, columns, measures, relationships, and AI-optimised metadata |
| Generate Query | Uses Copilot's DAX generation to turn a question into a query; requires a Copilot licence |

---

## Layer reference

| Layer | Tool | Responsibility |
|---|---|---|
| Semantic model | Authoring MCP server | Tables, columns, measures, DAX |
| Report layer (PBIR/PBIP) | `power-bi-report-authoring` skill | Pages, visuals, filters, formatting, themes |
| Report automation | [`pbir` CLI](../../AgenticDevelopment/AgentSkills/pbir-cli.md) | Bulk edits, validation, publish |
| Live Desktop verification | Power BI Desktop Bridge | Reload Desktop, capture screenshots |
| Consumption | Fabric IQ | Natural language answers for end users |

---

## MCP in three roles

- **Host** — the application running the client. VS Code.
- **Client** — the component inside the host that connects to servers. GitHub Copilot.
- **Server** — the local or remote program exposing tools. Power BI.

With Copilot in VS Code: VS Code is the host, Copilot is the client, Power BI
provides the server.

---

## Security

MCP is a new standard and deserves a review before it reaches production.

- **Review the whole chain** — server, client, and model provider — against
  your regulations.
- **RBAC applies.** The server invokes operations with the signed-in user's
  permissions. A misconfigured or autonomous client can perform destructive
  actions. Apply least privilege.
- **MCP does not expand data access, but it does move data.** Metadata,
  schemas, and query results go to the client, which may forward them to the
  LLM provider as conversation context. Govern that movement through your
  AI data-handling policy — not through Power BI security controls alone.
- **Not all clients support safeguards.** The MCP spec has no standard flag for
  blocking destructive operations, and clients vary.
- **Compliance boundary.** These servers may interact with clients and
  services outside Fabric's compliance boundary, under their own terms. You are
  responsible for the integration meeting your obligations.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Server not in the tool list | Client not in agent mode, or Copilot's MCP setting is off | Enable **MCP servers in Copilot** in GitHub settings — off by default on enterprise |
| Can read the model, every change fails | Build instead of Write; or read-only XMLA endpoint | Request Write; set the capacity's XMLA endpoint to Read Write |
| Reconnects before every operation | Client is not returning `mcp-Session-Id` | Use a session-preserving client, or switch to local |
| Hosted sign-in fails | Tenant setting off, or client needs dynamic OAuth registration | Enable the tenant setting; use the local server or register an Entra app |
| Can't find a Desktop file or PBIP folder | Hosted server cannot reach your machine | Use the local server |
| Local server will not start on macOS | Not supported | Use the hosted server |
| Agent makes wrong changes or stalls | Model or prompt granularity | Switch to a deep-reasoning model; break the request into smaller steps |

---

## Related

- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — Microsoft's
  plugin bundles this server; the Data Goblins marketplace has more
- [Setup Guide](./Setup_Guide.md) — step-by-step local setup
- [VS Code Integration](./VSCode_Integration.md)
- [Use Cases](./UseCases/README.md)
- [pbir-cli](../../AgenticDevelopment/AgentSkills/pbir-cli.md) — the report layer
- [MCP Prompts](../../PromptLibrary/MCPPrompts.md)
- [Service Principal Setup](../../Governance/ServicePrincipalSetup.md) — CI auth
