---
title: XML
tags: [data-connections, power-query]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# XML

> XML file sources.

## Practice

- Use **Table.Transform** rather than a manual expansion where possible. It
  keeps the result tabular and avoids a deep nested structure.
- Expand the root element and then the attributes you need. Expanding
  everything produces a very wide table that is slow to refresh.
- Be deliberate about element versus attribute data; mixing both in one
  source often needs a normalisation step.

XML sources are relatively rare in analytics. If the system can also emit CSV
or JSON, prefer that.

## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [JSON](../JSON/)
- [Data sources folder](../)
