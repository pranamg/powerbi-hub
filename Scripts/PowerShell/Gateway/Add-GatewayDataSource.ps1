<#
.SYNOPSIS
    Add a new data source to a Power BI gateway cluster.

.DESCRIPTION
    Creates a new data source on an on-premises data gateway with specified 
    connection details and credentials.

.PARAMETER GatewayId
    The gateway cluster ID to add the data source to.

.PARAMETER DataSourceName
    Display name for the data source.

.PARAMETER DataSourceType
    Type of data source (SQL, Oracle, File, Web, etc.).

.PARAMETER ConnectionDetails
    Connection string or server/database details as hashtable.

.PARAMETER CredentialType
    Type of credential: Basic, Windows, OAuth2, Key, Anonymous.

.PARAMETER Username
    Username for authentication (if applicable).

.PARAMETER Password
    Password as SecureString (if applicable).

.EXAMPLE
    $connDetails = @{ server = "sqlserver.contoso.com"; database = "SalesDB" }
    $pass = Read-Host -AsSecureString "Password"
    .\Add-GatewayDataSource.ps1 -GatewayId "guid" -DataSourceName "Sales SQL" -DataSourceType "Sql" -ConnectionDetails $connDetails -CredentialType Windows -Username "domain\user" -Password $pass
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$GatewayId,

    [Parameter(Mandatory = $true)]
    [string]$DataSourceName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Sql", "Oracle", "File", "Folder", "SharePointList", "Web", "OData", "ODBC", "AnalysisServices", "PostgreSql", "MySql", "Teradata", "SapHana", "SapBw", "Custom")]
    [string]$DataSourceType,

    [Parameter(Mandatory = $true)]
    [hashtable]$ConnectionDetails,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Basic", "Windows", "OAuth2", "Key", "Anonymous")]
    [string]$CredentialType,

    [Parameter(Mandatory = $false)]
    [string]$Username,

    [Parameter(Mandatory = $false)]
    [SecureString]$Password,

    [Parameter(Mandatory = $false)]
    [ValidateSet("None", "Private", "Organizational", "Public")]
    [string]$PrivacyLevel = "Organizational"
)

#Requires -Modules MicrosoftPowerBIMgmt

function ConvertTo-PlainText {
    param([SecureString]$SecureString)
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Get-ConnectionString {
    param(
        [string]$Type,
        [hashtable]$Details
    )
    
    switch ($Type) {
        "Sql" {
            return @{
                server   = $Details.server
                database = $Details.database
            } | ConvertTo-Json
        }
        "Oracle" {
            return @{
                server = $Details.server
            } | ConvertTo-Json
        }
        "AnalysisServices" {
            return @{
                server   = $Details.server
                database = $Details.database
            } | ConvertTo-Json
        }
        "Web" {
            return @{
                url = $Details.url
            } | ConvertTo-Json
        }
        "OData" {
            return @{
                url = $Details.url
            } | ConvertTo-Json
        }
        "File" {
            return @{
                path = $Details.path
            } | ConvertTo-Json
        }
        "Folder" {
            return @{
                path = $Details.path
            } | ConvertTo-Json
        }
        "SharePointList" {
            return @{
                url = $Details.url
            } | ConvertTo-Json
        }
        default {
            return $Details | ConvertTo-Json
        }
    }
}

try {
    Write-Host "Connecting to Power BI Service..." -ForegroundColor Cyan
    Connect-PowerBIServiceAccount | Out-Null
    
    # Verify gateway exists
    $gateway = Get-PowerBIGatewayCluster -GatewayClusterId $GatewayId
    
    if (-not $gateway) {
        throw "Gateway not found: $GatewayId"
    }
    
    Write-Host "Gateway: $($gateway.Name)" -ForegroundColor Yellow
    
    # Build credential details
    $credentialDetails = @{
        credentialType = $CredentialType
        privacyLevel   = $PrivacyLevel
    }
    
    switch ($CredentialType) {
        "Basic" {
            if (-not $Username -or -not $Password) {
                throw "Username and Password required for Basic authentication"
            }
            $credentialDetails.credentials = @{
                credentialData = @(
                    @{ name = "username"; value = $Username }
                    @{ name = "password"; value = (ConvertTo-PlainText $Password) }
                )
            }
        }
        "Windows" {
            if (-not $Username -or -not $Password) {
                throw "Username and Password required for Windows authentication"
            }
            $credentialDetails.credentials = @{
                credentialData = @(
                    @{ name = "username"; value = $Username }
                    @{ name = "password"; value = (ConvertTo-PlainText $Password) }
                )
            }
        }
        "Key" {
            if (-not $Password) {
                throw "API Key required for Key authentication"
            }
            $credentialDetails.credentials = @{
                credentialData = @(
                    @{ name = "key"; value = (ConvertTo-PlainText $Password) }
                )
            }
        }
        "Anonymous" {
            $credentialDetails.credentials = @{
                credentialData = @()
            }
        }
        "OAuth2" {
            Write-Warning "OAuth2 data sources must be configured through the Power BI portal after creation"
            $credentialDetails = $null
        }
    }
    
    # Build request body
    $body = @{
        datasourceType    = $DataSourceType
        connectionDetails = (Get-ConnectionString -Type $DataSourceType -Details $ConnectionDetails)
        datasourceName    = $DataSourceName
    }
    
    if ($credentialDetails) {
        $body.credentialDetails = $credentialDetails
    }
    
    if ($PSCmdlet.ShouldProcess($DataSourceName, "Create data source on gateway $($gateway.Name)")) {
        # Create via REST API
        $apiUrl = "https://api.powerbi.com/v1.0/myorg/gatewayClusters/$GatewayId/datasources"
        
        $response = Invoke-PowerBIRestMethod -Url $apiUrl -Method Post -Body ($body | ConvertTo-Json -Depth 10)
        $newDs = $response | ConvertFrom-Json
        
        Write-Host "`nData source created successfully!" -ForegroundColor Green
        Write-Host "Name: $DataSourceName"
        Write-Host "Type: $DataSourceType"
        Write-Host "ID: $($newDs.id)"
        Write-Host "Gateway: $($gateway.Name)"
        
        if ($CredentialType -eq "OAuth2") {
            Write-Host "`nIMPORTANT: Complete OAuth2 configuration in Power BI portal" -ForegroundColor Yellow
        }
        
        return $newDs
    }
}
catch {
    Write-Error "Error creating data source: $($_.Exception.Message)"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue
}
