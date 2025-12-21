# Power BI PowerShell Scripts

> Automation scripts for Power BI administration, deployment, and management

## Prerequisites

### Required Modules
```powershell
# Install Power BI Management Module
Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser

# For Azure authentication
Install-Module -Name Az.Accounts -Scope CurrentUser

# Verify installation
Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable
```

### Authentication
```powershell
# Interactive login
Connect-PowerBIServiceAccount

# Service principal login
$securePassword = ConvertTo-SecureString "ClientSecret" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("AppId", $securePassword)
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId "TenantId"
```

## Script Categories

| Folder | Purpose |
|--------|---------|
| [Workspace/](./Workspace/) | Workspace creation, permissions, migration |
| [Dataset/](./Dataset/) | Refresh, parameters, credentials |
| [Gateway/](./Gateway/) | Gateway management and data sources |
| [Admin/](./Admin/) | Tenant-wide administration |
| [Reports/](./Reports/) | Report deployment and management |

## Quick Start

### Get All Workspaces
```powershell
Get-PowerBIWorkspace -Scope Organization -All | Format-Table Name, Id, Type
```

### Refresh a Dataset
```powershell
Invoke-PowerBIRestMethod -Url "groups/{workspaceId}/datasets/{datasetId}/refreshes" -Method Post
```

### Export Report
```powershell
Export-PowerBIReport -WorkspaceId $workspaceId -Id $reportId -OutFile "report.pbix"
```

## Environment Variables

Set these for unattended scripts:
```powershell
$env:PBI_TENANT_ID = "your-tenant-id"
$env:PBI_APP_ID = "your-app-id"
$env:PBI_APP_SECRET = "your-client-secret"
```

## Error Handling Pattern

All scripts use this pattern:
```powershell
try {
    Connect-PowerBIServiceAccount -ErrorAction Stop
    # Operations...
}
catch {
    Write-Error "Failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Disconnect-PowerBIServiceAccount
}
```

## Related Resources

- [Power BI REST API](https://learn.microsoft.com/rest/api/power-bi/)
- [PowerShell Cmdlet Reference](https://learn.microsoft.com/powershell/power-bi/overview)
- [Deployment Pipelines](../../Deployment/Pipelines/)
