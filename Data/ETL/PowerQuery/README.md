---
title: PowerQuery
tags: [power-query, etl]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# PowerQuery

> Power Query / M transformation patterns.

## Where to focus

- **Query folding** — keep transformations in the source where possible so
  less data is read. Check with *View Native Query* in Power Query Editor.
- **Steps not queries.** Prefer many simple steps in one query over many
  intermediate queries; intermediate queries break folding and add no value.
- **`Table.Buffer`** is a blunt instrument. It is useful for isolating a
  volatile source from downstream changes, and harmful as a reflex.
- **Errors** should be handled explicitly where a source is known to have gaps.
  See [fnErrorHandler.m](../../../Queries/PowerQuery/CustomFunctions/fnErrorHandler.m).

## Reuse

Put shared logic in custom functions rather than copying steps between
queries. See [CustomFunctions](../../../Queries/PowerQuery/CustomFunctions/).

## Practice

- Rename queries to something descriptive; the query name is the first thing a
  reader sees.
- Set explicit types on every column.
- Keep the staging layer separate from the transformation layer.

## Related

- [Power Query best practices](../../../Queries/PowerQuery/BestPractices/)
- [Power Query tips](../../../TipsAndTricks/PowerQuery.md)
- [Power Query prompts](../../../PromptLibrary/PowerQueryPrompts.md)
