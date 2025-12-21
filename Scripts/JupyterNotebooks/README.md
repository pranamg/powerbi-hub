# Power BI Python Automation

> Jupyter notebooks and Python scripts for Power BI automation

## Prerequisites

```bash
pip install msal requests pandas jupyter
```

## Notebooks

| Notebook | Description |
|----------|-------------|
| [PowerBI_REST_API.ipynb](./PowerBI_REST_API.ipynb) | Interactive API examples |

## Quick Start

### Authentication Setup

Create a `.env` file (add to .gitignore):
```bash
PBI_TENANT_ID=your-tenant-id
PBI_APP_ID=your-app-id
PBI_CLIENT_SECRET=your-client-secret
```

Load in Python:
```python
from dotenv import load_dotenv
load_dotenv()
```

### Basic Usage

```python
from powerbi_client import PowerBIClient

client = PowerBIClient.from_env()

# List workspaces
workspaces = client.get_workspaces()

# Refresh dataset
client.refresh_dataset(workspace_id, dataset_id)

# Execute DAX query
result = client.execute_dax(workspace_id, dataset_id, "EVALUATE 'Table'")
```

## API Reference

### REST API Endpoints

| Operation | Endpoint |
|-----------|----------|
| List Workspaces | `GET /groups` |
| List Datasets | `GET /groups/{workspaceId}/datasets` |
| Refresh Dataset | `POST /groups/{workspaceId}/datasets/{datasetId}/refreshes` |
| Execute DAX | `POST /groups/{workspaceId}/datasets/{datasetId}/executeQueries` |

### Authentication

Uses MSAL (Microsoft Authentication Library) with client credentials flow:

```python
from msal import ConfidentialClientApplication

app = ConfidentialClientApplication(
    client_id,
    authority=f"https://login.microsoftonline.com/{tenant_id}",
    client_credential=client_secret
)

token = app.acquire_token_for_client(
    scopes=["https://analysis.windows.net/powerbi/api/.default"]
)
```

## Common Tasks

### Bulk Refresh All Datasets
```python
for workspace in client.get_workspaces():
    for dataset in client.get_datasets(workspace['id']):
        if dataset['isRefreshable']:
            client.refresh_dataset(workspace['id'], dataset['id'])
```

### Export Inventory to Excel
```python
import pandas as pd

inventory = client.get_inventory()
with pd.ExcelWriter('inventory.xlsx') as writer:
    pd.DataFrame(inventory['workspaces']).to_excel(writer, sheet_name='Workspaces')
    pd.DataFrame(inventory['datasets']).to_excel(writer, sheet_name='Datasets')
```

## Related Resources

- [Power BI REST API Docs](https://learn.microsoft.com/rest/api/power-bi/)
- [MSAL Python](https://github.com/AzureAD/microsoft-authentication-library-for-python)
- [PowerShell Scripts](../PowerShell/)
