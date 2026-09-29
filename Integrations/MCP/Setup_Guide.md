---
title: "Power BI Authoring MCP Server — Local Setup"
tags: [mcp, agentic, ai, setup]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Power BI Authoring MCP Server — Local Setup

Step-by-step setup for the **local** Power BI Authoring MCP server, which lets
an AI agent read and change semantic models in Power BI Desktop, on disk as
PBIP/TMDL, or in a Fabric workspace.

> **Choose your deployment first.** The local server is the right choice when
> you need Power BI Desktop, PBIP files on disk, service principal auth in CI,
> transactions, or traces. If you only need Fabric workspaces, the **hosted**
> server requires no install at all. See [Server Guide](./ServerGuide.md) for
> the comparison — and note that you should register **one**, never both.

---

## Prerequisites

| Requirement | Detail |
|---|---|
| **Node.js 18+** | With npm and npx |
| An MCP client in agent mode | GitHub Copilot in VS Code is the common choice |
| **Write** permission on the model | With only **Build**, the agent can run DAX but cannot change anything |
| XMLA endpoint **Read Write** | Required on the capacity when the model is in a Fabric workspace |
| A deep-reasoning model | GPT-5 or Claude Sonnet-class. Model choice materially affects output quality |

**macOS:** the local server is not supported. Use the
[hosted server](./ServerGuide.md#1-power-bi-authoring-mcp-server) instead.

Verify Node:

```bash
node --version    # v18.0.0 or higher
npm --version
npx --version
```

---

## Method 1 — VS Code extension (easiest)

If you are using GitHub Copilot in VS Code, install the extension and skip the
config file entirely.

1. Install [VS Code](https://code.visualstudio.com/download) and the GitHub
   Copilot Chat extension
2. Install the
   [Power BI Modeling MCP extension](https://marketplace.visualstudio.com/items?itemName=analysis-services.powerbi-modeling-mcp)
3. Open Copilot chat and confirm `powerbi-modeling-mcp` appears in the tool list

> If the server is missing, check that **MCP servers in Copilot** is enabled in
> your GitHub settings. It is **off by default on enterprise accounts** and an
> administrator has to turn it on.

## Method 2 — npx (no install)

Node downloads the package on first run, so there is nothing to install
permanently.

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

> **Config root key depends on the client.** VS Code and Visual Studio use
> `servers`. Other MCP clients use `mcpServers`.

## Method 3 — npm install

For a pinned, reproducible setup — worth doing in CI:

```bash
npm install -g @microsoft/powerbi-modeling-mcp
```

Or as a project dependency, which is the better choice for a team:

```bash
npm install @microsoft/powerbi-modeling-mcp
```

Then point the config at the pinned version:

```json
{
  "servers": {
    "powerbi-authoring-local": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@microsoft/powerbi-modeling-mcp@<pinned-version>", "--start"]
    }
  }
}
```

Pinning matters in CI: `@latest` means your pipeline can change behaviour
without a commit explaining why.

## Method 4 — standalone executable

The repository publishes a standalone binary if you would rather avoid Node
entirely:

```json
{
  "servers": {
    "powerbi-authoring-local": {
      "type": "stdio",
      "command": "C:\\MCPServers\\PowerBIModelingMCP\\powerbi-modeling-mcp.exe",
      "args": ["--start"]
    }
  }
}
```

See the [repository README](https://github.com/microsoft/powerbi-modeling-mcp)
for download and service principal configuration.

---

## Enable external tools in Power BI Desktop

The server reaches a local Desktop instance through the external tools
interface, which must be enabled:

1. Power BI Desktop → **File → Options and settings → Options**
2. **Security** → enable **Allow external tools to access semantic model**
3. Restart Power BI Desktop

Without this, the server starts but cannot find your model.

---

## Connect to a semantic model

The server must be told which model to work on before it can do anything.

**Fabric workspace:**

```text
Connect to semantic model 'SalesModel' in Fabric workspace 'SalesAnalytics'
```

**Power BI Desktop (local server only):**

```text
Connect to 'AdventureWorks' in Power BI Desktop
```

**PBIP project on disk (local server only):**

```text
Open semantic model from PBIP folder './MyModel.SemanticModel/definition'
```

For PBIP, the PBIR-enabled format is what you want — see
[PBIR](../../Documentation/UserGuides/PBIR.md).

---

## Verify with a read-only request

Always confirm the connection before asking for a change:

```text
List the tables and measures in this model
```

If that returns a sensible inventory, the server is connected and you have the
permissions you think you have. If it fails, fix that before proceeding.

Then check your write access:

```text
Create a measure called '__PermissionTest' that returns 1
```

If that succeeds but the agent reports changes failing elsewhere, the problem
is usually Write permission or the XMLA endpoint setting rather than the
connection.

---

## Permissions that decide what works

| You have | The agent can |
|---|---|
| **Build** | Read metadata, run DAX queries |
| **Write** | Also create and change model objects |

A Fabric workspace model additionally needs the capacity's **XMLA endpoint set
to Read Write**. Without it, every write fails even with Write permission.

The symptom — reads succeed, writes fail — has exactly two causes. Check them
in that order.

---

## First things to try

| Task | Prompt |
|---|---|
| Inventory | `List the tables and measures, grouped by display folder` |
| Relationships | `Which relationships are active and which are inactive, and why?` |
| Audit | `Analyze the model against best practices and report findings by severity` |
| Documentation | `Add descriptions to all measures explaining their business purpose in plain language` |
| Naming | `Analyze the naming convention of the 'Sales' table and apply the same pattern model-wide` |
| Calculation groups | `Refactor 'Sales Amount 12M Avg' and '6M Avg' into a calculation group, adding 24M and 3M` |
| DAX | `Evaluate [Sales Amount] for 2026 and show the result` |

The full [Use Cases](./UseCases/README.md) cover these in depth.

---

## Working safely

The server writes to your model and changes may be irreversible.

1. **Back up first.** A language model can produce unexpected results.
2. **Work in PBIP under Git.** Files are plain text, so you get a reviewable
   diff and a revert. This is the strongest safeguard available — see
   [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md).
3. **Start small.** One measure, verify, then widen the scope.
4. **Mind what reaches the LLM provider.** Model metadata and query results
   enter the conversation and go to whichever provider your client is
   configured with.
5. **For CI, use least privilege** and a service principal — see
   [Service Principal Setup](../../Governance/ServicePrincipalSetup.md).

---

## Known limitations

- **No macOS support.** Use the hosted server.
- **Modeling operations only.** It cannot change report pages, visual
  definitions, or semantic model diagram layouts. The report layer needs
  [`pbir`](../../AgenticDevelopment/AgentSkills/pbir-cli.md) or the report
  authoring skill.
- **DAX execution caps at 100,000 rows.**
- **No tenant setting blocks it.** It connects through the XMLA endpoint, so
  blocking it means disabling the XMLA endpoint — which blocks every tool that
  depends on XMLA.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Server not in the tool list | Client not in agent mode, or Copilot's MCP setting is off | Enable **MCP servers in Copilot** in GitHub settings |
| Cannot find the model | External tools disabled, or Desktop not open | Enable the security option and restart Desktop; open the model |
| Reads work, writes fail | Build instead of Write; or read-only XMLA endpoint | Request Write; set the capacity's XMLA endpoint to Read Write |
| Server will not start on macOS | Not supported | Use the hosted server |
| Agent makes wrong changes or stalls | Model or prompt granularity | Use a deep-reasoning model; break the request into smaller steps |
| Changes are wrong and hard to undo | No version control | Work in PBIP under Git |

The repository has a dedicated
[troubleshooting guide](https://github.com/microsoft/powerbi-modeling-mcp/blob/main/TROUBLESHOOTING.md)
for startup failures and authentication setup.

---

## Uninstall

```bash
# If installed globally
npm uninstall -g @microsoft/powerbi-modeling-mcp
```

Then remove the server entry from your MCP configuration. Nothing else is
required — the server holds no persistent state of its own.

---

## Related

- [Server Guide](./ServerGuide.md) — hosted vs local, Fabric IQ, security
- [VS Code Integration](./VSCode_Integration.md)
- [Use Cases](./UseCases/README.md)
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md)
- [Environment Setup](../../Documentation/Setup/EnvironmentSetup.md)
- [Repository](https://github.com/microsoft/powerbi-modeling-mcp) ·
  [npm package](https://www.npmjs.com/package/@microsoft/powerbi-modeling-mcp)
