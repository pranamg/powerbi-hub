---
title: PowerBI-Hub
tags: [meta, contributing]
audience: [all]
difficulty: reference
last_verified: 2026-09-29
---

# PowerBI-Hub

A centralized documentation and resource hub for Power BI best practices, templates, scripts, queries, visuals, and reference materials.

## Core Tasks

- Adding/editing Markdown documentation
- Creating DAX measures and Power Query functions
- Adding templates for reports and dashboards
- Updating reference materials and tips

## Project Layout

Top-level folders, in rough order of importance:

├── AgenticDevelopment/ → AI-assisted semantic model development (hooks, agents, MCP, workflows, custom commands)
├── Data/               → Data sources, models, ETL scripts, datasets, constants
├── Scripts/            → PowerShell, Python, C#, TMDL, Azure Automation, Jupyter
├── Queries/            → DAX measures, calculated columns, Power Query functions
├── Visuals/            → Custom visuals, R/Python visuals, layouts
├── Design/             → Themes, guidelines, templates, atomic elements, background images
├── Reports/            → Example reports and report templates
├── Dashboards/         → Example dashboards and dashboard templates
├── Deployment/         → Pipelines (GitHub Actions, Azure Pipelines), environments, configurations
├── Integrations/       → Fabric, Power Apps, Power Automate, Azure services, MCP
├── Monitoring/         → Alerts, logs, metrics
├── Optimization/       → Performance tuning, query, memory, composite models
├── Collaboration/      → Workspaces, permissions, comments
├── Governance/         → Policies, compliance, audits, RLS, naming conventions
├── Documentation/      → Setup guides, architecture diagrams, design documents, user guides
├── References/         → Books, articles, blogs, YouTube, GitHub repos
├── TipsAndTricks/      → DAX, Power Query, ETL, Performance, Visuals tips
├── PromptLibrary/      → AI prompts for DAX, Power Query, ETL, Visuals, MCP
├── Contributions/      → CONTRIBUTING.md, CodeOfConduct.md
└── .github/            → Issue and PR templates, CI workflows, repo scripts

Keep this list in sync with the actual folder tree when adding or removing
top-level folders.

## Required: Frontmatter on every Markdown file

Every `.md` file must begin with a frontmatter block. The topic index and the
CI freshness check are both generated from these values, so a file without
them is invisible to navigation.

```yaml
---
title: Human readable title
tags: [dax, performance]
audience: [developer, model-author]
difficulty: intermediate
last_verified: 2026-09-29
---
```

- `title` — matches the file's own H1 heading.
- `tags` — from the controlled vocabulary in `.github/scripts/check_frontmatter.py`.
- `audience` — one or more of `all`, `report-author`, `model-author`,
  `developer`, `bi-admin`.
- `difficulty` — `beginner`, `intermediate`, `advanced`, or `reference`.
- `last_verified` — the date the content was last checked against current
  Microsoft guidance. Update this when you re-verify a document.

The only exceptions are the two GitHub issue templates in
`.github/ISSUE_TEMPLATE/`, which use GitHub's own frontmatter schema.

## Repo Scripts

Run these from the repository root after adding or re-tagging content:

| Script | Purpose |
|--------|---------|
| `python .github/scripts/add_frontmatter.py` | Add frontmatter to new files (idempotent) |
| `python .github/scripts/build_index.py` | Regenerate `Documentation/Topic_Index.md` |
| `python .github/scripts/build_index.py --check` | Fail if the index is stale |
| `python .github/scripts/check_frontmatter.py` | Validate frontmatter values |
| `python .github/scripts/check_links.py` | Validate relative links |

`Documentation/Topic_Index.md` is generated — do not edit it by hand.

## Conventions & Patterns

- Markdown style: `#` for main headings, `##` for subheadings
- Code blocks with triple backticks and language identifiers
- Clear, descriptive file/folder naming
- Each subfolder should have a README.md
- Link only to documents that exist. Where coverage is genuinely missing, add
  a **Known gaps** section naming the omission rather than linking to nothing
  — the learning paths in `Documentation/LearningPaths/` model this.

## Scope

The hub targets **Power BI developers and semantic model authors**. Fabric
topics are in scope only where Power BI depends on them (Direct Lake, Lakehouse,
OneLake, Mirrored databases). Data engineering, Spark, and Purview are out of
scope.

## Git Workflow

- Branch naming: `feature/<slug>` or `fix/<slug>`
- Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat: Add custom DAX measures for sales analysis`
