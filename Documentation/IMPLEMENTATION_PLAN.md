# PowerBI-Hub Implementation Plan

> **Last Updated:** December 2024  
> **Status:** In Progress  
> **Tracking:** See [CHECKLIST.md](./CHECKLIST.md) for detailed progress

---

## Current State

The repository has a well-organized folder structure with foundational content now in place. This plan incorporates the latest Power BI features released in 2024-2025.

---

## Phase 1: Core Foundations (Week 1-2) ✅ COMPLETED

### 1.1 Date Tables
- [x] Basic calendar date table
- [x] Extended with fiscal year support
- [x] Multi-calendar (US/UK fiscal, 4-4-5, ISO)

### 1.2 Essential DAX Measures
- [x] Time Intelligence (YTD, QTD, MTD, YoY, Rolling)
- [x] Rankings (Top N, Pareto, ABC, Percentiles)
- [x] Conditional Formatting helpers

### 1.3 Power Query Functions
- [x] Date table generator
- [x] Error handler
- [x] Dynamic data source switcher
- [x] Parameter table builder
- [x] Text cleaning utilities

### 1.4 Design System Basics
- [x] Corporate Light theme
- [x] Corporate Dark theme

### 1.5 Knowledge Base
- [x] References (Articles, Blogs, GitHub repos)
- [x] Prompt Library (DAX, PQ, ETL, Visuals, General)
- [x] Tips & Tricks (DAX, Power Query, Performance)

---

## Phase 2: Modern DAX Features (Week 3-4) 🆕

### 2.1 DAX Window Functions (NEW - 2024)
Window functions enable row navigation and calculations over sorted/partitioned data.

| Function | Purpose | Status |
|----------|---------|--------|
| `INDEX` | Return row at specific position | ⬜ To Add |
| `OFFSET` | Return row relative to current | ⬜ To Add |
| `WINDOW` | Define range of rows for calculation | ⬜ To Add |
| `RANK` | Ranking within partition | ⬜ To Add |
| `ROWNUMBER` | Row number within partition | ⬜ To Add |

**Location:** `Queries/DAX/Measures/WindowFunctions.dax`

**Examples to Include:**
- Year-over-year comparison using OFFSET
- Running totals with WINDOW
- Moving averages
- Lead/Lag calculations
- Ranking within groups

### 2.2 DAX User Defined Functions (NEW - September 2025)
UDFs allow creating reusable, parameterized DAX logic.

**Location:** `Queries/DAX/UserDefinedFunctions/`

| UDF Category | Examples | Status |
|--------------|----------|--------|
| Financial | Tax calculation, Compound interest | ⬜ To Add |
| Statistical | Weighted average, Standard deviation | ⬜ To Add |
| Text | Parsing, Formatting | ⬜ To Add |
| Date | Custom fiscal periods | ⬜ To Add |
| Business Logic | Pricing rules, Discount tiers | ⬜ To Add |

**Key Concepts to Document:**
- `DEFINE FUNCTION` syntax
- VAL vs EXPR parameter modes
- Type hints for parameters
- Pascal case naming convention
- Creating UDFs in DAX Query View

---

## Phase 3: Developer Tools & TMDL (Week 5-6) 🆕

### 3.1 TMDL (Tabular Model Definition Language)
TMDL is the modern code-based format for semantic models.

**Location:** `Scripts/TMDL/`

| Content | Purpose | Status |
|---------|---------|--------|
| TMDL Syntax Guide | Reference for TMDL format | ⬜ To Add |
| Table Templates | Reusable table definitions | ⬜ To Add |
| Measure Templates | Organized measure groups | ⬜ To Add |
| Relationship Patterns | Common relationship configs | ⬜ To Add |
| Role Definitions | RLS role templates | ⬜ To Add |

**Benefits to Document:**
- Human-readable YAML-like syntax
- Better source control (one file per object)
- Team collaboration improvements
- Properties not available in UI

### 3.2 TMDL View in Power BI Desktop
Code editor for semantic models within Desktop.

**Location:** `Documentation/UserGuides/TMDLView.md`

**Topics to Cover:**
- Enabling TMDL View (Preview features)
- Navigating the code editor
- Drag-and-drop scripting
- Diff view for changes
- Integration with external tools
- Common workflows

### 3.3 DAX Query View
Direct DAX query execution in Desktop.

**Location:** `Documentation/UserGuides/DAXQueryView.md`

**Topics to Cover:**
- Creating and running DAX queries
- Testing measures before adding to model
- Performance testing with Server Timings
- Creating UDFs
- EVALUATE and DEFINE statements

---

## Phase 4: AI Integration & MCP (Week 7-8) 🆕

### 4.1 Power BI MCP (Model Context Protocol) - November 2025
Connect AI assistants (Claude, ChatGPT, etc.) to Power BI models.

**Location:** `Integrations/MCP/`

| Content | Purpose | Status |
|---------|---------|--------|
| MCP Setup Guide | Installation & configuration | ⬜ To Add |
| VS Code Integration | Connect via VS Code | ⬜ To Add |
| Use Case Examples | Common AI + PBI scenarios | ⬜ To Add |
| Prompt Templates | MCP-specific prompts | ⬜ To Add |
| Troubleshooting | Common issues & solutions | ⬜ To Add |

**Key Topics:**
- What is MCP (Model Context Protocol)
- Installing Power BI MCP server
- Connecting to PBIX files
- Querying semantic models via AI
- Modifying measures through AI
- Security considerations

### 4.2 Copilot Integration
Power BI's native AI assistant.

**Location:** `Documentation/UserGuides/Copilot.md`

**Topics to Cover:**
- Copilot capabilities in Power BI
- Report generation with Copilot
- DAX generation assistance
- Narrative generation
- Copilot in TMDL View (upcoming)

---

## Phase 5: DevOps & Automation (Week 9-10)

### 5.1 Scripts Enhancement
**Location:** `Scripts/`

| Script Type | Purpose | Status |
|-------------|---------|--------|
| PowerShell - Workspace Management | Bulk operations | ⬜ To Add |
| PowerShell - Dataset Refresh | Automation | ⬜ To Add |
| PowerShell - Gateway Management | Configuration | ⬜ To Add |
| C# - Tabular Editor Scripts | BPA, documentation | ⬜ To Add |
| Python - REST API | Automation | ⬜ To Add |

### 5.2 Deployment Pipelines
**Location:** `Deployment/Pipelines/`

| Content | Purpose | Status |
|---------|---------|--------|
| Azure DevOps YAML | CI/CD templates | ⬜ To Add |
| GitHub Actions | Workflow templates | ⬜ To Add |
| Fabric Git Integration | Setup guide | ⬜ To Add |
| TMDL Deployment | Code-based deployments | ⬜ To Add |

### 5.3 Tabular Editor Integration
**Location:** `Scripts/CSharp/TabularEditor/`

| Content | Purpose | Status |
|---------|---------|--------|
| Best Practice Analyzer Rules | Custom BPA rules | ⬜ To Add |
| C# Scripts | Automation scripts | ⬜ To Add |
| Macros | Common operations | ⬜ To Add |
| Documentation Generator | Auto-doc measures | ⬜ To Add |

---

## Phase 6: Governance & Security (Week 11-12)

### 6.1 Governance Framework
**Location:** `Governance/`

| Document | Purpose | Status |
|----------|---------|--------|
| Naming Conventions | Standards document | ⬜ To Add |
| Data Classification | Policy template | ⬜ To Add |
| Access Control Matrix | Permission templates | ⬜ To Add |
| Audit Procedures | Compliance checklists | ⬜ To Add |
| Change Management | Process documentation | ⬜ To Add |

### 6.2 Security Patterns
**Location:** `Governance/Security/`

| Pattern | Purpose | Status |
|---------|---------|--------|
| RLS Templates | Row-level security DAX | ⬜ To Add |
| OLS Templates | Object-level security | ⬜ To Add |
| Dynamic Security | User-based filtering | ⬜ To Add |
| Service Principal | Automation security | ⬜ To Add |

---

## Phase 7: Advanced Features (Week 13-14)

### 7.1 Custom Visuals Development
**Location:** `Visuals/CustomVisuals/`

| Content | Purpose | Status |
|---------|---------|--------|
| Deneb/Vega-Lite Examples | Declarative visuals | ⬜ To Add |
| Python Visual Templates | Python integration | ⬜ To Add |
| R Visual Templates | R integration | ⬜ To Add |
| SVG Templates | Custom graphics | ⬜ To Add |

### 7.2 Advanced Data Modeling
**Location:** `Data/DataModels/`

| Pattern | Purpose | Status |
|---------|---------|--------|
| Calculation Groups | Time intelligence groups | ⬜ To Add |
| Field Parameters | Dynamic dimensions | ⬜ To Add |
| Composite Models | DirectQuery + Import | ⬜ To Add |
| Aggregations | Large dataset optimization | ⬜ To Add |

### 7.3 Microsoft Fabric Integration
**Location:** `Integrations/Fabric/`

| Content | Purpose | Status |
|---------|---------|--------|
| Lakehouse Patterns | Data architecture | ⬜ To Add |
| Dataflow Gen2 | Modern ETL | ⬜ To Add |
| Direct Lake | Real-time analytics | ⬜ To Add |
| OneLake Integration | Unified storage | ⬜ To Add |

---

## New Feature Reference

### DAX Window Functions (2024)

```dax
// OFFSET - Get value from previous row
Sales Previous Month = 
CALCULATE(
    [Sales Amount],
    OFFSET(-1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)

// WINDOW - Moving average
Sales 3M Moving Avg = 
AVERAGEX(
    WINDOW(-2, REL, 0, REL, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month])),
    [Sales Amount]
)

// INDEX - Get specific row value
First Month Sales = 
CALCULATE(
    [Sales Amount],
    INDEX(1, ALLSELECTED('Date'[Month]), ORDERBY('Date'[Month]))
)
```

### DAX User Defined Functions (September 2025)

```dax
// Define a UDF
DEFINE
    FUNCTION CalculateTax(Amount AS CURRENCY, TaxRate AS DOUBLE) AS CURRENCY =
        Amount * (1 + TaxRate)

// Use the UDF
EVALUATE
    ADDCOLUMNS(
        Sales,
        "Total with Tax", CalculateTax([Amount], 0.1)
    )
```

### TMDL Syntax Example

```yaml
table Sales
    lineageTag: abc-123

    measure 'Total Sales' = SUM(Sales[Amount])
        formatString: $#,##0
        displayFolder: Revenue
        
    column Amount
        dataType: decimal
        sourceColumn: Amount
        
    partition Sales = m
        mode: import
        source = 
            let
                Source = Sql.Database("server", "db")
            in
                Source
```

---

## File Naming Convention

```
[Category]_[Feature]_[Description]_v[Version].[ext]

Examples:
- DAX_WindowFunctions_Examples_v1.dax
- DAX_UDF_Financial_v1.dax
- TMDL_Table_SalesTemplate_v1.tmdl
- PS_Workspace_BulkExport_v1.ps1
```

---

## Quick Reference Links

| Feature | Documentation | Release |
|---------|---------------|---------|
| Window Functions | [SQLBI Whitepaper](https://www.sqlbi.com/whitepapers/windows-functions-in-dax/) | 2024 |
| DAX UDFs | [Microsoft Learn](https://learn.microsoft.com/power-bi/transform-model/desktop-user-defined-functions) | Sep 2025 |
| TMDL | [Microsoft Learn](https://learn.microsoft.com/analysis-services/tmdl/tmdl-overview) | 2024 |
| TMDL View | [Microsoft Learn](https://learn.microsoft.com/power-bi/transform-model/desktop-tmdl-view) | Jan 2025 |
| Power BI MCP | [Power BI Blog](https://powerbi.microsoft.com/blog/) | Nov 2025 |
| DAX Query View | [Microsoft Learn](https://learn.microsoft.com/power-bi/transform-model/dax-query-view) | 2024 |

---

## Maintenance Schedule

| Frequency | Action |
|-----------|--------|
| Weekly | Add new measures/queries created |
| Monthly | Review and update Tips & Tricks |
| Quarterly | Audit external references, update for new features |
| On-demand | Add templates as reusable reports are created |

---

*See [CHECKLIST.md](./CHECKLIST.md) for detailed task tracking.*
