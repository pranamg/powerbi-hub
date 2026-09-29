---
title: Books
tags: [references, learning]
audience: [all]
difficulty: reference
last_verified: 2026-09-29
---

# Books

Books are still the most complete way to learn DAX and modeling. Most are
better as a reference you dip into than something to read front to back.

> Publisher and edition details change. Check the linked page for the current
> edition — several titles below have newer editions than older tutorials
> suggest.

## Essential DAX

| Book | Author | Read it for |
|------|--------|-------------|
| [The Definitive Guide to DAX](https://www.sqlbi.com/books/the-definitive-guide-to-dax) (3rd ed., Microsoft Press, Dec 2025) | Marco Russo & Alberto Ferrari | The single best DAX book. The 3rd edition adds user-defined functions, window functions, visual calculations, and calculation groups — the modern DAX surface |
| [DAX Patterns](https://www.sqlbi.com/books/dax-patterns) (2nd ed.) | Marco Russo & Alberto Ferrari | Not a tutorial — a catalogue of solved problems. The hub's [DAX Measures Library](../Queries/DAX/Measures/README.md) and [Calculation Groups](../Queries/DAX/CalculationGroups/README.md) follow this lineage |
| [Optimizing DAX](https://www.sqlbi.com/books/optimizing-dax) (2nd ed., 2024) | Marco Russo & Alberto Ferrari | Performance specifically. Read after you can write correct DAX, not before |

The Definitive Guide to DAX 3rd edition is the one to buy if you buy only
one. Its chapter list maps almost directly onto this hub's
[DAX Practitioner learning path](../Documentation/LearningPaths/README.md#2-dax-practitioner):

| Book chapter | This hub |
|---|---|
| Filter context and `CALCULATE` | [DAX Best Practices](../Queries/DAX/BestPractices/README.md) |
| Row context and context transition | [DAX Best Practices](../Queries/DAX/BestPractices/README.md) |
| Variables | [DAX Tips](../TipsAndTricks/DAX.md) |
| User-defined functions | [User-Defined Functions](../Queries/DAX/UserDefinedFunctions/README.md) |
| Window functions | [WindowFunctions.dax](../Queries/DAX/Measures/WindowFunctions.dax) |
| Time intelligence | [TimeIntelligence.dax](../Queries/DAX/Measures/TimeIntelligence.dax) |
| Visual calculations | Not covered — see [known gaps](#known-gaps) |
| Calculation groups | [Calculation Groups](../Queries/DAX/CalculationGroups/README.md) |

Sample chapters for The Definitive Guide to DAX are available free from
Microsoft Press.

## Modeling and data preparation

| Book | Author | Read it for |
|------|--------|-------------|
| [Analyzing Data with Power BI and Power Pivot for Excel](https://www.sqlbi.com/tools/tabular-editor) | Marco Russo & Alberto Ferrari | Power Query and Power Pivot taught from first principles. Still the best Power Query book in print |
| [Analyzing Data with Power BI and Power Pivot for Excel](https://www.sqlbi.com/tools/tabular-editor) — companion volume | Marco Russo | Tabular engine internals: VertiPaq, partitioning, processing. Pairs with [Memory Optimization](../Optimization/MemoryOptimization/README.md) |
| [The Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/) | Ralph Kimball & Margy Kimball | Dimensional modelling, the discipline behind a star schema. Vendor-neutral |
| [Power Pivot and Power BI: The Excel User's Guide](https://www.robcollie.com/) | Rob Collie | A gentler on-ramp for Excel users. Older, but the mental model still holds |

## Power BI specifics

| Book | Author | Read it for |
|------|--------|-------------|
| [Microsoft Power BI Quick Start Guide](https://www.microsoft.com/en-us/store/books/Microsoft-Power-BI-Quick-Start-Guide) (2nd ed.) | Devin Knight | End-to-end walkthrough for building a first report. Good for report authors, thin on modeling |
| [Beginning Microsoft Power BI](https://www.apress.com/) | Dan Clark | Broad coverage of the service, sharing, and governance |

## Tooling

| Tool | Why |
|------|-----|
| [DAX Guide](https://dax.guide/) | Free searchable function index by Marco Russo. Faster than searching docs |
| [DAX.do](https://dax.do/) | Free browser-based DAX sandbox for practice, no install |
| [Tabular Editor](https://tabulareditor.com/) | See [C# and Tabular Editor](../Scripts/CSharp/TabularEditor/README.md) |
| [DAX Studio](https://dax.studio/) | Query plans, server timings, measure extraction. The hub's [Performance Tuning](../Optimization/PerformanceTuning/README.md) assumes you have it |

## How to use these alongside this hub

Books and this hub serve different purposes. Use the hub for *pattern lookup*
and *up-to-date mechanics* — Microsoft ships monthly changes and a book does
not. Use books for *concepts that need depth and sequence*, especially filter
context, VertiPaq, and dimensional modelling.

Concretely: read The Definitive Guide to DAX for concepts, then come back here
for the current syntax, the current file layout, and the tooling that did not
exist when the book was written.

## Known gaps

- No book covers **visual calculations** in this hub's own material. They are
  a measure-layer feature that changes how filters apply, and the 3rd edition
  of The Definitive Guide to DAX now devotes a chapter to them.
- No book recommendation for **paginated reports** (RDL/Report Builder).
- No guidance on **AI-assisted development** tooling as a book-length topic;
  this area moves too fast for print. See
  [Agentic Development](../AgenticDevelopment/README.md) instead.

## Related

- [Articles](./Articles.md) — free, and more current than books
- [Blogs](./BlogPosts.md) — where practitioners publish new patterns first
- [YouTube](./YouTube/Channels.md) — visual walkthroughs
- [DAX Practitioner path](../Documentation/LearningPaths/README.md#2-dax-practitioner)
