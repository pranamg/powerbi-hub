---
title: PowerBI-Hub Roadmap
tags: [meta, documentation]
audience: [all]
difficulty: reference
last_verified: 2026-09-29
---

# PowerBI-Hub Roadmap

> **Status:** Actively maintained
> **Last reviewed:** 2026-09-29
> **Supersedes:** the December 2024 implementation plan and checklist, which
> listed most existing content as "not started" while a companion checklist
> claimed 100% complete. Both contradicted reality and were replaced.

## Where the hub stands

| Measure | State |
|---|---|
| Documents | 205 Markdown files, ~27,000 lines |
| Code assets | 14 `.dax`, 5 `.m`, 17 `.tmdl`, 8 `.ps1`, ~6,400 lines |
| Navigation | Generated [topic index](./Topic_Index.md), six [learning paths](./LearningPaths/), role-based README |
| Automated checks | Frontmatter, frontmatter values, index freshness, link resolution, Markdown lint |
| Freshness | Per-document `last_verified` plus a [What's New register](./WhatsNew/) |

## What is not yet covered

This is the working backlog. It is deliberately concrete — each item names
where the content should live and what it should contain.

### Phase 5 candidates

#### 1. Refresh the agentic pages that predate the 2026 restructure ⭐

**Why:** `AgenticDevelopment/MCPTools/` and `AgenticDevelopment/Workflows/`
(~2,500 lines) were written before Microsoft shipped first-party agent skills
and restructured MCP. They still say "Power BI Modeling MCP server" and
present a single-server model. The current picture is in
[MCP Server Guide](../Integrations/MCP/ServerGuide.md) and
[Agent Skills](../AgenticDevelopment/AgentSkills/README.md), but the older
pages contradict them.

**Scope:**

| File | Change |
|---|---|
| [MCPTools/PowerBI_Modeling_MCP.md](../AgenticDevelopment/MCPTools/PowerBI_Modeling_MCP.md) | Rename to Authoring; add hosted vs local, Fabric IQ boundary, real package name, permission matrix |
| [MCPTools/README.md](../AgenticDevelopment/MCPTools/README.md) | Re-point at Server Guide; remove the invented tool-name tables |
| [MCPTools/ConfigurationExamples.md](../AgenticDevelopment/MCPTools/ConfigurationExamples.md) | Replace with real `mcp.json` snippets matching current config keys |
| [Workflows/MCPServerWorkflow.md](../AgenticDevelopment/Workflows/MCPServerWorkflow.md) | Update prompts and flows to the Authoring server |
| [Workflows/README.md](../AgenticDevelopment/Workflows/README.md) | Add the skill-based workflow as the primary path |
| [AgentsAndSkills/*](../AgenticDevelopment/AgentsAndSkills/) | Point at the `AgentSkills` folder; it supersedes this one |

**Risk:** mechanical, low. Mostly terminology plus a genuine rewrite of the
configuration examples, which currently describe a config schema that does not
exist.

#### 2. Power BI Desktop Bridge

The reload-and-screenshot verification loop is the missing leg of every
agentic workflow in the hub, and is currently only described in passing in
[pbir-cli](../AgenticDevelopment/AgentSkills/pbir-cli.md).

Should cover: the CLI commands (open, reload, status, screenshot), when to
verify visually versus structurally, and how it closes the
MCP → edit → validate → screenshot → review loop.

#### 3. TMDL and PBIR merge-conflict resolution

The practical hard part of co-development, and entirely absent. TMDL merges on
a shared model, and PBIR merges on shared visuals, both need worked examples
of a real conflict and its resolution.

#### 4. Schema validation in CI

The [pbip plugin](../AgenticDevelopment/AgentSkills/README.md) provides PBIR,
TMDL, and binding validation hooks. This hub has no configuration for running
them, and no `microsoft/json-schemas` validation wired into
[CI](../.github/workflows/).

### Coverage gaps by area

| Area | Missing |
|---|---|
| **Optimization** | All three subfolders (Query, Memory, Performance) are 39–46 lines; no vertiPaq analyzer workflow, no partition strategy guidance |
| **Monitoring** | No capacity planning, no cost management, no workspace monitoring (new Fabric preview). Alerts/Metrics/Logs are 27–33 lines |
| **Governance** | No tenant-settings reference — the hub assumes settings exist without enumerating them. Policies, Compliance, and Audits are index pages with little behind them |
| **Data/ETL** | Python, R, and SQL subfolders are 18–23 lines |
| **Design** | Templates and Guidelines are 23–42 lines; no theme preset reference for the Fluent 2 base theme |
| **Reports/Dashboards** | No worked report template; the folders hold only index pages |
| **Scripts** | No PBIR or TMDL schema validation; PowerShell scripts are undocumented beyond one-liners |
| **Visuals** | No `.pbiviz` development guide, despite custom visual templates existing |
| **Reference** | No DAX Info functions reference; no written explanation of filter vs row context |
| **Documentation/Setup** | No first-connection walkthrough, no gateway setup guide, no mobile app coverage |

## Recently completed

| Phase | Outcome |
|---|---|
| **0 — Navigation** | Frontmatter on all documents, generated topic index, six role-based learning paths, role-based README, four repo scripts, real CI replacing a placeholder |
| **1 — Stubs** | The eight 3-line placeholders became 1,540 lines: books, other resources, YouTube channels and playlists, ETL tips, visuals tips, environment setup, installation instructions. Also migrated 28 retired `docs.microsoft.com` links |
| **2 — 2026 content** | MCP server guide (Authoring vs Fabric IQ), agent skills and marketplaces, pbir-cli, PBIR, AI readiness, What's New register. Replaced a fabricated MCP setup guide that named a non-existent package |
| **3 — Accuracy** | Removed 20 stale December 2024 date footers superseded by frontmatter, replaced the contradictory plan/checklist pair with this roadmap |

## Maintenance expectations

| Frequency | Action |
|---|---|
| Monthly | Read the Power BI feature summary; update [What's New](./WhatsNew/README.md); act on any "review" row |
| Quarterly | Walk the deprecation table; re-verify anything marked unstable |
| Semi-annually | Re-verify every document whose `last_verified` is older than six months |
| On change | Add frontmatter, run `build_index.py`, run the checks |

Agent tooling content ages fastest — the Data Goblins marketplace releases
weekly — so expect shorter review cycles there than anywhere else in the hub.

## Related

- [Topic Index](./Topic_Index.md) — every document, filterable
- [Learning Paths](./LearningPaths/) — role-based reading, each naming its gaps
- [What's New](./WhatsNew/) — the change register this backlog tracks
- [Contributing](../Contributions/CONTRIBUTING.md)
