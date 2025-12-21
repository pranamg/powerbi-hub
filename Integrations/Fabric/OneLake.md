# OneLake Integration

> **Purpose:** Patterns for integrating Power BI with OneLake unified storage

---

## Overview

OneLake is Microsoft Fabric's unified data lake - a single logical data lake for your entire organization built on Azure Data Lake Storage Gen2.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Workspace** | Container for Fabric items |
| **Lakehouse/Warehouse** | Data storage items |
| **Tables** | Managed Delta tables |
| **Files** | Unmanaged file storage |
| **Shortcuts** | Pointers to external data |

---

## OneLake Structure

```
OneLake (Tenant Level)
├── Workspace: Sales Analytics
│   ├── Lakehouse: Sales Data
│   │   ├── Tables/
│   │   │   ├── DimCustomer/
│   │   │   ├── DimProduct/
│   │   │   └── FactSales/
│   │   └── Files/
│   │       ├── Incoming/
│   │       └── Archive/
│   └── Semantic Model: Sales Report
│
└── Workspace: Finance Analytics
    ├── Warehouse: Finance DW
    │   ├── dbo.DimAccount
    │   └── dbo.FactGL
    └── Shortcuts/
        └── → Sales Data/Tables/FactSales (shortcut)
```

---

## Shortcuts

### What are Shortcuts?

Shortcuts are pointers to data that allow accessing data without copying:
- **Internal shortcuts:** Point to other OneLake locations
- **External shortcuts:** Point to ADLS Gen2, S3, GCS

### Creating Internal Shortcut

1. Open target Lakehouse
2. Right-click Tables or Files folder
3. Select "New shortcut"
4. Choose "Microsoft OneLake"
5. Select source Lakehouse/table
6. Name the shortcut

### Creating External Shortcut (ADLS Gen2)

1. Open target Lakehouse
2. Right-click Files folder
3. Select "New shortcut"
4. Choose "Azure Data Lake Storage Gen2"
5. Provide:
   - Connection name
   - URL: `https://<account>.dfs.core.windows.net/<container>`
   - Authentication method
   - Shortcut name
   - Subpath (optional)

### External Shortcut (S3)

```
URL format: s3://<bucket-name>/<path>
Authentication: Access key or IAM role
```

### Shortcut Use Cases

| Use Case | Benefit |
|----------|---------|
| Cross-workspace data sharing | No data duplication |
| External data virtualization | Query external data in place |
| Data mesh architecture | Domain ownership with sharing |
| Migration scenarios | Gradual data movement |

---

## Access Patterns

### Pattern 1: Centralized Data, Distributed Analysis

```
Central Lakehouse (Data Engineering)
├── Tables/
│   ├── DimDate
│   ├── DimProduct
│   └── FactSales
            │
            │ Shortcuts
            ▼
┌─────────────────────────────────────────┐
│                                         │
▼                ▼                ▼       │
Sales LH      Marketing LH     Finance LH │
(Shortcut)    (Shortcut)       (Shortcut) │
    │              │                │     │
    ▼              ▼                ▼     │
Sales Model   Marketing Model  Finance Model
```

### Pattern 2: Data Mesh with Domains

```
Sales Domain                    Finance Domain
├── Sales Lakehouse             ├── Finance Lakehouse
│   ├── Raw/                    │   ├── Raw/
│   ├── Curated/                │   ├── Curated/
│   └── Published/──────────────┼───┤ Shortcuts ◄─┘
│       └── FactSales           │   
│                               │
└── Sales Reports               └── Finance Reports
```

### Pattern 3: Landing Zone Architecture

```
External Systems
      │
      ▼
Landing Zone Lakehouse
├── Files/
│   ├── SAP/ (External ADLS Shortcut)
│   ├── Salesforce/ (External S3 Shortcut)
│   └── Oracle/ (External ADLS Shortcut)
      │
      │ Processing
      ▼
Curated Lakehouse
├── Tables/
│   ├── Bronze/
│   ├── Silver/
│   └── Gold/
```

---

## Accessing OneLake from Power BI

### Direct Lake Mode

See [DirectLake.md](./DirectLake.md) for detailed setup.

### Dataflow Gen2

1. Create new Dataflow Gen2
2. Get Data → OneLake data hub
3. Select Lakehouse tables
4. Apply transformations
5. Output to destination

### Power Query (Desktop)

```powerquery
let
    Source = AzureDataLakeStorage.Contents(
        "https://onelake.dfs.fabric.microsoft.com/<workspace-guid>/<lakehouse-guid>/Tables"
    ),
    FactSales = Source{[Name="FactSales"]}[Content],
    ImportedTable = Parquet.Tables(FactSales)
in
    ImportedTable
```

---

## OneLake APIs

### REST API Access

```python
import requests

# Get access token
# Using Azure Identity
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
token = credential.get_token("https://storage.azure.com/.default")

# List files
url = "https://onelake.dfs.fabric.microsoft.com/<workspace>/<item>/Files"
headers = {"Authorization": f"Bearer {token.token}"}

response = requests.get(url, headers=headers)
print(response.json())
```

### OneLake File Explorer

Desktop application for browsing OneLake:
1. Download from Microsoft Store
2. Sign in with Microsoft account
3. Browse workspaces and items
4. Copy paths for use in scripts

### OneLake Path Formats

| Context | Path Format |
|---------|-------------|
| HTTPS | `https://onelake.dfs.fabric.microsoft.com/<workspace>/<item>/Tables/` |
| ABFS | `abfss://<workspace>@onelake.dfs.fabric.microsoft.com/<item>/Tables/` |
| File Explorer | `\\onelake.dfs.fabric.microsoft.com\<workspace>\<item>\Tables\` |

---

## Security

### Workspace Permissions

| Role | OneLake Access |
|------|---------------|
| Admin | Full control |
| Member | Read/Write |
| Contributor | Read/Write (content only) |
| Viewer | Read only |

### Item-Level Permissions

Can be configured per Lakehouse/Warehouse:
- Read
- ReadAll (bypass RLS)
- Write
- Execute
- ReadMetadata

### Shortcut Security

- Shortcuts inherit permissions from target
- External shortcuts use configured credentials
- OneLake shortcuts use Fabric permissions

---

## Best Practices

### Organization

1. **Use naming conventions**
   - Workspaces: `<Domain>-<Environment>`
   - Lakehouses: `<Domain>-Data-<Purpose>`

2. **Folder structure**
   ```
   Files/
   ├── Landing/
   ├── Staging/
   ├── Archive/
   └── Reference/
   ```

### Performance

1. **Use shortcuts over copies** when possible
2. **Partition large tables** by date
3. **Maintain Delta tables** with OPTIMIZE/VACUUM

### Governance

1. **Document shortcuts** and their sources
2. **Regular access reviews**
3. **Monitor usage** via admin APIs

---

## Troubleshooting

### Common Issues

**"Shortcut not found"**
- Check source still exists
- Verify permissions on source
- Refresh metadata

**"Access denied"**
- Check workspace role
- Verify item permissions
- For external, check credential validity

**"Data not current"**
- Shortcuts are metadata only
- Check source data freshness
- Run Delta OPTIMIZE on source

---

## Related Documents

- [Lakehouse Patterns](./Lakehouse.md)
- [Direct Lake Setup](./DirectLake.md)
- [Dataflow Gen2](./DataflowGen2.md)

---

*Last Updated: December 2024*
