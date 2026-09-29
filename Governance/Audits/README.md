# Audits

> Audit checklists, cadence, and findings.

## What to audit

| Area | Check |
|------|-------|
| Access | Workspace roles match current job responsibilities |
| Ownership | Every dataset and report has a named owner |
| Freshness | Datasets refresh on schedule and are not silently failing |
| Data classification | Sensitive data is labelled and access is restricted |
| Orphaned content | Unused reports and datasets are identified for removal |
| Deployment | Changes to production went through the pipeline |

## Cadence

- **Access** — quarterly, and immediately after an organisation change.
- **Ownership and freshness** — monthly.
- **Classification and compliance** — aligned to the regulatory calendar.

Record the date, the scope, who performed the review, and the outcome for each
audit. An audit with no recorded result is indistinguishable from one that
never happened.

## Findings

Track findings to closure with a named owner and a due date. Recurring
findings indicate a control problem rather than a one-off mistake, and are
worth escalating.

## Related

- [Audit procedures](../AuditProcedures.md)
- [Compliance](../Compliance/)
- [Access control matrix](../AccessControlMatrix.md)
