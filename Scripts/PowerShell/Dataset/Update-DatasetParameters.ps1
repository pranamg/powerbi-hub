<#
.SYNOPSIS
    Updates Power BI dataset parameters.

.DESCRIPTION
    Updates one or more parameters in a dataset.
    Commonly used for environment-specific connection strings,
    server names, or configuration values.

.PARAMETER WorkspaceId
    The workspace ID containing the dataset.

.PARAMETER DatasetId
    The dataset ID to update.

.PARAMETER Parameters
    Hashtable of parameter name-value pairs to update.

.PARAMETER TakeoverIfRequired
    If true, takes over the dataset if not owned by service principal.

.EXAMPLE
    .\Update-DatasetParameters.ps1 -WorkspaceId "guid" -DatasetId "guid" -Parameters @{
        "ServerName" = "prod-sql.database.windows.net"
        "DatabaseName" = "SalesDB"
    }

.NOTES
    Dataset must be in a Premium/Fabric workspace for some parameter types.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $true)]
    [string]$DatasetId,

    [Parameter(Mandatory = $true)]
    [hashtable]$Parameters,

    [Parameter(Mandatory = $false)]
    [switch]$TakeoverIfRequired
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Connecting to Power BI Service..."
    Connect-PowerBIServiceAccount | Out-Null

    # Get current parameters
    Write-Log "Retrieving current parameters for dataset: $DatasetId"
    $response = Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/datasets/$DatasetId/parameters" -Method Get
    $currentParams = ($response | ConvertFrom-Json).value

    Write-Log "Found $($currentParams.Count) existing parameters"

    # Validate parameters exist
    $invalidParams = @()
    foreach ($paramName in $Parameters.Keys) {
        $exists = $currentParams | Where-Object { $_.name -eq $paramName }
        if (-not $exists) {
            $invalidParams += $paramName
        }
    }

    if ($invalidParams.Count -gt 0) {
        Write-Log "Warning: These parameters don't exist in dataset: $($invalidParams -join ', ')" -Level "WARN"
        Write-Log "Available parameters: $($currentParams.name -join ', ')"
    }

    # Take over dataset if required
    if ($TakeoverIfRequired) {
        Write-Log "Taking over dataset ownership..."
        try {
            Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/datasets/$DatasetId/takeover" -Method Post | Out-Null
            Write-Log "Takeover successful"
        }
        catch {
            if ($_.Exception.Message -notlike "*already owned*") {
                throw
            }
            Write-Log "Dataset already owned by current user/service principal"
        }
    }

    # Build update request
    $updateDetails = @()
    foreach ($paramName in $Parameters.Keys) {
        $exists = $currentParams | Where-Object { $_.name -eq $paramName }
        if ($exists) {
            $updateDetails += @{
                name = $paramName
                newValue = $Parameters[$paramName]
            }
            Write-Log "Queuing update: $paramName = $($Parameters[$paramName])"
        }
    }

    if ($updateDetails.Count -eq 0) {
        Write-Log "No valid parameters to update" -Level "WARN"
        return @{ Updated = 0 }
    }

    # Update parameters
    $body = @{
        updateDetails = $updateDetails
    } | ConvertTo-Json -Depth 3

    Write-Log "Updating $($updateDetails.Count) parameter(s)..."
    Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/datasets/$DatasetId/Default.UpdateParameters" -Method Post -Body $body | Out-Null

    Write-Log "Parameters updated successfully" -Level "SUCCESS"

    # Verify updates
    $verifyResponse = Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/datasets/$DatasetId/parameters" -Method Get
    $verifiedParams = ($verifyResponse | ConvertFrom-Json).value

    $results = @()
    foreach ($update in $updateDetails) {
        $verified = $verifiedParams | Where-Object { $_.name -eq $update.name }
        $results += @{
            Name = $update.name
            NewValue = $update.newValue
            Verified = ($verified.currentValue -eq $update.newValue)
        }
    }

    return @{
        Updated = $updateDetails.Count
        Details = $results
    }
}
catch {
    Write-Log "Error: $($_.Exception.Message)" -Level "ERROR"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue | Out-Null
}
