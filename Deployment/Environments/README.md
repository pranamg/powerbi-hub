# Environment Configuration

> **Purpose:** Manage environment-specific settings for Power BI deployments

---

## Overview

Environment configuration files help manage different settings across Development, Test, and Production environments without modifying the core artifacts.

## Directory Structure

```
Environments/
├── README.md
├── dev.json           # Development settings
├── test.json          # Test/QA settings
├── prod.json          # Production settings
└── local.json.template # Template for local development
```

---

## Configuration Files

### Environment Settings Schema

```json
{
  "$schema": "./env-schema.json",
  "environment": "dev|test|prod",
  "workspace": {
    "id": "workspace-guid",
    "name": "Workspace Name"
  },
  "connections": {
    "sqlServer": {
      "server": "server.database.windows.net",
      "database": "database-name"
    }
  },
  "parameters": {
    "parameterName": "value"
  },
  "features": {
    "featureName": true|false
  }
}
```

---

## Usage

### PowerShell Deployment

```powershell
# Load environment config
$env = Get-Content "./Environments/$Environment.json" | ConvertFrom-Json

# Update dataset parameters
.\Scripts\PowerShell\Dataset\Update-DatasetParameters.ps1 `
    -WorkspaceId $env.workspace.id `
    -DatasetName "Sales Model" `
    -Parameters @{
        ServerName = $env.connections.sqlServer.server
        DatabaseName = $env.connections.sqlServer.database
    }
```

### CI/CD Pipeline

```yaml
# Azure DevOps
variables:
  - name: configFile
    value: 'Environments/$(Environment).json'

steps:
  - task: PowerShell@2
    inputs:
      script: |
        $config = Get-Content "$(configFile)" | ConvertFrom-Json
        Write-Host "Deploying to: $($config.environment)"
```

---

## Security Notes

- Never commit sensitive values (passwords, keys)
- Use Azure Key Vault for secrets
- Use variable groups in pipelines for credentials
- Keep `local.json` in `.gitignore`
