---
title: PowerBI-Hub
tags: [hub, navigation]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# PowerBI-Hub

A one-stop hub for Power BI development: modeling patterns, DAX and Power Query
libraries, runnable TMDL models, deployment automation, agentic-development
workflows, and curated references.

Everything here targets **Power BI developers and semantic model authors**. Where
a Fabric topic is load-bearing for Power BI — Direct Lake, Lakehouse, OneLake,
Mirrored databases — it is covered as a data source, not as a platform guide.

---

## Start here

Follow the path that matches what you are doing. Each is a sequenced reading
list drawn from this repository.

| I want to… | Go to |
|------------|-------|
| Build or fix a semantic model | [Semantic Model Author](./Documentation/LearningPaths/README.md#1-semantic-model-author) |
| Write better DAX | [DAX Practitioner](./Documentation/LearningPaths/README.md#2-dax-practitioner) |
| Put Power BI in Git / CI | [PBIP, TMDL & Git](./Documentation/LearningPaths/README.md#3-pbip-tmdl--git) |
| Prepare a model for Copilot, or work with AI agents | [AI Readiness & Agentic](./Documentation/LearningPaths/README.md#4-ai-readiness--agentic) |
| Design a report or dashboard | [Report Author](./Documentation/LearningPaths/README.md#5-report-author) |
| Own the platform: access, security, standards | [BI Admin & Governance](./Documentation/LearningPaths/README.md#6-bi-admin--governance) |
| Browse everything | [Topic Index](./Documentation/Topic_Index.md) |

**New to the hub?** Read [Copilot in Power BI](./Documentation/UserGuides/Copilot.md)
and [Semantic Model Best Practices](./Queries/DAX/BestPractices/README.md) first —
they explain the mental model everything else builds on.

---

## What's here

### Get set up

| Area | Start at |
|------|----------|
| New machine | [Environment Setup](./Documentation/Setup/EnvironmentSetup.md) — install order, platform matrix, troubleshooting |
| One tool | [Installation Instructions](./Documentation/Setup/InstallationInstructions.md) — Desktop, Git, VS Code, Node, Tabular Editor, DAX Studio, pbi-tools, pbir-cli, MCP |
| Project layout | [Fabric Git Integration](./Documentation/UserGuides/FabricGitIntegration.md) · [TMDL View](./Documentation/UserGuides/TMDLView.md) · [PBIR](./Documentation/UserGuides/PBIR.md) |
| Keeping current | [What's New](./Documentation/WhatsNew/README.md) — dated change register and deprecations |

### Modeling & data

| Area | Start at |
|------|----------|
| Date tables | [Date Table Templates](./Data/Constants/DateTable/README.md) |
| Reference models | [Data Models](./Data/DataModels/README.md) — [Model 1](./Data/DataModels/Model1/README.md), [Model 2](./Data/DataModels/Model2/README.md) |
| Data connections | [Data Sources](./Data/DataSources/README.md) |
| ETL / Power Query | [ETL](./Data/ETL/README.md), [Power Query Best Practices](./Queries/PowerQuery/BestPractices/README.md) |

### DAX & Power Query

| Area | Start at |
|------|----------|
| Measures library | [DAX Measures](./Queries/DAX/Measures/README.md) — time intelligence, rankings, conditional formatting, [window functions](./Queries/DAX/Measures/WindowFunctions.dax) |
| Calculation groups | [Calculation Groups](./Queries/DAX/CalculationGroups/README.md) |
| User-defined functions | [UDFs](./Queries/DAX/UserDefinedFunctions/README.md) |
| Power Query functions | [Custom Functions](./Queries/PowerQuery/CustomFunctions/README.md) |
| Field parameters | [Field Parameters](./Queries/DAX/FieldParameters/README.md) |
| Best practice | [DAX](./Queries/DAX/BestPractices/README.md) · [Power Query](./Queries/PowerQuery/BestPractices/README.md) |

### Performance

| Area | Start at |
|------|----------|
| Tuning | [Performance Tuning](./Optimization/PerformanceTuning/README.md) |
| Memory | [Memory Optimization](./Optimization/MemoryOptimization/README.md) |
| Query | [Query Optimization](./Optimization/QueryOptimization/README.md) |
| Composite models | [Composite Model Patterns](./Optimization/CompositeModels.md) |
| Tips | [Performance Tips](./TipsAndTricks/Performance.md) |

### Development & automation

| Area | Start at |
|------|----------|
| TMDL templates | [TMDL](./Scripts/TMDL/README.md) |
| PowerShell | [Scripts](./Scripts/PowerShell/README.md) — admin, gateway, workspace, dataset |
| C# / Tabular Editor | [C#](./Scripts/CSharp/README.md) |
| Python & REST API | [Jupyter Notebooks](./Scripts/JupyterNotebooks/README.md) |
| Quality gates | [Hooks & BPA](./AgenticDevelopment/Hooks/README.md) |

### Deployment & operations

| Area | Start at |
|------|----------|
| Pipelines | [Deployment Pipelines](./Deployment/Pipelines/README.md) |
| Environments | [Environments](./Deployment/Environments/README.md) |
| Git in the service | [Fabric Git Integration](./Documentation/UserGuides/FabricGitIntegration.md) |
| Monitoring | [Monitoring](./Monitoring/README.md) · [Capacity Planning](./Monitoring/CapacityPlanning.md) |
| Governance | [Governance](./Governance/README.md) · [Tenant Settings](./Governance/TenantSettings.md) · [RLS](./Governance/RLSPatterns.md) · [OLS](./Governance/OLSConfiguration.md) |

### Agentic development & AI

| Area | Start at |
|------|----------|
| Overview | [Agentic Development](./AgenticDevelopment/README.md) |
| **Which MCP server** | [MCP Server Guide](./Integrations/MCP/ServerGuide.md) — Authoring vs Fabric IQ, hosted vs local |
| MCP setup | [Local Setup](./Integrations/MCP/Setup_Guide.md) · [VS Code](./Integrations/MCP/VSCode_Integration.md) |
| MCP use cases | [Use Cases](./Integrations/MCP/UseCases/README.md) |
| **Agent skills & plugins** | [Agent Skills](./AgenticDevelopment/AgentSkills/README.md) — Microsoft's plugin, Data Goblins marketplace |
| **Report automation** | [pbir-cli](./AgenticDevelopment/AgentSkills/pbir-cli.md) |
| **Preparing a model for AI** | [AI Readiness](./Data/AIReadiness/README.md) |
| Workflows | [Direct TMDL](./AgenticDevelopment/Workflows/DirectMetadataModification.md) · [MCP](./AgenticDevelopment/Workflows/MCPServerWorkflow.md) · [CLI](./AgenticDevelopment/Workflows/CLIToolsWorkflow.md) |
| Custom commands | [Tabular Editor CLI](./AgenticDevelopment/CustomCommands/TabularEditorCLI.md) |
| Prompts | [Prompt Library](./PromptLibrary/README.md) |
| Copilot | [Copilot in Power BI](./Documentation/UserGuides/Copilot.md) |
| Staying current | [What's New](./Documentation/WhatsNew/README.md) |

### Visuals & design

| Area | Start at |
|------|----------|
| Guidelines | [Design Guidelines](./Design/Guidelines/README.md) |
| Themes | [Themes](./Design/Themes/README.md) — light & dark JSON included |
| Reusable pieces | [Atomic Elements](./Design/AtomicElements/README.md) |
| Custom visuals | [Custom Visuals](./Visuals/CustomVisuals/README.md) — Deneb, SVG, R, Python |

### Integrations

| Area | Start at |
|------|----------|
| Fabric | [Fabric](./Integrations/Fabric/README.md) — [Direct Lake](./Integrations/Fabric/DirectLake.md), [Lakehouse](./Integrations/Fabric/Lakehouse.md), [OneLake](./Integrations/Fabric/OneLake.md) |
| Power Apps / Automate | [Power Apps](./Integrations/PowerApps/README.md) · [Power Automate](./Integrations/PowerAutomate/README.md) |
| Azure services | [Azure Services](./Integrations/AzureServices/README.md) |

### Reference

| Area | Start at |
|------|----------|
| All topics A–Z | [Topic Index](./Documentation/Topic_Index.md) |
| Articles | [Articles](./References/Articles.md) |
| Blogs | [Blogs](./References/BlogPosts.md) |
| Repos | [GitHub Repos](./References/GitHubRepos.md) |
| Books | [Books](./References/Books.md) |
| Video | [Channels](./References/YouTube/Channels.md) · [Playlists](./References/YouTube/Playlists.md) |
| Certs, practice tools, Learn paths | [Other Resources](./References/OtherResources.md) |
| Tips | [TipsAndTricks](./TipsAndTricks/README.md) |

---

## Repository structure

```
PowerBI-Hub/
├── AgenticDevelopment/    # AI-assisted semantic model development
├── Data/                  # Data sources, models, ETL, constants
├── Scripts/               # PowerShell, C#, TMDL, Python, Jupyter
├── Queries/               # DAX measures and Power Query functions
├── Visuals/               # Custom visuals, R/Python visuals, layouts
├── Design/                # Themes, guidelines, atomic elements, images
├── Reports/               # Report examples and templates
├── Dashboards/            # Dashboard examples and templates
├── Deployment/            # Pipelines, environments, configurations
├── Integrations/          # Fabric, Power Apps, Power Automate, MCP
├── Monitoring/            # Alerts, logs, metrics
├── Optimization/          # Performance, query, memory, composite models
├── Collaboration/         # Workspaces, permissions, comments
├── Governance/            # Policies, compliance, audits, RLS
├── Documentation/         # Setup, architecture, user guides, learning paths
├── References/            # Books, articles, blogs, YouTube, GitHub repos
├── TipsAndTricks/         # DAX, Power Query, ETL, Performance, Visuals
├── PromptLibrary/         # AI prompts for DAX, Power Query, ETL, Visuals
├── Contributions/         # CONTRIBUTING.md, CodeOfConduct.md
└── .github/               # Issue/PR templates, CI workflows, tooling scripts
```

---

## Keeping this current

Every document carries `last_verified` in its frontmatter, and
[Topic Index](./Documentation/Topic_Index.md) is generated from those tags — so
navigation stays in sync with the tree automatically.

- **Regenerate the index:** `python .github/scripts/build_index.py`
- **Validate links:** `python .github/scripts/check_links.py`
- **Check frontmatter:** `python .github/scripts/add_frontmatter.py --check`

CI runs all three. When you add a file, tag it; the index and the freshness
check pick it up from there.

---

## Contributing

Please read the [Contribution Guidelines](./Contributions/CONTRIBUTING.md) and
the [Code of Conduct](./Contributions/CodeOfConduct.md) before opening a pull
request. Branch as `feature/<slug>` or `fix/<slug>`; use conventional commit
types (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`).

## License

Licensed under [Creative Commons Zero (CC0)](./LICENSE).

- **Original content** in this repository is free to use without attribution.
- **Referenced content** (Microsoft Learn, SQLBI, community links) remains
  under its own licensing and must be attributed accordingly.

## Contact

Open an issue for questions or suggestions.
