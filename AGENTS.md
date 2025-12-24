# PowerBI-Hub

A centralized documentation and resource hub for Power BI best practices, templates, scripts, queries, visuals, and reference materials.

## Core Tasks

- Adding/editing Markdown documentation
- Creating DAX measures and Power Query functions
- Adding templates for reports and dashboards
- Updating reference materials and tips

## Project Layout

├── Data/           → Data sources, models, ETL scripts, constants
├── Scripts/        → PowerShell, Python, C#, Azure Automation, Jupyter
├── Queries/        → DAX measures, calculated columns, Power Query functions
├── Visuals/        → Custom visuals, R/Python visuals, layouts
├── Design/         → Themes, guidelines, templates, atomic elements
├── Templates/      → Report and dashboard templates
├── Reports/        → Example reports
├── Dashboards/     → Example dashboards
├── Documentation/  → Setup guides, architecture diagrams, user guides
├── References/     → Books, articles, blogs, YouTube, GitHub repos
├── TipsAndTricks/  → DAX, Power Query, ETL, Performance, Visuals tips
├── PromptLibrary/  → AI prompts for DAX, Power Query, ETL, Visuals

## Conventions & Patterns

- Markdown style: `#` for main headings, `##` for subheadings
- Code blocks with triple backticks and language identifiers
- Clear, descriptive file/folder naming
- Each subfolder should have a README.md

## Git Workflow

- Branch naming: `feature/<slug>` or `fix/<slug>`
- Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Example: `feat: Add custom DAX measures for sales analysis`
