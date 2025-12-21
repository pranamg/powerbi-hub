# Microsoft Fabric Integration Patterns

> **Purpose:** Patterns and guides for integrating Power BI with Microsoft Fabric components

---

## Overview

Microsoft Fabric is a unified analytics platform that brings together data engineering, data science, real-time analytics, and business intelligence. Power BI is the BI workload within Fabric.

## Fabric Components

| Component | Description | Power BI Integration |
|-----------|-------------|---------------------|
| **Lakehouse** | Unified data lake + warehouse | Direct Lake mode |
| **Dataflow Gen2** | Data preparation | Semantic model source |
| **Data Warehouse** | Enterprise DW | DirectQuery/Import |
| **OneLake** | Unified storage | Shortcuts, Direct Lake |
| **Real-Time Analytics** | Streaming data | Real-time dashboards |
| **Notebooks** | Data science | ML integration |

---

## Contents

```
Fabric/
├── README.md           (this file)
├── Lakehouse.md        # Lakehouse patterns
├── DataflowGen2.md     # Dataflow Gen2 templates
├── DirectLake.md       # Direct Lake setup
└── OneLake.md          # OneLake integration
```

---

## Quick Reference

### When to Use What

| Scenario | Recommended Component |
|----------|----------------------|
| Ad-hoc exploration | Lakehouse + Direct Lake |
| Enterprise reporting | Data Warehouse + DirectQuery |
| Self-service prep | Dataflow Gen2 |
| Real-time dashboards | KQL Database + Eventstreams |
| Large dataset (>1TB) | Direct Lake |
| Complex transformations | Data Warehouse/Lakehouse |

### Performance Modes

| Mode | Description | Best For |
|------|-------------|----------|
| Import | In-memory | Small datasets, best performance |
| DirectQuery | Query on demand | Real-time, large data |
| Direct Lake | Parquet to memory | Best of both worlds |

---

## Prerequisites

- Microsoft Fabric capacity (F2+) or Power BI Premium (P1+)
- Fabric workspace (not classic)
- OneLake access

---

## Related Resources

- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- [Power BI in Fabric](https://learn.microsoft.com/power-bi/fundamentals/fabric-get-started)
- [Direct Lake Overview](https://learn.microsoft.com/power-bi/enterprise/directlake-overview)
