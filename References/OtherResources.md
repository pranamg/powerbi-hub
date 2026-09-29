---
title: Other Resources
tags: [references, learning]
audience: [all]
difficulty: reference
last_verified: 2026-09-29
---

# Other Resources

Learning paths, certifications, and practice environments — the things that
aren't articles, blogs, books, or video.

## Certifications

Microsoft's Associate certifications expire annually and are renewed by
passing a free online assessment, so the cost of staying current is a
30–45 minute quiz once a year.

| Exam | Credential | Focus | Who it's for |
|------|------------|-------|--------------|
| [PL-300](https://learn.microsoft.com/en-us/credentials/certifications/exams/pl-300) | Power BI Data Analyst Associate | Power Query, DAX, modelling, visual design, service and refresh | Report authors and analysts. Replaced the older DA-100 |
| [DP-600](https://learn.microsoft.com/en-us/credentials/certifications/exams/dp-600) | Fabric Data Engineer Associate | Fabric analytics: DAX, SQL analytics endpoints, Spark, dataflows | Developers whose work spans Power BI and Fabric |
| [DP-700](https://learn.microsoft.com/en-us/credentials/certifications/exams/dp-700) | Fabric Data Engineer Associate | Data engineering with Fabric: pipelines, warehouses, orchestration | Data engineers, not BI developers |
| [GH-300](https://learn.microsoft.com/en-us/credentials/certifications/) | GitHub Copilot Exam | Using agents and Copilot effectively | Relevant if you are adopting the agentic workflows in this hub |

### A common misconception

**DP-300 is not a Power BI exam.** It is *Administering Microsoft Azure SQL
Solutions*. For Power BI, the code is **PL-300**. Plenty of study material
online mixes these up.

### Fundamentals, if you are starting out

| Exam | Credential |
|------|------------|
| [PL-900](https://learn.microsoft.com/en-us/credentials/certifications/exams/pl-900) | Power Platform Fundamentals |
| [DP-900](https://learn.microsoft.com/en-us/credentials/certifications/exams/dp-900) | Azure Data Fundamentals |

### Exam format, for planning

| Property | Value |
|----------|-------|
| Questions | 40–60, including multiple choice, drag-and-drop, and case studies |
| Duration | ~100 minutes |
| Passing score | 700 / 1000 |
| Prerequisites | None for PL-300; experience strongly recommended |
| Renewal | Free online assessment, annually |

Most questions cover generally available features. Preview features appear
only when they are already in common use — so do not skip GA material to chase
preview features.

### Retirement watch

Microsoft retired a large batch of exams in 2026, including MS-900, DP-100,
AI-102, AI-900, PL-500, and PL-600. PL-400 (Power Platform Developer) has a
last exam date of **30 October 2026**. Check
[retired certification exams](https://learn.microsoft.com/en-us/credentials/support/retired-certification-exams)
before you invest in a study plan.

## Free practice environments

| Resource | Use it for |
|----------|-----------|
| [DAX.do](https://dax.do/) | Writing and testing DAX in a browser — no install, no model to build first |
| [DAX Patterns](https://www.daxpatterns.com/) | Solved DAX problems by category; the reference behind many patterns in this hub |
| [DAX Guide](https://dax.guide/) | Searchable DAX function index |
| [DAX Formatter](https://www.daxformatter.com/) (SQLBI) | Formats a `.dax` file so diffs are readable — useful in CI |
| [Bravo for Power BI](https://www.sqlbi.com/tools/bravo) (SQLBI) | Free external tools suite: measure extraction, DAX debugger, model documentation |
| [Microsoft Learn sandbox](https://learn.microsoft.com/en-us/credentials/certifications/) | Practice the exam interface before test day |
| [Sample reports](https://github.com/microsoft/powerbi-desktop-samples) | Real PBIX files to open, break, and learn from |
| [AdventureWorks / Contoso datasets](https://learn.microsoft.com/en-us/power-bi/sample-datasets) | Microsoft's standard sample data for tutorials and demos |

## Official learning paths

Microsoft Learn learning paths are free and structured. They are worth
completing once, then treating as reference:

| Path | Focus |
|------|-------|
| [Get data with Power BI Desktop](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | Power Query fundamentals |
| [Model data with Power BI](https://learn.microsoft.com/en-us/training/paths/model-data-power-bi/) | Relationships, dimensions, star schema |
| [Build Power BI visuals and reports](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | Visual selection and report design |
| [Optimize a model for performance](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | VertiPaq, partitioning, DAX performance |
| [Apply security in Power BI](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | RLS, OLS, sensitivity labels |
| [Manage the lifecycle of datasets in Power BI](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | Deployment pipelines, lineage, certification |
| [Plan and manage Power BI in an organization](https://learn.microsoft.com/en-us/training/paths/?terms=power%20bi) | Workspaces, capacities, governance |

## Community and events

| Resource | What it offers |
|----------|----------------|
| [Microsoft Fabric Community](https://community.fabric.microsoft.com/) | Official forums, blog, and the monthly feature summary posts |
| [Power BI Community](https://community.powerbi.com/) | Long-running forum; the place for DAX and modeling questions with expert answers |
| [Stack Overflow — `powerbi`](https://stackoverflow.com/questions/tagged/powerbi) | Focused technical Q&A |
| [r/PowerBI](https://reddit.com/r/PowerBI) | Discussion, showcase, and news |
| [Microsoft Fabric Community Conference (FabCon)](https://community.fabric.microsoft.com/fabric/events) | Free annual conference; sessions are posted online afterwards |
| [PASS / SQLBits](https://sqlbits.com/) | Conference sessions, many free on YouTube |
| [SQLBI training](https://www.sqlbi.com/training/) | Paid, and the standard for DAX depth |
| [Pragmatic Works](https://pragmaticworks.com/) | Paid courses and webinars across Power BI and Fabric |

## Blogs worth a weekly check

See [Blogs](./BlogPosts.md) for the full list. In short: SQLBI for DAX and
modelling depth, RADACAD for Power Query and architecture, and the
[Power BI blog](https://powerbi.microsoft.com/en-us/blog) for official
release announcements.

## Tooling indexes

| Resource | Use it for |
|----------|-----------|
| [DAX Guide](https://dax.guide/) | Function reference |
| [Microsoft json-schemas](https://github.com/microsoft/json-schemas) | Validation schemas for PBIR, TMDL, and PBIP files — what an editor uses to check your project |
| [pbi-tools](https://pbi.tools/) | Compile, diff, and deploy PBIX/TMDL/PBIP from the command line |
| [Tabular Editor](https://tabulareditor.com/) | Bulk metadata editing, Best Practice Analyzer, C# scripting |
| [DAX Studio](https://dax.studio/) | Query plans and server timings |

## Related

- [Books](./Books.md) — depth on DAX and modelling
- [Articles](./Articles.md) — free and current
- [GitHub Repos](./GitHubRepos.md) — tools and sample projects
- [YouTube](./YouTube/Channels.md)
- [Topic Index](../Documentation/Topic_Index.md)
