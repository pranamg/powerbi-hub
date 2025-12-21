# Microsoft Fabric Git Integration Guide

> **Purpose:** Step-by-step guide for setting up Git integration with Microsoft Fabric workspaces

---

## Overview

Git integration in Microsoft Fabric enables source control for workspace items including:
- Semantic models (datasets)
- Reports
- Notebooks
- Data pipelines
- Lakehouses
- Warehouses

### Supported Git Providers
- **Azure DevOps** (Azure Repos)
- **GitHub** (including GitHub Enterprise)

---

## Prerequisites

### Tenant Requirements
1. Fabric capacity (F64 or higher) or Power BI Premium
2. Tenant admin must enable Git integration in admin portal

### User Requirements
- Workspace Admin or Member role
- Git repository access (read/write)
- Azure DevOps or GitHub account

### Repository Setup
```
my-fabric-repo/
├── .gitignore
├── README.md
├── workspace-name/
│   ├── Sales Report.Report/
│   ├── Sales Model.SemanticModel/
│   └── ETL Pipeline.DataPipeline/
```

---

## Setup Steps

### Step 1: Enable Git Integration (Admin)

**In Power BI Admin Portal:**
1. Go to **Admin Portal** > **Tenant Settings**
2. Find **Git Integration** section
3. Enable "Users can synchronize workspace items with their Git repositories"
4. Configure allowed Git providers
5. Optionally restrict to specific security groups

### Step 2: Connect Workspace to Repository

**In Fabric Portal:**
1. Open workspace settings (gear icon)
2. Select **Git Integration** tab
3. Click **Connect**
4. Choose provider (Azure DevOps or GitHub)
5. Authenticate and authorize

**Azure DevOps Configuration:**
```
Organization: https://dev.azure.com/your-org
Project: YourProject
Repository: fabric-workspace
Branch: main
Folder: /workspaces/workspace-name
```

**GitHub Configuration:**
```
Repository: your-org/fabric-workspace
Branch: main
Folder: /workspaces/workspace-name
```

### Step 3: Initial Sync

After connecting:
1. Choose sync direction:
   - **Commit to Git**: Push current workspace items to repository
   - **Update from Git**: Pull items from repository to workspace
2. Review changes
3. Confirm sync

---

## Daily Workflows

### Making Changes

```
Developer Workflow:
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Fabric     │ --> │    Git       │ --> │  Code Review │
│   Workspace  │     │  Repository  │     │     & PR     │
└──────────────┘     └──────────────┘     └──────────────┘
        ↓                    ↓                    ↓
   Make changes         Commit            Merge to main
```

### Commit Changes

1. Click **Source Control** in workspace
2. Review changed items (shows diff)
3. Select items to commit
4. Enter commit message
5. Click **Commit**

**Best Practices for Commits:**
```
# Good commit messages
✓ "Add YTD sales measure to Sales Model"
✓ "Fix filter context issue in Regional Report"
✓ "Update ETL pipeline for new data source"

# Avoid vague messages
✗ "Updates"
✗ "Fix bug"
✗ "Changes"
```

### Update from Git

Pull changes made by team members:
1. Click **Source Control** in workspace
2. Click **Update**
3. Review incoming changes
4. Confirm update

### Handle Conflicts

When conflicts occur:
1. Fabric shows conflicting items
2. Choose resolution:
   - **Accept yours**: Keep workspace version
   - **Accept theirs**: Use Git version
   - **Manual merge**: Edit and resolve

---

## Branch Strategy

### Recommended Branch Structure

```
main (production)
├── develop (integration)
│   ├── feature/new-report
│   ├── feature/model-updates
│   └── bugfix/filter-issue
```

### Environment Mapping

| Branch | Workspace | Purpose |
|--------|-----------|---------|
| main | Prod Workspace | Production |
| develop | Dev Workspace | Integration testing |
| feature/* | Personal workspace | Development |

### Working with Branches

**Create Feature Branch:**
```bash
git checkout develop
git checkout -b feature/new-sales-report
```

**In Fabric:**
1. Disconnect workspace from current branch
2. Reconnect to feature branch
3. Make changes
4. Commit to feature branch

**Merge via Pull Request:**
```bash
# Create PR in Azure DevOps/GitHub
# After review and approval, merge to develop
git checkout develop
git merge feature/new-sales-report
```

---

## Item Types & Structure

### Semantic Model (.SemanticModel)

```
Sales Model.SemanticModel/
├── definition.pbism
├── model.bim           # Full model definition
├── .pbi/
│   └── localSettings.json
└── tables/
    ├── Sales.tmdl
    ├── Products.tmdl
    └── Date.tmdl
```

### Report (.Report)

```
Sales Report.Report/
├── definition.pbir
├── report.json         # Report layout
├── .pbi/
│   └── localSettings.json
└── pages/
    ├── Overview.json
    └── Details.json
```

### Data Pipeline (.DataPipeline)

```
ETL Pipeline.DataPipeline/
├── pipeline-content.json
└── .pbi/
    └── localSettings.json
```

### Notebook (.Notebook)

```
Analysis.Notebook/
├── notebook-content.py
└── .pbi/
    └── localSettings.json
```

---

## CI/CD with Git Integration

### Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  fabricWorkspaceId: '$(FABRIC_WORKSPACE_ID)'
  
stages:
  - stage: Validate
    jobs:
      - job: ValidateChanges
        steps:
          - task: PowerShell@2
            displayName: 'Validate TMDL syntax'
            inputs:
              targetType: 'inline'
              script: |
                # Validate semantic model files
                $models = Get-ChildItem -Path "**/*.SemanticModel" -Recurse
                foreach ($model in $models) {
                    Write-Host "Validating: $($model.Name)"
                    # Add validation logic
                }

  - stage: Deploy
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
    jobs:
      - deployment: DeployToProduction
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: PowerShell@2
                  displayName: 'Sync to Production Workspace'
                  inputs:
                    targetType: 'inline'
                    script: |
                      # Trigger workspace sync via REST API
                      $headers = @{
                          "Authorization" = "Bearer $(ACCESS_TOKEN)"
                          "Content-Type" = "application/json"
                      }
                      
                      $body = @{
                          commitMessage = "Deploy $(Build.BuildNumber)"
                      } | ConvertTo-Json
                      
                      Invoke-RestMethod `
                          -Uri "https://api.fabric.microsoft.com/v1/workspaces/$(fabricWorkspaceId)/git/updateFromGit" `
                          -Method Post `
                          -Headers $headers `
                          -Body $body
```

### GitHub Actions

```yaml
# .github/workflows/fabric-deploy.yml
name: Fabric Deployment

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate semantic models
        run: |
          echo "Validating TMDL files..."
          find . -name "*.tmdl" -exec echo "Checking {}" \;

  deploy:
    needs: validate
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Fabric
        env:
          FABRIC_TOKEN: ${{ secrets.FABRIC_TOKEN }}
          WORKSPACE_ID: ${{ secrets.WORKSPACE_ID }}
        run: |
          curl -X POST \
            "https://api.fabric.microsoft.com/v1/workspaces/${WORKSPACE_ID}/git/updateFromGit" \
            -H "Authorization: Bearer ${FABRIC_TOKEN}" \
            -H "Content-Type: application/json" \
            -d '{"commitMessage": "GitHub Actions Deploy"}'
```

---

## Best Practices

### 1. Repository Organization

```
fabric-analytics/
├── README.md
├── .gitignore
├── workspaces/
│   ├── sales-analytics/
│   ├── hr-analytics/
│   └── finance-analytics/
├── shared/
│   ├── themes/
│   └── templates/
└── docs/
    └── architecture.md
```

### 2. .gitignore for Fabric

```gitignore
# Fabric Git Integration
.pbi/localSettings.json
*.pbix
*.pbit

# Temporary files
*.tmp
*~

# IDE files
.vs/
.idea/
.vscode/

# OS files
.DS_Store
Thumbs.db
```

### 3. Avoid Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Large binary files | Use semantic model as TMDL, not PBIX |
| Merge conflicts | Coordinate changes, use feature branches |
| Lost changes | Always commit before disconnecting |
| Sync failures | Check permissions, network connectivity |

### 4. Security Considerations

- Never commit credentials or connection strings
- Use workspace parameters for environment-specific values
- Store secrets in Azure Key Vault
- Review all changes before merging to production

---

## Troubleshooting

### Common Issues

**"Unable to connect to Git"**
- Verify Git provider is enabled in tenant settings
- Check repository URL format
- Ensure authentication is valid

**"Sync failed"**
- Check for merge conflicts
- Verify workspace permissions
- Review item-specific errors in sync log

**"Item not supported"**
- Some legacy items don't support Git integration
- Convert to supported format if possible

**"Changes not appearing"**
- Refresh workspace view
- Check branch is correct
- Verify commit was successful

### Support Resources

- [Microsoft Fabric Git Integration Docs](https://learn.microsoft.com/fabric/cicd/git-integration/intro-to-git-integration)
- [Fabric REST API Reference](https://learn.microsoft.com/rest/api/fabric/)
- [Azure DevOps Integration Guide](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-with-azure-devops)

---

## Related Resources

- [TMDL View Guide](./TMDLView.md)
- [Deployment Pipelines](../../Deployment/Pipelines/README.md)
- [Development Standards](../../Governance/DevelopmentStandards.md)

---

*Last Updated: December 2024*
