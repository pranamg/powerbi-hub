---
title: Installation Instructions
tags: [setup, tooling]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# Installation Instructions

Tool-by-tool install, verify, and update. For the recommended *order* and a
new-machine walkthrough, see [Environment Setup](./EnvironmentSetup.md).

**Every tool here is optional.** None is required to build a report. Pick the
ones that match the work you do — see the "Who needs this" column.

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Works on Windows |
| 🍎 | macOS supported |
| 🐧 | Linux supported |
| — | Not supported |

---

## Tier 1 — Required

### Power BI Desktop

| | |
|---|---|
| Platforms | ✅ 🍎 (Windows on ARM via Store) |
| Cost | Free |
| Download | [powerbi.microsoft.com/desktop](https://powerbi.microsoft.com/en-us/download) |

Two distributions exist and they behave differently:

| Distribution | Notes |
|--------------|-------|
| **Installer** (`.exe`/`.msi`) | Default choice. Required by pbi-tools and by automation that locates Desktop by install path |
| **Microsoft Store** | Auto-updates, but some tooling cannot find or launch it — `pbi-tools launch-pbi` explicitly does not support the Store version |

If you intend to script against Desktop, install the **installer** version.

```powershell
# Verify
& "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe" /?
```

---

## Tier 2 — Development

### Git

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Cost | Free |
| Download | [git-scm.com/downloads](https://git-scm.com/downloads) |

```bash
git --version

# On Windows, also enable long paths — TMDL paths exceed 260 characters easily
git config --system core.longpaths true
```

> The `core.longpaths` setting matters for Power BI work specifically. Without
> it, `git clone` of a PBIP project can fail with `Filename too long` on
> Windows. See the Data Goblins marketplace notes for the OS-level companion
> change.

### Visual Studio Code

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Cost | Free |
| Download | [code.visualstudio.com/download](https://code.visualstudio.com/download) |

Use the **User Installer** — it does not require admin rights.

Recommended extensions:

| Extension | Why |
|-----------|-----|
| GitHub Copilot | Agent mode and MCP client |
| DAX Studio extension | Query plans without leaving VS Code |
| Markdown All in One | Editing this hub's docs |

VS Code is also an MCP client, which makes it the most direct way to use the
[Power BI MCP server](../../Integrations/MCP/README.md).

### Node.js

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Minimum | **18+** for the Power BI MCP server |
| Download | [nodejs.org](https://nodejs.org/) |

```bash
node --version   # v18.0.0 or higher
npm --version
npx --version
```

Required for the local [Power BI Authoring MCP server](../../Integrations/MCP/README.md).

---

## Tier 3 — Modeling and performance

### Tabular Editor 3

| | |
|---|---|
| Platforms | ✅ (x64 and ARM64) · ❌ macOS · ❌ Linux |
| Requires | .NET Desktop Runtime 8.0 |
| Cost | Paid, with a free 2-tab limitation |
| Download | [tabulareditor.com/downloads](https://tabulareditor.com/downloads) |

Install the **MSI 64-bit installer**. Silent install:

```powershell
msiexec /i TabularEditor.<version>.x64.Net8.msi /qn /norestart /l*v C:\Temp\TE3_install.log
```

On macOS and Linux you need the **Tabular Editor CLI** (`te`) instead, or a
VM. See below.

### Tabular Editor CLI

Two different CLIs exist, and this trips people up:

| CLI | Binary | Status | Use for |
|-----|--------|--------|---------|
| Tabular Editor **2** CLI | `TabularEditor.exe` | Stable, Windows only | CI/CD and scripted automation. Still the most widely deployed |
| Tabular Editor **3** CLI | `te` | Preview, cross-platform | Newer; no external runtime dependency (single self-contained executable) |

The two are not interchangeable — `TabularEditor.exe` is **not** Tabular
Editor 3. This hub's automation examples use `TabularEditor.exe`; see
[Tabular Editor CLI](../../AgenticDevelopment/CustomCommands/TabularEditorCLI.md).

### DAX Studio

| | |
|---|---|
| Platforms | ✅ (hosts on Power BI Desktop or SSMS) |
| Cost | Free, open source |
| Download | [daxstudio.org](https://daxstudio.org/) |

The portable ZIP will install missing prerequisites itself. This is the tool
for query plans, server timings, and measure extraction — the basis of
[Performance Tuning](../../Optimization/PerformanceTuning/README.md) and
[Query Optimization](../../Optimization/QueryOptimization/README.md).

### pbi-tools

| | |
|---|---|
| Editions | **Desktop** (Windows, needs Power BI Desktop) · **Core** (cross-platform, .NET 8) |
| Cost | Free, open source (AGPLv3) |
| Download | [github.com/pbi-tools/pbi-tools/releases](https://github.com/pbi-tools/pbi-tools/releases) |

No installer — download the ZIP, extract to e.g. `C:\Tools\pbi-tools`, and
add it to `PATH`. **Unblock the ZIP before extracting** on Windows.

```bash
pbi-tools info          # diagnostics: version, detected Desktop installs
```

Core edition for CI:

```bash
docker pull ghcr.io/pbi-tools/pbi-tools-core:latest
```

Note: `launch-pbi` does not support the Store version of Desktop.

---

## Tier 4 — Report automation and AI

### pbir-cli

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 (via Python) |
| Cost | Free, open source |
| PyPI | `pbir-cli` |
| Repo | [github.com/maxanatsko/pbir.tools](https://github.com/maxanatsko/pbir.tools) |

```bash
uv tool install pbir-cli        # recommended
# or
pip install pbir-cli
```

Verify:

```bash
pbir --version
```

> **This tool is in beta.** The authors recommend a manual backup of any report
> folder before first use, and treating bulk formatting, conversion, merge, and
> publish as higher-risk operations. See
> [Agentic Development](../../AgenticDevelopment/README.md) for the
> safety workflow.

### Power BI Authoring MCP server

| | |
|---|---|
| Platform | ✅ (local server does not support macOS) |
| Install | VS Code extension, `npx`, or standalone executable |
| Cost | Free, Microsoft |
| Repo | [github.com/microsoft/powerbi-modeling-mcp](https://github.com/microsoft/powerbi-modeling-mcp) |

Via `npx` (no install step — the package is fetched on first run):

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

> In VS Code and Visual Studio use `servers` as the root object; other clients
> use `mcpServers`.

There is also a **hosted** option requiring no install at all:

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

Pick **one**, never both — overlapping tool sets make routing ambiguous. See
[MCP Servers](../../Integrations/MCP/README.md).

### Agent skills and plugins

| Source | Install |
|--------|---------|
| Microsoft `powerbi-authoring` | `copilot plugin marketplace add microsoft/skills-for-fabric` then `copilot plugin install powerbi-authoring@fabric-collection` |
| Data Goblins marketplace | `claude plugin marketplace add data-goblin/power-bi-agentic-development`, then install named child plugins |

Details, plugin inventory, and the release-cadence warnings are in
[Agentic Development](../../AgenticDevelopment/README.md).

---

## Tier 5 — Data and scripting

### PowerShell 7

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Cost | Free |
| Install | `winget install Microsoft.PowerShell` |

Windows ships PowerShell 5.1, which lacks some features. The scripts in
[Scripts/PowerShell](../../Scripts/PowerShell/README.md) target PowerShell 7.

### Python

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Minimum | 3.10 recommended |
| Download | [python.org](https://www.python.org/downloads/) |

For Power BI, Python serves R and Python custom visuals. **Both require the
visual to be enabled in the Power BI service first** — a local setup does not
by itself make them available.

### Azure CLI

| | |
|---|---|
| Platforms | ✅ 🍎 🐧 |
| Cost | Free |
| Install | `az` (see [Microsoft docs](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)) |

```bash
az login
```

Needed for Fabric control-plane calls and service principal authentication in
CI. Pairs with [Service Principal Setup](../../Governance/ServicePrincipalSetup.md).

---

## Verifying a full install

```bash
git --version
node --version          # v18.0.0+
pwsh --version          # 7.x
python --version
code --version
pbir --version
pbi-tools info
az version
```

Plus, inside Power BI Desktop: File → Options → Preview features, and confirm
TMDL view and PBIR are available if you intend to use them.

## Known gaps

- No **paginated report** tooling (Report Builder, RDL validation) is covered.
- No **Azure Data Studio** guidance; it is retired in favour of the Fabric
  extension for VS Code.
- No coverage of **Bravo for Power BI** or other SQLBI free tools, which are
  worth installing for model documentation and measure extraction. See
  [Other Resources](../../References/OtherResources.md).
- macOS is under-served throughout: Power BI Desktop runs on it, but Tabular
  Editor 3, DAX Studio, and the local MCP server do not.

## Related

- [Environment Setup](./EnvironmentSetup.md) — recommended install order
- [Scripts](../../Scripts/README.md) — what lives in this repo
- [MCP](../../Integrations/MCP/README.md)
- [Agentic Development](../../AgenticDevelopment/README.md)
