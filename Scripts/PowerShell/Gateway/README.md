# Gateway Management Scripts

PowerShell scripts for managing Power BI on-premises data gateways.

## Prerequisites

```powershell
# Install required module
Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser

# Connect to Power BI (required before running scripts)
Connect-PowerBIServiceAccount
```

## Scripts

### Get-GatewayStatus.ps1

Retrieve gateway cluster status, member health, and data source information.

```powershell
# Get all gateways
.\Get-GatewayStatus.ps1

# Get specific gateway with data sources
.\Get-GatewayStatus.ps1 -GatewayId "guid-here" -IncludeDataSources

# Export to JSON
.\Get-GatewayStatus.ps1 -OutputPath "gateway-status.json"
```

**Output includes:**
- Cluster name and type
- Gateway version
- Member count and online status
- Individual member details
- Data source inventory (optional)

### Add-GatewayDataSource.ps1

Create new data sources on a gateway cluster.

```powershell
# SQL Server data source with Windows auth
$connDetails = @{
    server   = "sqlserver.contoso.com"
    database = "SalesDB"
}
$password = Read-Host -AsSecureString "Password"

.\Add-GatewayDataSource.ps1 `
    -GatewayId "gateway-guid" `
    -DataSourceName "Sales SQL Server" `
    -DataSourceType "Sql" `
    -ConnectionDetails $connDetails `
    -CredentialType Windows `
    -Username "DOMAIN\ServiceAccount" `
    -Password $password

# Oracle data source
$oracleConn = @{ server = "oracle.contoso.com:1521/ORCL" }
.\Add-GatewayDataSource.ps1 `
    -GatewayId "gateway-guid" `
    -DataSourceName "Oracle Sales" `
    -DataSourceType "Oracle" `
    -ConnectionDetails $oracleConn `
    -CredentialType Basic `
    -Username "schema_user" `
    -Password $password

# Web API with anonymous access
$webConn = @{ url = "https://api.example.com/data" }
.\Add-GatewayDataSource.ps1 `
    -GatewayId "gateway-guid" `
    -DataSourceName "Public API" `
    -DataSourceType "Web" `
    -ConnectionDetails $webConn `
    -CredentialType Anonymous
```

**Supported Data Source Types:**
| Type | Connection Details |
|------|-------------------|
| Sql | server, database |
| Oracle | server |
| AnalysisServices | server, database |
| Web | url |
| OData | url |
| File | path |
| Folder | path |
| SharePointList | url |
| PostgreSql | server, database |
| MySql | server, database |

### Update-GatewayDataSource.ps1

Update credentials for existing data sources.

```powershell
# Update SQL Server credentials
$newPassword = Read-Host -AsSecureString "New password"

.\Update-GatewayDataSource.ps1 `
    -GatewayId "gateway-guid" `
    -DataSourceId "datasource-guid" `
    -CredentialType Windows `
    -Username "DOMAIN\NewServiceAccount" `
    -Password $newPassword `
    -PrivacyLevel Organizational
```

**Credential Types:**
- `Basic` - Username/password
- `Windows` - Windows authentication
- `Key` - API key authentication
- `Anonymous` - No credentials
- `OAuth2` - Must be configured in portal

**Privacy Levels:**
- `None` - No privacy level
- `Private` - Private data
- `Organizational` - Organization-wide access
- `Public` - Public data

## Common Workflows

### Inventory All Gateways

```powershell
# Get comprehensive gateway inventory
$gateways = .\Get-GatewayStatus.ps1 -IncludeDataSources

# Export to CSV for reporting
$gateways | ForEach-Object {
    $gateway = $_
    $_.Members | ForEach-Object {
        [PSCustomObject]@{
            GatewayName   = $gateway.ClusterName
            GatewayType   = $gateway.Type
            MemberName    = $_.MachineName
            Status        = $_.Status
            Version       = $_.Version
            DataSources   = $gateway.DataSources.Count
        }
    }
} | Export-Csv "gateway-inventory.csv" -NoTypeInformation
```

### Health Check Script

```powershell
# Check for offline gateways
$gateways = .\Get-GatewayStatus.ps1

$unhealthy = $gateways | Where-Object {
    $_.OnlineMembers -lt $_.MemberCount -or $_.OnlineMembers -eq 0
}

if ($unhealthy) {
    Write-Warning "Unhealthy gateways detected!"
    $unhealthy | ForEach-Object {
        Write-Host "  $($_.ClusterName): $($_.OnlineMembers)/$($_.MemberCount) online"
    }
}
```

### Bulk Credential Update

```powershell
# Update credentials for all SQL data sources on a gateway
$gatewayId = "your-gateway-guid"
$newPassword = Read-Host -AsSecureString "New service account password"
$newUsername = "DOMAIN\NewServiceAccount"

$gateway = .\Get-GatewayStatus.ps1 -GatewayId $gatewayId -IncludeDataSources

$gateway.DataSources | Where-Object { $_.DataSourceType -eq "Sql" } | ForEach-Object {
    Write-Host "Updating: $($_.DataSourceName)"
    .\Update-GatewayDataSource.ps1 `
        -GatewayId $gatewayId `
        -DataSourceId $_.DataSourceId `
        -CredentialType Windows `
        -Username $newUsername `
        -Password $newPassword
}
```

## Troubleshooting

### Common Errors

**"Gateway not found"**
- Verify you have admin access to the gateway
- Check the gateway ID is correct
- Ensure gateway is registered in your tenant

**"Unauthorized"**
- Re-authenticate: `Connect-PowerBIServiceAccount`
- Verify you're a gateway admin
- Check tenant settings allow gateway management

**"Invalid credentials"**
- Verify credential type matches data source requirements
- Test credentials manually first
- Check password doesn't contain special characters that need escaping

### Gateway Permissions

To manage gateways, you need one of:
- Gateway admin role (assigned in Power BI portal)
- Power BI Service administrator role
- Owner of the gateway cluster

## Related Resources

- [Power BI Gateway Documentation](https://docs.microsoft.com/power-bi/connect-data/service-gateway-onprem)
- [Gateway REST API Reference](https://docs.microsoft.com/rest/api/power-bi/gateways)
- [MicrosoftPowerBIMgmt Module](https://docs.microsoft.com/powershell/power-bi/overview)
