---
title: Environment Setup
tags: [setup, tooling]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# Environment Setup

A working Power BI development environment, in the order that avoids
rework. For per-tool install commands, see
[Installation Instructions](./InstallationInstructions.md).

## What you actually need

Start from your role and stop when the tools you need are installed.

| If you are a… | Minimum viable setup |
|---------------|----------------------|
| Report author / analyst | Power BI Desktop. Nothing else |
| Semantic model author | Desktop, Git, VS Code |
| Working in source control | The above, plus Node.js (for MCP) and `pbir-tools` (for PBIP) |
| Performance work | The above, plus DAX Studio and Tabular Editor |
| Doing CI/CD | PowerShell 7, Azure CLI, `pbi-tools` Core, a service principal |
| Doing agentic development | The above, plus Node.js, the MCP server, and agent skills |

Install more only when a task calls for it. Every extra tool is another thing
to keep updated and another thing that can differ between your machine and a
CI agent's.

---

## Recommended order

### 1. Power BI Desktop

The installer version, not the Store version — several automation tools
cannot locate or launch the Store build.

```powershell
& "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
```

### 2. Git, with long paths enabled

Do the long-paths step now rather than after your first PBIP clone fails.

```powershell
git config --system core.longpaths true
```

Verify:

```powershell
git --version
git config --system core.longpaths    # expect: true
```

> If cloning still fails with `Filename too long`, Windows itself needs long
> path support enabled at the OS level (a registry change plus a reboot), not
> just in git. TMDL file paths exceed 260 characters readily.

### 3. Visual Studio Code

User Installer — no admin rights needed. Add the GitHub Copilot extension if
you plan to use MCP or agent skills; VS Code is an MCP host and Copilot is the
client.

```powershell
code --version
```

### 4. Node.js 18 or later

Needed by the local [Power BI MCP server](../../Integrations/MCP/README.md)
and by most agent tooling.

```powershell
node --version    # v18.0.0 or higher
```

### 5. PowerShell 7

Windows ships 5.1. The scripts in this repo target 7.

```powershell
winget install Microsoft.PowerShell
pwsh --version    # 7.x
```

### 6. The modeling tools

```powershell
# Tabular Editor 3 — MSI, requires .NET 8 Desktop Runtime
winget install TabularEditor.TabularEditor

# Verify the tools this repo's examples assume
pbi-tools info
```

Install DAX Studio from its portable ZIP if you do performance work — see
[Installation Instructions](./InstallationInstructions.md) for the silent
install commands.

### 7. Optional: report automation and AI tooling

Only if your work touches PBIR reports or agentic development.

```bash
uv tool install pbir-cli
pbir --version
```

Then install an agent plugin — Microsoft's or the Data Goblins marketplace:

```bash
# Microsoft first-party
copilot plugin marketplace add microsoft/skills-for-fabric
copilot plugin install powerbi-authoring@fabric-collection
```

Full inventory and safety notes in
[Agentic Development](../../AgenticDevelopment/README.md).

---

## Platform support

Power BI itself is cross-platform; most of its tooling is not. This is the
single most common surprise for new users.

| Tool | Windows | macOS | Linux |
|------|:-------:|:-----:|:-----:|
| Power BI Desktop | ✅ | ✅ | — (Windows VM) |
| Git, VS Code, Node, PowerShell 7 | ✅ | ✅ | ✅ |
| DAX Studio | ✅ | — | — |
| Tabular Editor 3 | ✅ | — | — |
| Tabular Editor 2 CLI | ✅ | — | — |
| Tabular Editor 3 CLI (`te`, preview) | ✅ | ✅ | ✅ |
| pbi-tools Desktop | ✅ | — | — |
| pbi-tools Core | ✅ | ✅ | ✅ |
| Power BI Authoring MCP (local) | ✅ | **—** | ✅ |
| Power BI Authoring MCP (hosted) | ✅ | ✅ | ✅ |
| `pbir-cli` | ✅ | ✅ | ✅ |
| Azure CLI | ✅ | ✅ | ✅ |

**On macOS:** the local MCP server is not supported. Use the hosted server, or
run Power BI Desktop in a Windows VM. Tabular Editor 3, DAX Studio, and
`pbi-tools` Desktop also require Windows.

---

## Authenticate

Most tooling acts with your existing identity — it does not bypass Power BI
security.

| Context | How to authenticate |
|---------|---------------------|
| Power BI Desktop | Sign in interactively |
| Fabric workspace via MCP | Sign in when the agent first calls a tool (Entra ID) |
| CI/CD | Service principal — see [Service Principal Setup](../../Governance/ServicePrincipalSetup.md) |
| Azure CLI | `az login` |

```bash
az login
az account show
```

### Permissions that matter

| Task | Required permission |
|------|--------------------|
| Query a semantic model | Build |
| Change a semantic model | **Write** |
| External XMLA tools against a Fabric model | Capacity's XMLA endpoint set to **Read Write** |
| Hosted MCP server | Tenant setting *Users can use the Power BI Model Context Protocol server endpoint* |

If an agent can read your model but every change fails, you have Build but not
Write — or the capacity's XMLA endpoint is read-only.

---

## Project layout

A sensible local structure that keeps source-controlled and unsaved work apart:

```
C:\BI\
├── repos\          # Git clones — your actual work
│   ├── sales-model\
│   └── finance-report\
├── sandbox\        # Experiments, samples, throwaway models
│   └── AdventureWorks.pbix
└── tools\          # pbi-tools, extracted installers
    └── pbi-tools\
```

Keep `sandbox\` out of Git. A repository of half-finished experiments is
harder to work in than no repository.

### Enable long paths before your first PBIP clone

TMDL generates deeply nested file paths. On Windows, without long-path support
enabled, `git clone` fails with `Filename too long` on a project that is
perfectly valid.

```powershell
git config --system core.longpaths true
```

---

## Verify the environment

```powershell
# Core
git --version
node --version          # v18.0.0+
pwsh --version          # 7.x
code --version

# Modeling
pbi-tools info          # confirms it can see Power BI Desktop

# Optional
pbir --version
az version
```

Then a functional check: open a sample model, run it in
[DAX Query View](../../Documentation/UserGuides/DAXQueryView.md), and confirm
[DAX Query View](../../Documentation/UserGuides/DAXQueryView.md) shows a
storage-engine query rather than a formula-engine scan.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `PBIDesktop.exe` not found | Store version installed | Install the installer version, or set `PBITOOLS_PbiInstallDir` |
| `Filename too long` on clone | Windows MAX_PATH | `git config --system core.longpaths true`; if that fails, the OS-level registry change |
| `pbi-tools launch-pbi` does nothing | Store version of Desktop | Use the installer version |
| Tabular Editor 3 will not start | .NET 8 Desktop Runtime missing | Install the runtime |
| Tabular Editor cannot reach a Fabric model | XMLA endpoint read-only | Set the capacity's XMLA endpoint to Read Write |
| Agent can read but not change a model | Build instead of Write permission | Request Write |
| Agent reconnects before every operation | Client is not returning `mcp-Session-Id` (hosted server) | Use a client that preserves the session, or switch to the local server |
| Local MCP server will not start on macOS | Not supported | Use the hosted server |
| `pbir` not found after `uv tool install` | PATH not refreshed | Open a new terminal |
| Script fails with PS syntax errors | Windows PowerShell 5.1 | Run with `pwsh`, not `powershell` |
| Python or R visual not available | Not enabled in the service | Enable the visual in the Power BI service first |

---

## Keeping the environment current

| Item | Cadence |
|------|---------|
| Power BI Desktop | Monthly — it ships a new version monthly and this is the biggest source of "works on my machine" |
| Tabular Editor 3 | As released |
| DAX Studio | As released |
| pbi-tools | As released (still 1.x) |
| Community agent plugins | **Weekly** — see the cadence warning in [Agentic Development](../../AgenticDevelopment/README.md) |

Pin versions in CI. Do not let a CI agent install "latest" of anything without
a lock, or your pipeline will break without a commit that explains it.

---

## Related

- [Installation Instructions](./InstallationInstructions.md) — per-tool detail
- [Scripts](../../Scripts/README.md) — automation in this repo
- [MCP](../../Integrations/MCP/README.md)
- [Agentic Development](../../AgenticDevelopment/README.md)
- [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md)
- [Service Principal Setup](../../Governance/ServicePrincipalSetup.md)
