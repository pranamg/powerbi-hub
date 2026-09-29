---
title: Architecture Diagrams
tags: [architecture, documentation]
audience: [all]
difficulty: intermediate
last_verified: 2026-09-29
---

# Architecture Diagrams

> Reference diagrams for solution architecture.

## Suggested coverage

Diagrams that are worth keeping current:

- The end-to-end flow from source systems to dataflows or pipelines, through
  the semantic model, to reports and downstream consumers.
- A **composite model** diagram showing which tables are Import and which are
  DirectQuery, and where the boundary sits.
- A gateway and data flow topology, including which credentials live where.
- Service principal and identity flows for automated deployment.

## Keeping them useful

- Prefer a **source format that is editable** (Mermaid, draw.io, or PlantUML)
  over a static image, so diagrams can be corrected when the design changes.
- Give each diagram a **date and an owner**. An undated architecture diagram
  is a liability.
- Check a diagram against reality before trusting it; they are usually the
  first documentation to drift.

## Related

- [Design documents](../DesignDocuments/)
- [Integrations](../../Integrations/)
- [Setup](../Setup/)
