---
title: MCP Configuration Examples
tags: [agentic, mcp, ai, automation]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# MCP Configuration Examples

Working configurations for the Power BI Authoring MCP server across clients.

> These were rewritten against the current server. The previous revision
> described a `--config` flag, a `--model` argument, an `mcp-config.json`
> schema, and a `port` setting — none of which exist.

---

## The shape of an MCP server entry

```json
{
  "<server-name>": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start"]
  }
}
```

| Key | Meaning |
|---|---|
| `type` | `stdio` for local, `http` for hosted |
| `command` | Executable to run |
| `args` | Arguments passed to it |
| `env` | Environment variables |

**The root key depends on the client.** This is the single most common
configuration mistake:

| Client | Root key |
|---|---|
| VS Code (`mcp.json`, settings) | `mcp.servers` in settings; `servers` in `mcp.json` |
| Claude Desktop | `mcpServers` |
| Copilot CLI, most others | `servers` or `mcpServers` |

---

## The EULA gate

The server blocks all other tool calls until its EULA is accepted. In an
interactive session the agent can call `accept_eula` once you authorise it, and
the acceptance is stored locally.

For unattended runs, accept it explicitly — after reading it:

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

If the server starts but exposes no tools, this is usually why.

---

## Read-only exploration

The safest way to let an agent look at a production model:

```json
{
  "servers": {
    "powerbi-authoring-readonly": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start", "--readonly"]
    }
  }
}
```

Write operations are blocked entirely. Use this for audits, documentation
generation, and anything where you want answers but not changes.

---

## Service principal (CI)

For pipelines, use a service principal rather than an interactive session. See
[Service Principal Setup](../../Governance/ServicePrincipalSetup.md) for
creating one and granting the right permissions.

```json
{
  "servers": {
    "powerbi-authoring-ci": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@microsoft/powerbi-modeling-mcp@0.5.0-beta.12",
        "--start",
        "--authmode=serviceprincipal"
      ],
      "env": {
        "AZURE_TENANT_ID": "<tenant-guid>",
        "AZURE_CLIENT_ID": "<app-guid>",
        "AZURE_CLIENT_SECRET": "<secret-from-your-ci-secret-store>",
        "PBI_MODELING_MCP_ACCEPT_EULA": "true"
      }
    }
  }
}
```

**Three rules for CI:**

1. **Pin the version.** `@latest` means your pipeline can change behaviour
   without a commit.
2. **Never hard-code a secret.** Read it from the CI secret store and inject it
   as an environment variable.
3. **Prefer certificate auth** where you can, over a client secret:
   `AZURE_CLIENT_CERTIFICATE_PATH` plus `AZURE_CLIENT_CERTIFICATE_PASSWORD`.

Also note the model needs **Write** permission and the capacity's XMLA endpoint
must be set to Read Write. With Build only, the agent can query but not change.

---

## Connecting to non-Power BI endpoints

To target Azure Analysis Services or SQL Server Analysis Services, set
`--compatibility Full` and allowlist the host:

```json
{
  "servers": {
    "powerbi-authoring-aas": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@microsoft/powerbi-modeling-mcp@latest",
        "--start",
        "--compatibility",
        "Full"
      ],
      "env": {
        "PBI_MODELING_MCP_ALLOWED_CONNECTION_HOSTS": "xmla.contoso.example,sqlserver_01:8373"
      }
    }
  }
}
```

Restart the server after changing the allowlist.

**Access tokens are sent to allowlisted hosts on connect.** Add only hostnames
your organisation operates. Do not add one just to clear a validation error —
the allowlist is a credential control.

---

## Hosted server

No install, no Node.js, Microsoft-managed updates:

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

Two things to know before choosing it:

- **It is stateful.** It keeps your model connection in a session and expects
  your client to return the `mcp-Session-Id` header on every request. A client
  that opens a new session per call will make the agent reconnect before every
  operation.
- **Entra OAuth only.** Some clients depend on dynamic OAuth client
  registration, which Entra does not support. Use the local server with those,
  or register an Entra app yourself.

> **Register one, not both.** Two servers mean overlapping tool sets, ambiguous
> routing, and wasted tokens on every request.

---

## Pinning versions

| Context | Recommendation |
|---|---|
| Local experimentation | `@latest` is fine |
| Shared workspace config | Pin an exact version so the team gets identical behaviour |
| CI | Pin, and update deliberately |

```json
"args": ["-y", "@microsoft/powerbi-modeling-mcp@0.5.0-beta.12", "--start"]
```

The package is pre-1.0, so breaking changes between minors are expected.

---

## VS Code specifics

In VS Code, options and environment variables can also be set in user settings.
Search `@ext:Microsoft.powerbi-modeling-mcp` in the settings editor.

If the server does not appear in the tool list, check that **MCP servers in
Copilot** is enabled in your GitHub settings. It is **off by default on
enterprise accounts** and an administrator has to enable it.

See [VS Code Integration](../../Integrations/MCP/VSCode_Integration.md) for the
full walkthrough.

---

## Verifying a configuration

```bash
copilot mcp show
```

Then, in the agent:

```text
Connect to semantic model 'SalesModel' in Fabric workspace 'SalesAnalytics'
```

```text
List the tables and measures in this model
```

A successful inventory means the server is connected and the permissions work.
Confirm write access separately before asking for a change.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Server registered, no tools | EULA not accepted | Authorise `accept_eula`, or pass `--accepteula` |
| Server not listed at all | Client not in agent mode, or Copilot MCP setting off | Enable **MCP servers in Copilot** in GitHub settings |
| `npx` not found | Node.js missing or not on PATH | Install Node.js 18+ and restart the client |
| Reads work, writes fail | Build instead of Write; or read-only XMLA endpoint | Request Write; set the capacity's XMLA endpoint to Read Write |
| Cannot connect to an AAS host | Host not allowlisted | Add it to `PBI_MODELING_MCP_ALLOWED_CONNECTION_HOSTS` and restart |
| Reconnects before every operation | Hosted server; client not returning `mcp-Session-Id` | Use a session-preserving client, or switch to local |
| Fails on macOS | Local server not supported | Use the hosted server |

---

## Related

- [Server Guide](../../Integrations/MCP/ServerGuide.md)
- [Setup Guide](../../Integrations/MCP/Setup_Guide.md)
- [PowerBI_Modeling_MCP.md](./PowerBI_Modeling_MCP.md)
- [VS Code Integration](../../Integrations/MCP/VSCode_Integration.md)
- [Service Principal Setup](../../Governance/ServicePrincipalSetup.md)
