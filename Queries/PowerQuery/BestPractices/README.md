---
title: Power Query Best Practices
tags: [power-query, etl]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Power Query Best Practices

> Practices for fast, maintainable M code.

## Query design

- **Prefer steps within a query to intermediate queries.** Intermediate
  queries break query folding and add no value.
- **Filter and project early.** Removing unneeded rows and columns at the
  first opportunity is the single biggest refresh win.
- **Set explicit column types.** Inferred types can change between refreshes
  and break downstream logic.
- **Use references deliberately.** Referencing an earlier step duplicates its
  logic, so use it when you want the original preserved, not by default.

## Folding

- Check folding with **View → Native Query** in Power Query Editor.
- Steps that **prevent folding**: custom functions, Python/R, `Table.Buffer`
  applied before a reduction, and some joins.
- Where a step must not fold (for example, to stabilise a volatile source),
  use `Table.Buffer` deliberately and note why.

## Parameters

- Use a **parameter table** for anything environment-specific — paths, URLs,
  schema, dates. This is what allows the same query to be promoted between
  environments.
- Do not use `Web.Contents` with a hard-coded URL string.

## Naming and structure

- Name queries descriptively; the query name is the reader's first clue.
- Keep **staging and transformation in separate queries**, and do not rename
  during extraction.
- Add a description to queries that do anything non-obvious.

## Errors

- Handle errors explicitly where a source is known to have gaps, using
  `try ... otherwise`. See
  [fnErrorHandler.m](../CustomFunctions/fnErrorHandler.m).
- Decide deliberately whether a failed row should **drop, error, or keep a
  null** — silently dropping data is the dangerous default.

## Related

- [Custom functions](../CustomFunctions/)
- [ETL best practices](../../../Data/ETL/BestPractices/)
- [Power Query tips](../../../TipsAndTricks/PowerQuery.md)
