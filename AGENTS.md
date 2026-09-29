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
└── .github/            → Issue and PR templates, CI workflows

Keep this list in sync with the actual folder tree when adding or removing
top-level folders.

## Conventions & Patterns

- Markdown style: `#` for main headings, `##` for subheadings
- Code blocks with triple backticks and language identifiers
- Clear, descriptive file/folder naming
- Each subfolder should have a README.md

## Git Workflow

- Branch naming: `feature/<slug>` or `fix/<slug>`
- Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat: Add custom DAX measures for sales analysis`
