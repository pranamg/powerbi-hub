# ETL Best Practices

> Practices that apply across every extraction and transformation tool.

## Layer your logic

Keep each stage doing one thing, in a predictable order:

1. **Extract** — read the source with the narrowest useful projection.
2. **Stage** — land raw data with minimal transformation, and do not rename
   yet. Staging is where you want fidelity to the source.
3. **Transform** — rename, type, and clean. Business rules live here.
4. **Present** — shape for the model, and apply business logic.

Renaming during extract is the most common source of confusion, because it
makes a staging failure hard to trace back to the source column.

## Rules that apply everywhere

- **Filter early.** Remove rows and columns not needed as early as possible.
- **Preserve query folding.** Steps that break folding — custom functions,
  Python/R, `Table.Buffer` in the wrong place — are expensive at scale.
- **Type columns explicitly.** Do not rely on inference, which can change
  between refreshes.
- **Make steps idempotent.** A refresh should be safe to re-run.
- **Parameterise environment-specific values** (paths, URLs, schema) rather
  than hard-coding them.
- **Document the refresh schedule and dependencies** for each pipeline.

## Related

- [Power Query ETL](../PowerQuery/)
- [SQL ETL](../SQL/)
- [ETL tips](../../../TipsAndTricks/ETL.md)
- [Deployment pipelines](../../../Deployment/Pipelines/)
