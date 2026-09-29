---
title: Metrics
tags: [monitoring, operations]
audience: [bi-admin]
difficulty: intermediate
last_verified: 2026-09-29
---

# Metrics

> KPIs and usage metrics for the Power BI estate.

## Estate metrics

| Metric | Why it matters |
|--------|----------------|
| Datasets by refresh status | Failed or never-refreshed datasets are invisible failures |
| Report usage and active users | Identifies unused content worth retiring |
| Capacity memory utilisation | The leading indicator of a capacity problem |
| Refresh duration trend | Spots degradation before it becomes an outage |
| Unused content count | The usual answer to "the estate has grown too large" |

## Reporting guidance

- **Track trends, not point values.** A single day's memory figure says little.
- Segment by **environment and owning team**, since aggregate figures hide the
  problem.
- Pair usage metrics with an **ownership register**. High usage on an
  unowned dataset is a risk as much as a success.

## Related

- [Alerts](../Alerts/) · [Logs](../Logs/)
- [Admin inventory script](../../Scripts/PowerShell/Admin/Get-TenantInventory.ps1)
- [Memory optimization](../../Optimization/MemoryOptimization/)
