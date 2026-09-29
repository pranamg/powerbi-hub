---
title: Learning Paths
tags: [meta, navigation, learning]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# Learning Paths

Sequenced reading for the roles this hub serves. Each path is ordered by
dependency: read it top to bottom and the later material assumes the earlier.

Paths link only to documents that exist in this repository. Where a step is
genuinely missing, it is listed under **Known gaps** rather than quietly
skipped, so you know the limit of the current coverage.

| Path | For | Steps | Time |
|------|-----|------:|-----:|
| [Semantic Model Author](#1-semantic-model-author) | Model authors, BI developers | 7 | ~4 h |
| [DAX Practitioner](#2-dax-practitioner) | Anyone writing measures | 7 | ~5 h |
| [PBIP, TMDL & Git](#3-pbip-tmdl--git) | Developers moving to source control | 6 | ~3 h |
| [AI Readiness & Agentic](#4-ai-readiness--agentic) | AI-assisted model and report work | 6 | ~3 h |
| [Report Author](#5-report-author) | Report and dashboard builders | 6 | ~2 h |
| [BI Admin & Governance](#6-bi-admin--governance) | Platform owners | 6 | ~3 h |

Not sure where to start? Take the [hub's start-here routing
table](../README.md) or browse the [topic index](../Topic_Index.md).

---

## 1. Semantic Model Author

Build a model that is correct, fast, and maintainable. The core loop of most
Power BI work.

### Steps

1. **[Date Table Templates](../../Data/Constants/DateTable/README.md)** —
   Every model needs a marked date table. Start here; the three variants
   (basic, multi-calendar, extended) cover most cases.

2. **[Data Models](../../Data/DataModels/README.md)** — Reference models to
   compare against yours. Read
   [Model 1 — Minimal Star Schema](../../Data/DataModels/Model1/README.md)
   first as the baseline shape.

3. **[Power Query Best Practices](../../Queries/PowerQuery/BestPractices/README.md)** —
   Query folding and staging happen before the model exists; mistakes here are
   expensive to undo later.

4. **[DAX Best Practices](../../Queries/DAX/BestPractices/README.md)** — The
   rules that keep measures fast and comprehensible.

5. **[DAX Measures Library](../../Queries/DAX/Measures/README.md)** — Copy-ready
   measures for time intelligence, rankings, conditional formatting, and
   window functions.

6. **[Calculation Groups](../../Queries/DAX/CalculationGroups/README.md)** —
   Time intelligence and currency conversion done once instead of per-measure.

7. **[Performance Tuning](../../Optimization/PerformanceTuning/README.md)** plus
   [Memory Optimization](../../Optimization/MemoryOptimization/README.md) —
   Apply after the model exists; measure before optimising.

### Known gaps

- No dedicated star-schema design guide. `Data/DataModels/` gives you
  reference models to imitate rather than a written methodology.
- No calculated-column vs measure decision guide, though
  [Calculated Columns](../../Queries/DAX/CalculatedColumns/README.md) exists
  as a starting point.
- Direct Lake modeling is covered in
  [Integrations/Fabric/DirectLake.md](../../Integrations/Fabric/DirectLake.md)
  but not as a first-class modeling path.

---

## 2. DAX Practitioner

Context engine, iterators, then performance. Assumes you can build a basic
star schema.

### Steps

1. **[DAX Tips & Tricks](../../TipsAndTricks/DAX.md)** — Quick wins and common
   pitfalls.

2. **[DAX Best Practices](../../Queries/DAX/BestPractices/README.md)** — The
   rules that govern how measures should be written.

3. **[DAX Measures Library](../../Queries/DAX/Measures/README.md)** —
   [TimeIntelligence](../../Queries/DAX/Measures/TimeIntelligence.dax),
   [Rankings](../../Queries/DAX/Measures/Rankings.dax),
   [ConditionalFormatting](../../Queries/DAX/Measures/ConditionalFormatting.dax),
   and [WindowFunctions](../../Queries/DAX/Measures/WindowFunctions.dax).

4. **[Window Functions](../../Queries/DAX/Measures/WindowFunctions.dax)** —
   `INDEX`, `OFFSET`, `WINDOW`, `RANK`, `ROWNUMBER`. The `WINDOW` syntax in
   the file's docs is the clearest reference in the repo.

5. **[User-Defined Functions](../../Queries/DAX/UserDefinedFunctions/README.md)** —
   Reusable, parameterised DAX. See
   [UDF_Examples.dax](../../Queries/DAX/UserDefinedFunctions/UDF_Examples.dax).

6. **[Calculation Groups](../../Queries/DAX/CalculationGroups/README.md)** —
   [TimeIntelligence](../../Queries/DAX/CalculationGroups/TimeIntelligence.dax)
   and
   [CurrencyConversion](../../Queries/DAX/CalculationGroups/CurrencyConversion.dax)
   show the pattern well.

7. **[Performance Tuning](../../Optimization/PerformanceTuning/README.md)** and
   [Query Optimization](../../Optimization/QueryOptimization/README.md) —
   `CALCULATE` reduction, iterators, storage engine limits.

### Reference material

- [DAX Patterns (SQLBI)](https://www.daxpatterns.com/) — the definitive pattern
  catalogue; the hub's measures draw on it.
- [DAX Guide (SQLBI)](https://dax.guide/) — searchable function index.
- [DAX reference (Microsoft Learn)](https://learn.microsoft.com/en-us/dax/dax-function-reference)

### Known gaps

- No written explanation of filter context vs row context. This is the
  single most important DAX concept and the hub currently only references it
  via [References/Articles.md](../../References/Articles.md).
- No Info functions reference.

---

## 3. PBIP, TMDL & Git

Source control for Power BI. Assumes you can build a model and have used Git.

### Steps

1. **[TMDL Templates](../../Scripts/TMDL/README.md)** — Start from
   [Table_Template.tmdl](../../Scripts/TMDL/Table_Template.tmdl),
   [Measures_Template.tmdl](../../Scripts/TMDL/Measures_Template.tmdl),
   [Relationship_Template.tmdl](../../Scripts/TMDL/Relationship_Template.tmdl),
   [RLS_Template.tmdl](../../Scripts/TMDL/RLS_Template.tmdl), and
   [DateTable_Template.tmdl](../../Scripts/TMDL/DateTable_Template.tmdl).

2. **[TMDL View (Desktop)](../../Documentation/UserGuides/TMDLView.md)** — The
   in-Desktop authoring surface for TMDL.

3. **[Reference Models](../../Data/DataModels/README.md)** —
   [Model 1](../../Data/DataModels/Model1/README.md) is a working TMDL model you
   can inspect; [Model 2](../../Data/DataModels/Model2/README.md) adds
   calculation groups and a shared dimension.

4. **[Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md)** —
   Round-tripping through the service.

5. **[Deployment Pipelines](../../Deployment/Pipelines/README.md)** — The
   service-native path, with
   [GitHub Actions](../../Deployment/Pipelines/github-actions.yml) and
   [Azure Pipelines](../../Deployment/Pipelines/azure-pipelines.yml) examples.

6. **[Hooks: Quality Gates](../../AgenticDevelopment/Hooks/README.md)** — Run
   Best Practice Analyzer in CI so bad changes never merge.

### Known gaps

- **PBIR is not documented.** The report side of a PBIP project (the
  `definition/` folder, `definition.pbir`, and the public JSON schemas) is
  entirely absent. This is the highest-priority gap in the hub and blocks
  report-level source control.
- No conflict-resolution guide for TMDL merges.
- No schema-validation setup for TMDL or JSON files.

---

## 4. AI Readiness & Agentic

Preparing models for Copilot and working with AI agents. Newest and least
complete path — read the gaps.

### Steps

1. **[Copilot in Power BI](../../Documentation/UserGuides/Copilot.md)** — What
   Copilot can and cannot do today, and what the model owes it.

2. **[Agentic Development](../../AgenticDevelopment/README.md)** — The
   overview: when agentic work helps and when it does not.

3. **[MCP Tools](../../AgenticDevelopment/MCPTools/README.md)** — Start with
   [Power BI Modeling MCP Server](../../AgenticDevelopment/MCPTools/PowerBI_Modeling_MCP.md),
   then [Configuration Examples](../../AgenticDevelopment/MCPTools/ConfigurationExamples.md).

4. **[MCP Setup Guide](../../Integrations/MCP/Setup_Guide.md)** and
   [VS Code Integration](../../Integrations/MCP/VSCode_Integration.md) — Wiring.

5. **[MCP Use Cases](../../Integrations/MCP/UseCases/README.md)** —
   [Data Exploration](../../Integrations/MCP/UseCases/DataExploration.md),
   [Measure Development](../../Integrations/MCP/UseCases/MeasureDevelopment.md),
   [Querying Models](../../Integrations/MCP/UseCases/QueryingModels.md),
   [Report Analysis](../../Integrations/MCP/UseCases/ReportAnalysis.md),
   [Documentation Generation](../../Integrations/MCP/UseCases/DocumentationGeneration.md).

6. **[Prompt Library](../../PromptLibrary/README.md)** — Starting prompts for
   [DAX](../../PromptLibrary/DAXPrompts.md),
   [Power Query](../../PromptLibrary/PowerQueryPrompts.md),
   [MCP](../../PromptLibrary/MCPPrompts.md), and
   [visuals](../../PromptLibrary/VisualsPrompts.md).

### Adjacent workflows

- [Direct Metadata Modification](../../AgenticDevelopment/Workflows/DirectMetadataModification.md)
  — editing TMDL files directly.
- [MCP Server Workflow](../../AgenticDevelopment/Workflows/MCPServerWorkflow.md)
  and [CLI Tools Workflow](../../AgenticDevelopment/Workflows/CLIToolsWorkflow.md).
- [Tabular Editor CLI](../../AgenticDevelopment/CustomCommands/TabularEditorCLI.md).

### Known gaps

- **"Prep for AI" is not documented at all.** AI data schemas, AI
  instructions, and verified answers — the features that determine whether
  Copilot answers your model correctly — have no coverage.
- Microsoft's official agent skills (`semantic-model-authoring`,
  `power-bi-report-authoring`, and the planner/design skills) are not
  covered; the repo's agentic content predates them.
- The remote Power BI MCP server (natural-language querying against a
  published model) is not covered; only local/modeling MCP is.
- No Power BI Desktop Bridge / CLI coverage for the reload-and-screenshot
  verification loop.
- No Fabric data agent guidance.

---

## 5. Report Author

Designing and building reports that people can read.

### Steps

1. **[Design Guidelines](../../Design/Guidelines/README.md)** — The house
   rules for layout, hierarchy, and density.

2. **[Design Best Practices](../../Design/BestPractices/README.md)** — Applied
   to real report problems.

3. **[Atomic Elements](../../Design/AtomicElements/README.md)** — Reusable
   building blocks: [Cards](../../Design/AtomicElements/Cards/README.md),
   [Tables](../../Design/AtomicElements/Tables/README.md),
   [Buttons](../../Design/AtomicElements/Buttons/README.md),
   [Other](../../Design/AtomicElements/Other/README.md).

4. **[Themes](../../Design/Themes/README.md)** — With
   [Theme_Corporate_Light.json](../../Design/Themes/Theme_Corporate_Light.json)
   and [Theme_Corporate_Dark.json](../../Design/Themes/Theme_Corporate_Dark.json)
   to copy.

5. **[Copilot in Power BI](../../Documentation/UserGuides/Copilot.md)** — Report
   creation, narrative visual, and Q&A.

6. **[DAX Query View](../../Documentation/UserGuides/DAXQueryView.md)** — Check
   what a visual actually queries before optimising it.

### Known gaps

- No PBIR documentation, so report source control is not covered (see path 3).
- Accessibility is covered as a checklist in
  [TipsAndTricks/Visuals.md](../../TipsAndTricks/Visuals.md) but there is no
  dedicated accessibility guide, and no coverage of the mobile report layout.

---

## 6. BI Admin & Governance

Owning the platform: access, security, lifecycle, and standards.

### Steps

1. **[Governance Overview](../../Governance/README.md)** — Structure of the
   area.

2. **[Development Standards](../../Governance/DevelopmentStandards.md)** and
   **[Naming Conventions](../../Governance/NamingConventions.md)** — The
   conventions the rest of the hub assumes.

3. **[RLS Patterns](../../Governance/RLSPatterns.md)** with
   [RLS_Template.tmdl](../../Scripts/TMDL/RLS_Template.tmdl) — Security
   enforced in the model.

4. **[OLS Configuration](../../Governance/OLSConfiguration.md)** — Column-level
   security, and how it differs from RLS.

5. **[Service Principal Setup](../../Governance/ServicePrincipalSetup.md)** —
   Automation identities; pairs with the deployment scripts in
   [Scripts/PowerShell/Admin/](../../Scripts/PowerShell/Admin/README.md).

6. **[Deployment Environments](../../Deployment/Environments/README.md)** and
   [Configurations](../../Deployment/Configurations/README.md) — Promote with
   intent.

### Supporting material

- [Access Control Matrix](../../Governance/AccessControlMatrix.md)
- [Data Classification](../../Governance/DataClassification.md)
- [Audit Procedures](../../Governance/AuditProcedures.md)
- [Change Management](../../Governance/ChangeManagement.md)
- [Workspaces](../../Collaboration/Workspaces/README.md) ·
  [Permissions](../../Collaboration/Permissions/README.md) ·
  [Comments](../../Collaboration/Comments/README.md)
- [Team Collaboration](../../Documentation/UserGuides/TeamCollaboration.md)

### Known gaps

- No tenant-settings reference. The hub assumes settings exist but never
  enumerates them.
- No capacity planning or cost-management content.
- Monitoring (alerts, logs, metrics) is thin — see
  [Monitoring](../../Monitoring/README.md).
- [Audits](../../Governance/Audits/README.md),
  [Compliance](../../Governance/Compliance/README.md), and
  [Policies](../../Governance/Policies/README.md) are index pages with little
  substance behind them.
