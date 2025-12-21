<#
.SYNOPSIS
    Update data source credentials on a Power BI gateway.

.DESCRIPTION
    Updates connection credentials for gateway data sources. Supports various 
    credential types including Basic, Windows, OAuth2, and Key authentication.

.PARAMETER GatewayId
    The gateway cluster ID containing the data source.

.PARAMETER DataSourceId
    The specific data source ID to update.

.PARAMETER CredentialType
    Type of credential: Basic, Windows, OAuth2, Key, Anonymous.

.PARAMETER Username
    Username for Basic or Windows authentication.

.PARAMETER Password
    Password as SecureString for Basic or Windows authentication.

.PARAMETER PrivacyLevel
    Privacy level: None, Private, Organizational, Public.

.EXAMPLE
    $securePass = Read-Host -AsSecureString "Enter password"
    .\Update-GatewayDataSource.ps1 -GatewayId "guid" -DataSourceId "guid" -CredentialType Basic -Username "user" -Password $securePass
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$GatewayId,

    [Parameter(Mandatory = $true)]
    [string]$DataSourceId,

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

try {
    Write-Host "Connecting to Power BI Service..." -ForegroundColor Cyan
    Connect-PowerBIServiceAccount | Out-Null
    
    # Get gateway public key for encryption
    $gateway = Get-PowerBIGatewayCluster -GatewayClusterId $GatewayId
    
    if (-not $gateway) {
        throw "Gateway not found: $GatewayId"
    }
    
    # Get current data source info
    $dataSource = Get-PowerBIGatewayClusterDatasource -GatewayClusterId $GatewayId |
        Where-Object { $_.Id -eq $DataSourceId }
    
    if (-not $dataSource) {
        throw "Data source not found: $DataSourceId"
    }
    
    Write-Host "Updating data source: $($dataSource.DatasourceName)" -ForegroundColor Yellow
    Write-Host "Type: $($dataSource.DatasourceType)"
    
    # Build credential details based on type
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
                throw "Password (API Key) required for Key authentication"
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
            Write-Warning "OAuth2 credentials must be updated through the Power BI portal"
            return
        }
    }
    
    if ($PSCmdlet.ShouldProcess($dataSource.DatasourceName, "Update credentials")) {
        # Update via REST API
        $apiUrl = "https://api.powerbi.com/v1.0/myorg/gatewayClusters/$GatewayId/datasources/$DataSourceId"
        
        $body = @{
            credentialDetails = $credentialDetails
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-PowerBIRestMethod -Url $apiUrl -Method Patch -Body $body
        
        Write-Host "`nCredentials updated successfully!" -ForegroundColor Green
        Write-Host "Data Source: $($dataSource.DatasourceName)"
        Write-Host "Credential Type: $CredentialType"
        Write-Host "Privacy Level: $PrivacyLevel"
    }
}
catch {
    Write-Error "Error updating data source: $($_.Exception.Message)"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue
}
