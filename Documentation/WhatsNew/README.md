---
title: "What's New"
tags: [meta, documentation]
audience: [all]
difficulty: reference
last_verified: 2026-09-29
---

# What's New

A dated register of Power BI changes that affect the guidance in this hub, and
a list of things being withdrawn.

**Why this exists:** every document here carries a `last_verified` date, but
that only tells you *when someone last checked*, not *what changed since*. This
register answers the second question.

---

## How to use this

- **Monthly:** after the Power BI feature summary drops, add a row to
  [Recent changes](#recent-changes) and check the "Affects" column.
- **If a row says "review"**, re-read the linked document and update its
  `last_verified`.
- **Anything in [Deprecations](#deprecations) with a future date** is a
  deadline, not a curiosity.

Official sources:

| Source | URL |
|---|---|
| Power BI what's new | [learn.microsoft.com/en-us/power-bi/fundamentals/whats-new](https://learn.microsoft.com/en-us/power-bi/fundamentals/whats-new) |
| Monthly feature summary | [powerbi.microsoft.com/blog](https://powerbi.microsoft.com/en-us/blog) |
| Fabric what's new | [learn.microsoft.com/en-us/fabric/fundamentals/whats-new](https://learn.microsoft.com/en-us/fabric/fundamentals/whats-new) |
| Fabric roadmap | [roadmap.fabric.microsoft.com](https://roadmap.fabric.microsoft.com/) |
| Desktop changelog | In-app: Help → About, and the release notes page |

---

## Recent changes

Findings from a review on **2026-09-29**. Items marked **review** mean a
document in this hub may need updating.

### Agentic development and MCP

| Date | Change | Impact | Hub status |
|---|---|---|---|
| 2026-09 | The "Power BI Modeling MCP server" is now the **Power BI Authoring MCP server**. Local is **GA**; a new **hosted** option is in preview at `api.fabric.microsoft.com/v1/mcp/powerbi/authoring` | **review** | Covered in [MCP Server Guide](../../Integrations/MCP/ServerGuide.md) |
| 2026-09 | **Fabric IQ** becomes the supported consumption path. Microsoft states the Authoring server should **not** be used for consumption | **review** | Covered in [Server Guide](../../Integrations/MCP/ServerGuide.md) |
| 2026-09 | The earlier "Power BI MCP server (remote)" is now the **Consumption** server, documented for existing integrations only | Old tutorials are wrong | Documented as legacy in [Server Guide](../../Integrations/MCP/ServerGuide.md) |
| 2026-08 | Microsoft ships first-party **agent skills** (`semantic-model-authoring`, `power-bi-report-authoring`, planner, design) in a `powerbi-authoring` plugin | New content | Covered in [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) |
| 2026 | `pbir-cli` matures to a full report automation CLI with validate/backup/restore/publish. **Still beta** | New content | Covered in [pbir-cli](../../AgenticDevelopment/AgentSkills/pbir-cli.md) |
| 2026 | Data Goblins marketplace moves to **weekly releases**, with a flagged breaking transition in versions 26.26–26.38 | Pinning advice | Warning recorded in [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) |

### Reports and visuals

| Date | Change | Impact | Hub status |
|---|---|---|---|
| 2026-08 | **Modern visual defaults** (Fluent 2 base theme) and customise-theme panes go **GA**. New reports start from the updated base theme | **review** | Partly in [Visuals Tips](../../TipsAndTricks/Visuals.md); themes folder may need a new preset |
| 2026-08 | **PBIR becomes the default report format** — **rollout paused**. Remains opt-in | Existing advice asserting default is wrong | Corrected in [PBIR](../../Documentation/UserGuides/PBIR.md) |
| 2026-08 | **Custom totals** let a visual override aggregation without changing the measure | New | Not covered |
| 2026-08 | Table and matrix: fixed and default column widths (**GA**), larger totals control (**GA**) | Minor | Not covered |
| 2026-05 | **Card with States** becomes the successor card visual; the legacy card is retired | **review** | [Cards](../../Design/AtomicElements/Cards/README.md) may need updating |
| 2026-05 | **Version History in Power BI Desktop** | New | Not covered |
| 2026-05 | New **Get Data experience** in Desktop (preview) | Minor | Not covered |
| 2026-03 | **Direct Lake on OneLake** goes GA, with OneLake security compatibility and more modeling features | **review** | [Direct Lake](../../Integrations/Fabric/DirectLake.md) — check for preview-era caveats |
| 2026-03 | **Power BI data writeback** to Fabric SQL databases, warehouses, and lakehouse files | New | Not covered |
| 2026 | TMDL view available **in the web** (preview) | Minor | Not covered |

### Copilot and AI

| Date | Change | Impact | Hub status |
|---|---|---|---|
| 2026 | *"Prepped for AI"* renamed to **"Approved for Copilot"** | Naming | Corrected in [Prep for AI](../../Data/AIReadiness/PrepForAI.md) |
| 2026 | **AI instructions** gain prompt-engineering guidance and per-model authoring in the service | **review** | Covered in [Prep for AI](../../Data/AIReadiness/PrepForAI.md) |
| 2026 | **Copilot indexing** and per-machine **Local Desktop Indexing** settings | Minor | Covered in [Prep for AI](../../Data/AIReadiness/PrepForAI.md) |
| 2026 | **Fabric IQ** preview workload unifies business semantics for agents | New | Consumption guidance only, per scope |
| 2026-06 | Microsoft publishes semantic model best practices for **data agents** — the model is the variable, not the prompt | **review** | Order of work in [Prep for AI](../../Data/AIReadiness/PrepForAI.md) |

### Data and connectivity

| Date | Change | Impact | Hub status |
|---|---|---|---|
| 2026-08 | **Mirroring for Google BigQuery** goes GA — near-real-time replication into OneLake, queryable via Direct Lake | New | Not covered |
| 2026-07 | **Lakehouse git integration** and deployment pipelines formalise lakehouse versioning | New | Partly in [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md) |
| 2026 | **Evaluate Power Query programmatically** (preview) — a REST API for running M scripts | New | Not covered |
| 2026 | **SQL analytics endpoint metadata sync** option (preview), faster, with time travel | New | Not covered |
| 2026 | **Workspace monitoring** (preview) — Fabric database collecting logs and metrics per workspace | New | Potentially changes [Monitoring](../../Monitoring/README.md) |

---

## Deprecations

Deadlines rather than news. Track these.

| Deadline | Change | Action |
|---|---|---|
| **30 Oct 2026** | **PL-400** (Power Platform Developer) — last exam day | Not a hub concern, but it appears in certification material |
| **30 Nov 2026** | **MS-102** (Microsoft 365 Administrator Expert) retires | Not a hub concern |
| **30 Sep 2026** | **AZ-800 / AZ-801** (Windows Server Hybrid Administrator) retire | Not a hub concern |
| **From Oct 2026** | Power BI Desktop **versions from March 2026 or earlier** can no longer save or share files to OneDrive and SharePoint | **Update Desktop.** Users on old builds lose the ability to save there |
| Ongoing | **PBIR default-format rollout is paused** | Do not assume PBIR is the default; see [PBIR](../../Documentation/UserGuides/PBIR.md) |
| 2026-08 | **Card with States Legacy** no longer receives updates or support | Migrate to Card with States |
| 2026-08 | **Fabric Apps** consumers need only **Read** on the underlying semantic model (app authors still need Build) | **review** if this hub documents Fabric Apps permissions — it does not currently |

Microsoft retired a large batch of exams during 2026 (MS-900, DP-100, AI-102,
AI-900, PL-500, PL-600, AZ-204, AZ-500, PL-200). These do not appear in hub
content. See
[Other Resources](../../References/OtherResources.md) for the current table.

---

## Refresh checklist

When doing a periodic refresh:

1. Read the month's Power BI feature summary
2. Add rows to **Recent changes**, including the ones that do *not* affect the
   hub — a "no impact" note is useful negative evidence
3. For every **review** row, open the linked document and either update it or
   refresh its `last_verified`
4. Check **Deprecations** for anything whose deadline has passed, and remove it
5. Bump this page's own `last_verified`
6. Re-run the repo checks: `python .github/scripts/build_index.py && python .github/scripts/check_links.py`

### Suggested cadence

| Cadence | Activity |
|---|---|
| Monthly | Feature summary → update Recent changes |
| Quarterly | Walk the Deprecations table; re-verify anything marked unstable |
| Semi-annually | Re-verify every `last_verified` older than six months |

---

## Content most likely to go stale

Not everything ages equally. In rough order of volatility:

1. **Agent tooling** — plugin inventories, install commands, MCP config. The
   Data Goblins marketplace alone releases weekly.
2. **AI/Copilot configuration** — feature names have already changed once.
3. **Report format** — PBIR is mid-transition with a paused rollout.
4. **Visual features** — the visual layer changes monthly.
5. **DAX and TMDL** — slow-moving, but new functions arrive.
6. **Governance and security guidance** — slowest, and most worth getting right.

Set a shorter refresh expectation for the top of that list.

---

## Related

- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — fastest-moving content here
- [MCP Server Guide](../../Integrations/MCP/ServerGuide.md)
- [PBIR](../../Documentation/UserGuides/PBIR.md)
- [Prep for AI](../../Data/AIReadiness/PrepForAI.md)
- [Topic Index](../Topic_Index.md)
