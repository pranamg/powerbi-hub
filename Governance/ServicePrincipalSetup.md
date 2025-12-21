# Service Principal Setup Guide

> **Purpose:** Configure Azure AD service principals for Power BI automation and CI/CD

---

## Overview

Service principals enable automated, unattended access to Power BI APIs for:
- CI/CD deployments
- Automated refreshes
- Embedding scenarios
- Administrative automation

---

## Prerequisites

- Azure AD Global Administrator or Application Administrator role
- Power BI Service Administrator role
- Azure subscription (for Key Vault, optional)

---

## Step 1: Create Azure AD Application

### Azure Portal Method

1. Navigate to **Azure Active Directory** > **App registrations**
2. Click **New registration**
3. Configure:
   - **Name:** `PowerBI-Automation-Prod`
   - **Supported account types:** Single tenant
   - **Redirect URI:** Leave blank (for API access)
4. Click **Register**
5. Note the **Application (client) ID** and **Directory (tenant) ID**

### PowerShell Method

```powershell
# Install Azure AD module
Install-Module -Name AzureAD -Scope CurrentUser

# Connect to Azure AD
Connect-AzureAD

# Create application
$app = New-AzureADApplication -DisplayName "PowerBI-Automation-Prod"

# Create service principal
$sp = New-AzureADServicePrincipal -AppId $app.AppId

Write-Host "Application ID: $($app.AppId)"
Write-Host "Service Principal ID: $($sp.ObjectId)"
Write-Host "Tenant ID: $((Get-AzureADTenantDetail).ObjectId)"
```

### Azure CLI Method

```bash
# Login to Azure
az login

# Create app registration with service principal
az ad sp create-for-rbac \
    --name "PowerBI-Automation-Prod" \
    --role "Contributor" \
    --scopes /subscriptions/<subscription-id>

# Output includes appId, password, and tenant
```

---

## Step 2: Create Client Secret or Certificate

### Option A: Client Secret

```powershell
# Create client secret (valid for 2 years)
$endDate = (Get-Date).AddYears(2)
$secret = New-AzureADApplicationPasswordCredential `
    -ObjectId $app.ObjectId `
    -EndDate $endDate

Write-Host "Client Secret: $($secret.Value)"
# IMPORTANT: Save this immediately - it won't be shown again
```

**In Azure Portal:**
1. Go to App registration > **Certificates & secrets**
2. Click **New client secret**
3. Set description and expiration
4. Copy the secret value immediately

### Option B: Certificate (Recommended for Production)

```powershell
# Generate self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=PowerBI-Automation-Prod" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(2)

# Export public key for Azure AD
Export-Certificate -Cert $cert -FilePath "powerbi-automation.cer"

# Export private key for automation server (PFX with password)
$pfxPassword = Read-Host -AsSecureString "Enter PFX password"
Export-PfxCertificate -Cert $cert -FilePath "powerbi-automation.pfx" -Password $pfxPassword

# Upload public certificate to Azure AD
$certData = [System.Convert]::ToBase64String((Get-Item "powerbi-automation.cer").GetRawCertData())
New-AzureADApplicationKeyCredential `
    -ObjectId $app.ObjectId `
    -Type AsymmetricX509Cert `
    -Usage Verify `
    -Value $certData
```

---

## Step 3: Configure Power BI Tenant Settings

### Enable Service Principal Access

1. Go to **Power BI Admin Portal** > **Tenant settings**
2. Find **Developer settings** section
3. Enable **Service principals can use Fabric APIs**
4. Configure scope:
   - **The entire organization** (not recommended)
   - **Specific security groups** (recommended)
5. Add service principal to allowed security group

### Create Security Group for Service Principals

```powershell
# Create security group
$group = New-AzureADGroup `
    -DisplayName "PowerBI-ServicePrincipals" `
    -Description "Service principals allowed to access Power BI APIs" `
    -MailEnabled $false `
    -SecurityEnabled $true `
    -MailNickName "powerbi-sp"

# Add service principal to group
Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $sp.ObjectId

Write-Host "Group ID: $($group.ObjectId)"
```

### Required Tenant Settings

| Setting | Location | Value |
|---------|----------|-------|
| Service principals can use Fabric APIs | Developer settings | Enabled |
| Service principals can access read-only admin APIs | Admin API settings | Enabled |
| Allow service principals to use Power BI APIs | Embed content | Enabled |

---

## Step 4: Assign Workspace Permissions

### Add to Workspace

```powershell
# Add service principal to workspace as Admin
$workspaceId = "workspace-guid"
$spObjectId = $sp.ObjectId

# Using Power BI Management module
Add-PowerBIWorkspaceUser `
    -Id $workspaceId `
    -AccessRight Admin `
    -Identifier $spObjectId `
    -PrincipalType App
```

### Permission Levels

| Role | Capabilities |
|------|-------------|
| Admin | Full control including permissions |
| Member | Create/edit content, no permissions mgmt |
| Contributor | Edit existing content only |
| Viewer | View only |

### REST API Method

```powershell
$body = @{
    identifier = $spObjectId
    groupUserAccessRight = "Admin"
    principalType = "App"
} | ConvertTo-Json

Invoke-PowerBIRestMethod `
    -Url "https://api.powerbi.com/v1.0/myorg/groups/$workspaceId/users" `
    -Method Post `
    -Body $body
```

---

## Step 5: Authentication in Scripts

### PowerShell with Client Secret

```powershell
# Store credentials securely
$tenantId = "your-tenant-id"
$appId = "your-app-id"
$clientSecret = "your-client-secret"  # Use Key Vault in production

# Create credential object
$secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($appId, $secureSecret)

# Connect to Power BI
Connect-PowerBIServiceAccount `
    -ServicePrincipal `
    -TenantId $tenantId `
    -Credential $credential

# Now use Power BI cmdlets
Get-PowerBIWorkspace
```

### PowerShell with Certificate

```powershell
$tenantId = "your-tenant-id"
$appId = "your-app-id"
$certThumbprint = "certificate-thumbprint"

Connect-PowerBIServiceAccount `
    -ServicePrincipal `
    -TenantId $tenantId `
    -ApplicationId $appId `
    -CertificateThumbprint $certThumbprint
```

### Python with MSAL

```python
from msal import ConfidentialClientApplication
import requests

tenant_id = "your-tenant-id"
client_id = "your-app-id"
client_secret = "your-client-secret"

# Create MSAL app
app = ConfidentialClientApplication(
    client_id,
    authority=f"https://login.microsoftonline.com/{tenant_id}",
    client_credential=client_secret
)

# Get token
scopes = ["https://analysis.windows.net/powerbi/api/.default"]
result = app.acquire_token_for_client(scopes=scopes)

if "access_token" in result:
    headers = {
        "Authorization": f"Bearer {result['access_token']}",
        "Content-Type": "application/json"
    }
    
    # Call Power BI API
    response = requests.get(
        "https://api.powerbi.com/v1.0/myorg/groups",
        headers=headers
    )
    print(response.json())
```

### Azure DevOps Pipeline

```yaml
variables:
  - group: PowerBI-ServicePrincipal  # Variable group with secrets

steps:
  - task: PowerShell@2
    displayName: 'Connect to Power BI'
    inputs:
      targetType: 'inline'
      script: |
        $secureSecret = ConvertTo-SecureString "$(ClientSecret)" -AsPlainText -Force
        $credential = New-Object PSCredential("$(AppId)", $secureSecret)
        
        Connect-PowerBIServiceAccount `
            -ServicePrincipal `
            -TenantId "$(TenantId)" `
            -Credential $credential
        
        # Your automation commands here
```

### GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Connect to Power BI
        env:
          TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          APP_ID: ${{ secrets.AZURE_APP_ID }}
          CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
        run: |
          Install-Module -Name MicrosoftPowerBIMgmt -Force
          
          $secureSecret = ConvertTo-SecureString $env:CLIENT_SECRET -AsPlainText -Force
          $credential = New-Object PSCredential($env:APP_ID, $secureSecret)
          
          Connect-PowerBIServiceAccount `
              -ServicePrincipal `
              -TenantId $env:TENANT_ID `
              -Credential $credential
```

---

## Step 6: Secure Secret Management

### Azure Key Vault Integration

```powershell
# Store secret in Key Vault
$vaultName = "kv-powerbi-automation"
$secretName = "PowerBI-SP-Secret"

Set-AzKeyVaultSecret `
    -VaultName $vaultName `
    -Name $secretName `
    -SecretValue $secureSecret

# Retrieve in automation
$secret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName
$credential = New-Object PSCredential($appId, $secret.SecretValue)
```

### Managed Identity (Azure Resources)

```powershell
# On Azure VM or App Service with managed identity
Connect-PowerBIServiceAccount -ManagedIdentity

# No secrets to manage!
```

---

## Service Principal Maintenance

### Monitor Secret Expiration

```powershell
# Check all service principal credentials
$apps = Get-AzureADApplication -All $true

$expiringCreds = foreach ($app in $apps) {
    $creds = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId
    
    foreach ($cred in $creds) {
        if ($cred.EndDate -lt (Get-Date).AddDays(30)) {
            [PSCustomObject]@{
                AppName    = $app.DisplayName
                AppId      = $app.AppId
                CredId     = $cred.KeyId
                ExpiresOn  = $cred.EndDate
                DaysLeft   = ($cred.EndDate - (Get-Date)).Days
            }
        }
    }
}

$expiringCreds | Format-Table
```

### Rotate Secrets

```powershell
# Create new secret before old one expires
$newSecret = New-AzureADApplicationPasswordCredential `
    -ObjectId $app.ObjectId `
    -EndDate (Get-Date).AddYears(2)

# Update automation systems with new secret
# Then remove old secret
Remove-AzureADApplicationPasswordCredential `
    -ObjectId $app.ObjectId `
    -KeyId $oldSecretKeyId
```

---

## Troubleshooting

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| AADSTS7000215 | Invalid client secret | Verify secret, check expiration |
| Unauthorized | Missing permissions | Add SP to workspace, check tenant settings |
| 403 Forbidden | API not enabled | Enable in tenant settings |
| Invalid scope | Wrong token audience | Use correct scope for Power BI |

### Diagnostic Script

```powershell
# Test service principal setup
param($TenantId, $AppId, $ClientSecret)

Write-Host "Testing Service Principal Setup..." -ForegroundColor Cyan

# Test 1: Token acquisition
try {
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $AppId
        client_secret = $ClientSecret
        scope         = "https://analysis.windows.net/powerbi/api/.default"
    }
    
    $response = Invoke-RestMethod `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Method Post `
        -Body $body
    
    Write-Host "✓ Token acquisition successful" -ForegroundColor Green
}
catch {
    Write-Host "✗ Token acquisition failed: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Test 2: Power BI API access
try {
    $headers = @{ Authorization = "Bearer $($response.access_token)" }
    $workspaces = Invoke-RestMethod `
        -Uri "https://api.powerbi.com/v1.0/myorg/groups" `
        -Headers $headers
    
    Write-Host "✓ API access successful ($($workspaces.value.Count) workspaces)" -ForegroundColor Green
}
catch {
    Write-Host "✗ API access failed: $($_.Exception.Message)" -ForegroundColor Red
}
```

---

## Security Best Practices

1. **Use certificates** over secrets for production
2. **Store secrets in Key Vault**, never in code
3. **Use managed identity** when running on Azure
4. **Limit permissions** to minimum required
5. **Rotate secrets** before expiration
6. **Monitor usage** via Azure AD sign-in logs
7. **Use separate SPs** for different environments
8. **Enable conditional access** policies

---

## Related Documents

- [Deployment Pipelines](../Deployment/Pipelines/README.md)
- [PowerShell Scripts](../Scripts/PowerShell/README.md)
- [Audit Procedures](./AuditProcedures.md)

---

*Last Updated: December 2024*
