---
title: Web
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Web

> Web, OData, and REST-based sources.

## Practice

- Prefer an **OData or shared semantic model endpoint** over a custom JSON
  query where one exists; it brings typing, pagination, and incremental
  refresh with it.
- Set an explicit **API limit / page size** for paginated endpoints.
- Avoid hard-coding URLs. Use a parameter table so the endpoint can change per
  environment. See [TipsAndTricks/PowerQuery](../../../TipsAndTricks/PowerQuery.md).
- Send an API version and an authentication header explicitly, and keep
  credentials in a gateway.
- Handle rate limits and transient failures, since a refresh that fails on a
  timeout is a common source of stale data.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [JSON](../JSON/)
- [Azure services](../../../Integrations/AzureServices/)
- [Integration patterns](../../../Integrations/)
