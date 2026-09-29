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
| Documents | 206 Markdown files, ~31,000 lines |
| Code assets | 14 `.dax`, 5 `.m`, 17 `.tmdl`, 8 `.ps1`, ~6,400 lines |
| Navigation | Generated [topic index](./Topic_Index.md), six [learning paths](./LearningPaths/), role-based README |
| Automated checks | Frontmatter, frontmatter values, index freshness, relative links, asset structure, external links, Markdown lint |
| Freshness | Per-document `last_verified` plus a [What's New register](./WhatsNew/) |

## What is not yet covered

This is the working backlog. It is deliberately concrete — each item names
where the content should live and what it should contain.

### Phase 5 candidates

#### 1. Power BI Desktop Bridge

The reload-and-screenshot verification loop is the missing leg of every
agentic workflow in the hub, and is currently only described in passing in
[pbir-cli](../AgenticDevelopment/AgentSkills/pbir-cli.md).

Should cover: the CLI commands (open, reload, status, screenshot), when to
verify visually versus structurally, and how it closes the
MCP → edit → validate → screenshot → review loop.

#### 2. TMDL and PBIR merge-conflict resolution

The practical hard part of co-development, and entirely absent. TMDL merges on
a shared model, and PBIR merges on shared visuals, both need worked examples
of a real conflict and its resolution.

#### 3. Schema validation in CI

The [pbip plugin](../AgenticDevelopment/AgentSkills/README.md) provides PBIR,
TMDL, and binding validation hooks. `check_assets.py` now covers JSON parsing
and TMDL declarations, but no validation against the published
`microsoft/json-schemas` is wired into [CI](../.github/workflows/).

#### 4. Report and dashboard templates

`Reports/` and `Dashboards/` hold only index pages. A worked report template —
a sales performance report, a finance pack — with the measures and pages
pre-wired would be more useful than any amount of additional prose.

#### 5. Pagination and paginated reports (RDL)

Referenced in the learning paths as a known gap. No coverage of Report
Builder, RDL structure, or the `@microsoft/powerbi-reporting` skills.

#### 6. Remaining thin areas

| Area | Current state | Missing |
|---|---|---|
| `Data/ETL/{Python,R,SQL}` | 18–23 lines | Real per-tool transformation patterns |
| `Design/{Templates,Guidelines}` | 23–42 lines | Theme presets for the Fluent 2 base theme; no `pbiviz` development guide |
| `Monitoring/{Alerts,Logs}` | index-level | Alert definitions, log analytics setup, workspace monitoring (new Fabric preview) |
| `Visuals/` | no `pbiviz` guide | Custom visual development, certification, AppSource |

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
| **3 — Accuracy** | Removed 20 stale December 2024 date footers superseded by frontmatter; corrected TMDL View and Direct Lake status; replaced the contradictory plan/checklist pair with this roadmap |
| **4 — CI** | Asset validation for DAX/M/TMDL/PowerShell/Python/JSON, and external link checking on a schedule. The first link run found 47 dead URLs, all now resolved |
| **5 — Depth** | Refreshed the agentic pages that predated the 2026 MCP restructure; added capacity planning, VertiPaq Analyzer diagnosis, and a tenant settings reference |

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
