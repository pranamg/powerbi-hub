---
title: Dataset Templates
tags: [modeling, deployment]
audience: [model-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Dataset Templates

> Starting points for new datasets.

## Include

- A folder structure separating source data from the model.
- Parameter tables for values that change per environment.
- A documented refresh schedule.

## Keep out

- Sample data that will survive into production.
- Hard-coded environment names in queries; use a parameter instead.

## Related

- [Dataset examples](../Examples/)
- [Deployment environments](../../../Deployment/Environments/)
- [Parameter patterns](../../../TipsAndTricks/PowerQuery.md)
