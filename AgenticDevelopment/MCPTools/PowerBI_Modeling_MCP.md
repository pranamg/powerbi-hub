---
title: "Power BI Authoring MCP Server"
tags: [agentic, mcp, ai]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Power BI Authoring MCP Server

The Microsoft server that gives an AI agent the tools to read and write Power BI
semantic models.

> **Renamed.** This was the "Power BI Modeling MCP server". It is now the
> **Authoring** server, and it has two deployment options. The npm package
> retains the old name (`@microsoft/powerbi-modeling-mcp`) because the registry
> entry predates the rename.
>
> For hosted vs local, the Fabric IQ consumption boundary, and permissions,
> see [Server Guide](../../Integrations/MCP/ServerGuide.md). This page is the
> reference for the server itself.

---

## What it does

| Capability | Notes |
|---|---|
| Author models in natural language | Tables, columns, measures, relationships, hierarchies, calculation groups, perspectives, partitions, security roles |
| Bulk operations | Renames, refactors, translations, security rules — hundreds of objects, with transaction support |
| Apply modeling best practices | Evaluate a model and implement the fixes |
| Pair with agent skills | Tools are the *what*; skills are the *how* |
| Agentic development workflows | Works with TMDL and PBIP files, so changes flow through source control |
| Write and validate DAX | Execute queries to test measures and explore data |

It performs **modeling operations only**. It cannot change report pages, visual
definitions, or semantic model diagram layouts — see
[pbir-cli](../AgentSkills/pbir-cli.md) for the report layer.

---

## Tools

The server exposes tools **grouped by object type**. You do not normally call
these by name; the agent selects them. To see what is available in your
session, ask:

```text
Tell me with some examples what I can do with the Power BI Authoring MCP server
```

| Group | Covers |
|---|---|
| `connection_operations` | Connect to Power BI Desktop or Fabric workspaces |
| `database_operations` | Connect, create, update, list; import/export TMDL folders; deploy |
| `transaction_operations` | Begin, commit, rollback, status |
| `model_operations` | Get, create, update, refresh, stats, rename |
| `table_operations` | Create, update, delete, get, list, refresh, rename |
| `column_operations` | Create, update, delete, get, list, rename |
| `measure_operations` | Create, update, delete, get, list, rename, move between tables |
| `relationship_operations` | Create, update, delete, activate/deactivate, find |
| `dax_query_operations` | Execute and validate DAX against the model |
| `trace_operations` | Capture and analyse Analysis Services events |
| `partition_operations` | Create, update, delete, refresh specific partitions |
| `user_hierarchy_operations` | Create, update, delete levels, reorder |
| `calculation_group_operations` | Calculation groups and items |
| `security_role_operations` | Security roles and RLS table permissions |
| `perspective_operations` | Filtered views of the model for different audiences |
| `named_expression_operations` | Named expressions and Power Query parameters |
| `function_operations` | DAX user-defined functions |
| `culture_operations` | Cultures for multi-language support |
| `object_translation_operations` | Translations per culture |
| `calendar_operations` | Calendar objects and time intelligence column groups |
| `query_group_operations` | Query groups for Power Query expressions |

---

## Built-in prompts

Available via `/` in VS Code.

| Prompt | Purpose |
|---|---|
| `CreateDAXQuery` | Builds a query from a natural-language question, attaching DAX context |
| `RunDAXQueryWithMetrics` | Runs the query, optionally clearing cache, returning metrics only |
| `AnalyzeDAXQuery` | Analyses query performance with a cleared cache |
| `ConnectToPowerBIDesktop` | Finds and connects to the Desktop instance matching a filename |
| `ConnectToFabric` | Connects to a semantic model in a Fabric workspace |
| `ConnectToPBIP` | Loads TMDL from a Power BI Project, attaching PBIP context |

---

## Install

Requires **Node.js 18+**. See
[Setup Guide](../../Integrations/MCP/Setup_Guide.md) for the full walkthrough.

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

### Accept the EULA

The server is under a dedicated
[EULA](https://github.com/microsoft/powerbi-modeling-mcp/blob/main/EULA.txt)
and **blocks all other tool calls until it is accepted**. In an interactive
session the agent can call `accept_eula` on your behalf once you authorise it,
and the acceptance is stored locally so you are not asked again.

For unattended execution, accept it explicitly — only after you have read it:

```json
{
  "servers": {
    "powerbi-authoring-local": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start", "--accepteula"],
      "env": { "PBI_MODELING_MCP_ACCEPT_EULA": "true" }
    }
  }
}
```

If the tools do not appear and you cannot find an EULA prompt, this is why.

---

## Settings

### Command-line options

| Option | Default | Purpose |
|---|---|---|
| `--start` | — | Required for MCP client registration |
| `--readwrite` | on | Write operations enabled, with a confirmation prompt once per database |
| `--readonly` | off | Safe mode; prevents all writes |
| `--compatibility` | `PowerBI` | Set to `Full` to target Azure Analysis Services databases |
| `--authmode` | `interactive` | Or `serviceprincipal` |
| `--accepteula` | off | Accept the EULA for unattended runs |

`--readonly` is worth knowing: it is the cheapest way to let an agent explore a
production model without any risk of change.

### Environment variables

| Variable | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | Service principal app ID (`--authmode=serviceprincipal`) |
| `AZURE_TENANT_ID` | Tenant ID, for service principal or forcing a tenant interactively |
| `AZURE_CLIENT_SECRET` | Client secret auth |
| `AZURE_CLIENT_CERTIFICATE_PATH` | PFX/PEM certificate instead of a secret |
| `AZURE_CLIENT_CERTIFICATE_PASSWORD` | Password for that certificate |
| `PBI_MODELING_MCP_ACCEPT_EULA` | `true` to accept the EULA unattended |
| `PBI_MODELING_MCP_ALLOWED_CONNECTION_HOSTS` | Comma-separated allowlist of trusted XMLA hostnames |

### The connection host allowlist

To connect to a non-Power BI endpoint — Azure Analysis Services, for example —
its hostname must be in `PBI_MODELING_MCP_ALLOWED_CONNECTION_HOSTS`:

```json
{
  "env": {
    "PBI_MODELING_MCP_ALLOWED_CONNECTION_HOSTS": "xmla.contoso.example,sqlserver_01:8373"
  }
}
```

Restart the server after changing it.

**Access tokens are sent to these hosts on connect.** Only add hostnames your
organisation operates and trusts; do not add one merely to clear a validation
error. The allowlist is a credential control, not a convenience.

In VS Code, set options and variables in user settings by searching
`@ext:Microsoft.powerbi-modeling-mcp`.

---

## Connect to a model

```text
Connect to semantic model 'SalesModel' in Fabric workspace 'SalesAnalytics'
```

```text
Connect to 'AdventureWorks' in Power BI Desktop
```

```text
Open semantic model from PBIP folder './MyModel.SemanticModel/definition'
```

Verify with a read-only request before asking for a change:

```text
List the tables and measures in this model
```

---

## Example scenarios

| Scenario | Prompt |
|---|---|
| Naming conventions | `Analyze the naming convention of the 'Sales' table and apply the same pattern across the entire model.` |
| Documentation | `Add descriptions to all measures, columns, and tables that explain their purpose and the logic behind the DAX code in plain business terms.` |
| Translation | `Generate a French translation for my model including tables, columns and measures.` |
| Refactor to calculation groups | `Refactor measures 'Sales Amount 12M Avg' and 'Sales Amount 6M Avg' into a calculation group and include new variants: 24M and 3M.` |
| Parameterise sources | `Analyze the Power Query code for all tables, identify the data source configuration, and create semantic model parameters to enable easy switching of the data source location.` |
| Benchmark models | `Connect to semantic model 'V1' and 'V2', and benchmark the following DAX query against both.` |
| Document the model | `Generate a Markdown document (.md) providing complete documentation, with a mermaid diagram of table relationships, each measure with its DAX and business logic, RLS filters, and the data sources inferred from the Power Query code.` |

That last one is worth knowing: it produces genuinely useful model
documentation. See
[Documentation Generation](../../Integrations/MCP/UseCases/DocumentationGeneration.md).

---

## Security and privacy

The server runs locally and uses your existing credentials. **It does not
bypass Power BI security.** But:

> AI assistance does not expand data access — it may **transmit** accessed
> data. Metadata, schemas, and query results go to the MCP client and may be
> forwarded to the configured LLM provider as conversation context.

Govern that through your organisation's AI data-handling policy and the
provider's terms, not through Power BI controls alone. Tokens are handled
through the official Azure Identity SDK; the server does not store them.

The server itself collects telemetry, which Microsoft may use to improve the
service. See the [repository](https://github.com/microsoft/powerbi-modeling-mcp)
for the full data collection notice.

**Permissions and risk.** MCP clients act with the signed-in user's Fabric
RBAC permissions. An autonomous or misconfigured client may perform destructive
actions, and the MCP specification has no standardised flag for blocking them.
Apply least privilege, and use `--readonly` where you only need exploration.

---

## Limitations

- Modeling operations only — not report pages, visuals, or diagram layouts
- **Write** permission required; with Build you can query but not change
- DAX execution caps at 100,000 rows
- Local server does not support macOS
- Follows the same rules and behaviours as External Tools modeling operations
- No tenant setting blocks it specifically — it connects via the XMLA endpoint,
  so blocking it means disabling the XMLA endpoint, which blocks every tool
  that relies on XMLA

---

## Related

- [Server Guide](../../Integrations/MCP/ServerGuide.md) — hosted vs local, Fabric IQ
- [Setup Guide](../../Integrations/MCP/Setup_Guide.md)
- [Agent Skills](../AgentSkills/README.md) — the plugin that bundles this server
- [Use Cases](../../Integrations/MCP/UseCases/README.md)
- [Repository](https://github.com/microsoft/powerbi-modeling-mcp) ·
  [npm](https://www.npmjs.com/package/@microsoft/powerbi-modeling-mcp)
