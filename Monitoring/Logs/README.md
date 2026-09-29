---
title: Logs
tags: [monitoring, operations]
audience: [bi-admin]
difficulty: intermediate
last_verified: 2026-09-29
---

# Logs

> Log collection and analysis.

## Sources

| Source | Contents |
|--------|----------|
| Power BI Service activity log | Workspace, report, and dataset changes in the portal |
| Capacity metrics app | Refresh history, failures, and memory over time |
| Refresh history | Per-dataset refresh status and duration |
| Gateway logs | Gateway availability and connection errors |
| Query and DAX query view | Individually slow queries in Premium/Fabric capacity |

## Guidance

- The **activity log is the audit trail**. Enable and export it if your
  governance programme requires change records, and confirm the retention
  period is adequate.
- Keep **gateway logs** — they are usually the only place a credential or
  connectivity failure is visible in detail.
- Correlate **capacity metrics with refresh schedules** before concluding that
  a refresh was inherently slow. Concurrent refreshes frequently look like a
  single slow one.
- When investigating a slow report, check whether the bottleneck is the model
  or the visual. See [PerformanceTuning](../../Optimization/PerformanceTuning/).

## Related

- [Alerts](../Alerts/) · [Metrics](../Metrics/)
- [Audit procedures](../../Governance/AuditProcedures.md)
