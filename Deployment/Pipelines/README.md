# Power BI Deployment Pipelines

> CI/CD templates for automated Power BI deployments

## Available Templates

| Template | Platform | Description |
|----------|----------|-------------|
| [azure-pipelines.yml](./azure-pipelines.yml) | Azure DevOps | Multi-stage deployment pipeline |
| [github-actions.yml](./github-actions.yml) | GitHub Actions | Workflow for GitHub repositories |

## Prerequisites

### Service Principal Setup

1. **Register an App in Azure AD:**
   ```
   Azure Portal → App registrations → New registration
   Name: "Power BI Deployment SP"
   ```

2. **Create Client Secret:**
   ```
   App → Certificates & secrets → New client secret
   ```

3. **Grant Power BI Permissions:**
   ```
   Power BI Admin Portal → Tenant settings → 
   Service principals can use Fabric APIs → Enable
   Add your security group
   ```

4. **Add SP to Workspaces:**
   ```
   Workspace → Manage access → Add service principal as Admin/Member
   ```

### Required Secrets

#### Azure DevOps
Create a variable group named `powerbi-{environment}`:
| Variable | Description |
|----------|-------------|
| `PBI_TENANT_ID` | Azure AD tenant ID |
| `PBI_APP_ID` | Service principal application ID |
| `PBI_CLIENT_SECRET` | Service principal secret (mark as secret) |
| `PBI_WORKSPACE_ID` | Target workspace ID |
| `PBI_DATASET_ID` | Dataset ID for refresh (optional) |

#### GitHub Actions
Add repository secrets:
- `PBI_TENANT_ID`
- `PBI_APP_ID`
- `PBI_CLIENT_SECRET`
- `DEV_WORKSPACE_ID`
- `PROD_WORKSPACE_ID`
- `DEV_DATASET_ID`
- `PROD_DATASET_ID`

## Deployment Strategies

### 1. TMDL-Based (Recommended)

Deploy semantic models as TMDL folders:
```
models/
├── model.tmdl
├── tables/
│   ├── Sales.tmdl
│   └── Product.tmdl
└── relationships.tmdl
```

Uses XMLA endpoint for deployment (requires Premium/Fabric).

### 2. PBIX-Based

Deploy complete .pbix files:
```
reports/
├── SalesDashboard.pbix
└── FinanceReport.pbix
```

Uses Power BI REST API.

### 3. Hybrid

Separate semantic model (TMDL) from thin reports (PBIX with live connection).

## Pipeline Flow

```
┌─────────────┐
│   Trigger   │ (push/manual)
└──────┬──────┘
       │
┌──────▼──────┐
│  Validate   │ (TMDL syntax, secrets scan)
└──────┬──────┘
       │
┌──────▼──────┐
│  Deploy     │ (model + reports)
│  to DEV     │
└──────┬──────┘
       │
┌──────▼──────┐
│  Manual     │ (approval gate)
│  Approval   │
└──────┬──────┘
       │
┌──────▼──────┐
│  Deploy     │
│  to PROD    │
└──────┬──────┘
       │
┌──────▼──────┐
│  Refresh &  │ (optional)
│  Notify     │
└─────────────┘
```

## Environment Configuration

Create environment-specific config files:

```yaml
# config/dev.yml
workspace_id: "guid-dev"
dataset_name: "Sales Model - DEV"
parameters:
  ServerName: "dev-sql.database.windows.net"
  DatabaseName: "SalesDB_Dev"

# config/prod.yml
workspace_id: "guid-prod"
dataset_name: "Sales Model"
parameters:
  ServerName: "prod-sql.database.windows.net"
  DatabaseName: "SalesDB"
```

## Tabular Editor Integration

For TMDL deployment, add Tabular Editor CLI:

```yaml
- task: PowerShell@2
  displayName: 'Deploy with Tabular Editor'
  inputs:
    targetType: 'inline'
    script: |
      # Install Tabular Editor CLI
      dotnet tool install -g TabularEditor.TOMWrapper.NetCore
      
      # Deploy model
      tabular-editor `
        "$(modelPath)" `
        "powerbi://api.powerbi.com/v1.0/myorg/$(workspaceName)" `
        "$(datasetName)" `
        -W
```

## Best Practices

### 1. Use Separate Workspaces per Environment
```
├── Sales Analytics - DEV
├── Sales Analytics - TEST
└── Sales Analytics - PROD
```

### 2. Parameter-Driven Connections
Don't hardcode connection strings. Use parameters:
```dax
expression ServerName = "prod-server" meta [IsParameterQuery=true]
```

### 3. Pre-Deployment Validation
- TMDL syntax check
- Secrets/credential scan
- Best Practice Analyzer rules

### 4. Post-Deployment Verification
- Trigger test refresh
- Validate data connectivity
- Check row counts match expectations

### 5. Rollback Strategy
- Keep previous PBIX versions in storage
- Tag Git releases
- Document rollback procedures

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Unauthorized" | Check SP permissions in workspace |
| "Dataset not found" | Verify dataset ID matches target environment |
| "Refresh failed" | Check data source credentials |
| "XMLA not available" | Requires Premium/Fabric capacity |

## Related Resources

- [PowerShell Scripts](../../Scripts/PowerShell/)
- [TMDL Documentation](../../Scripts/TMDL/)
- [Environment Config](../Environments/)
