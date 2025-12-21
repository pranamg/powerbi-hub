<#
.SYNOPSIS
    Triggers and monitors Power BI dataset refresh.

.DESCRIPTION
    Initiates a dataset refresh and optionally waits for completion.
    Supports enhanced refresh with specific tables/partitions.
    Can send notifications on completion/failure.

.PARAMETER WorkspaceId
    The workspace ID containing the dataset.

.PARAMETER DatasetId
    The dataset ID to refresh.

.PARAMETER DatasetName
    Alternative to DatasetId - find dataset by name in workspace.

.PARAMETER WaitForCompletion
    If true, polls until refresh completes or times out.

.PARAMETER TimeoutMinutes
    Maximum time to wait for refresh completion.

.PARAMETER RefreshType
    Type of refresh: Full, Automatic, or DataOnly.

.PARAMETER Tables
    Optional array of table names for partial refresh.

.EXAMPLE
    .\Invoke-DatasetRefresh.ps1 -WorkspaceId "guid" -DatasetId "guid" -WaitForCompletion

.EXAMPLE
    .\Invoke-DatasetRefresh.ps1 -WorkspaceId "guid" -DatasetName "Sales Model" -RefreshType "DataOnly"

.NOTES
    Enhanced refresh requires Premium/Fabric capacity.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $false)]
    [string]$DatasetId,

    [Parameter(Mandatory = $false)]
    [string]$DatasetName,

    [Parameter(Mandatory = $false)]
    [switch]$WaitForCompletion,

    [Parameter(Mandatory = $false)]
    [int]$TimeoutMinutes = 60,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Full", "Automatic", "DataOnly")]
    [string]$RefreshType = "Full",

    [Parameter(Mandatory = $false)]
    [string[]]$Tables = @()
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Get-RefreshStatus {
    param([string]$WsId, [string]$DsId)
    
    $history = Invoke-PowerBIRestMethod -Url "groups/$WsId/datasets/$DsId/refreshes?`$top=1" -Method Get
    $refreshes = ($history | ConvertFrom-Json).value
    
    if ($refreshes.Count -gt 0) {
        return $refreshes[0]
    }
    return $null
}

try {
    Write-Log "Connecting to Power BI Service..."
    Connect-PowerBIServiceAccount | Out-Null

    # Resolve dataset
    if (-not $DatasetId) {
        if (-not $DatasetName) {
            throw "Either DatasetId or DatasetName must be provided"
        }
        $datasets = Get-PowerBIDataset -WorkspaceId $WorkspaceId
        $dataset = $datasets | Where-Object { $_.Name -eq $DatasetName }
        if (-not $dataset) {
            throw "Dataset '$DatasetName' not found in workspace"
        }
        $DatasetId = $dataset.Id
        Write-Log "Resolved dataset '$DatasetName' to ID: $DatasetId"
    }

    # Build refresh request
    $body = @{
        type = $RefreshType
    }

    if ($Tables.Count -gt 0) {
        Write-Log "Enhanced refresh for tables: $($Tables -join ', ')"
        $body.objects = $Tables | ForEach-Object { @{ table = $_ } }
    }

    $bodyJson = $body | ConvertTo-Json -Depth 3

    # Get initial refresh count for tracking
    $initialStatus = Get-RefreshStatus -WsId $WorkspaceId -DsId $DatasetId
    $initialRequestId = if ($initialStatus) { $initialStatus.requestId } else { $null }

    # Trigger refresh
    Write-Log "Triggering $RefreshType refresh for dataset: $DatasetId"
    try {
        Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/datasets/$DatasetId/refreshes" -Method Post -Body $bodyJson | Out-Null
    }
    catch {
        if ($_.Exception.Message -like "*refresh operation is already in progress*") {
            Write-Log "Refresh already in progress" -Level "WARN"
        }
        else {
            throw
        }
    }

    Write-Log "Refresh triggered successfully"

    if (-not $WaitForCompletion) {
        Write-Log "Not waiting for completion. Use -WaitForCompletion to monitor."
        return @{ Status = "Triggered"; DatasetId = $DatasetId }
    }

    # Wait for completion
    Write-Log "Waiting for refresh completion (timeout: $TimeoutMinutes minutes)..."
    $startTime = Get-Date
    $timeout = $startTime.AddMinutes($TimeoutMinutes)
    $pollInterval = 30  # seconds

    while ((Get-Date) -lt $timeout) {
        Start-Sleep -Seconds $pollInterval
        
        $currentStatus = Get-RefreshStatus -WsId $WorkspaceId -DsId $DatasetId
        
        # Check if this is the new refresh
        if ($currentStatus.requestId -ne $initialRequestId) {
            $status = $currentStatus.status
            $elapsed = [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1)

            switch ($status) {
                "Completed" {
                    Write-Log "Refresh completed successfully in $elapsed minutes" -Level "SUCCESS"
                    return @{
                        Status = "Completed"
                        DatasetId = $DatasetId
                        Duration = $elapsed
                        EndTime = $currentStatus.endTime
                    }
                }
                "Failed" {
                    $error = $currentStatus.serviceExceptionJson | ConvertFrom-Json -ErrorAction SilentlyContinue
                    $errorMsg = if ($error) { $error.errorDescription } else { "Unknown error" }
                    Write-Log "Refresh failed after $elapsed minutes: $errorMsg" -Level "ERROR"
                    return @{
                        Status = "Failed"
                        DatasetId = $DatasetId
                        Duration = $elapsed
                        Error = $errorMsg
                    }
                }
                "Cancelled" {
                    Write-Log "Refresh was cancelled" -Level "WARN"
                    return @{ Status = "Cancelled"; DatasetId = $DatasetId }
                }
                "Unknown" {
                    Write-Log "Still refreshing... ($elapsed minutes elapsed)"
                }
                default {
                    Write-Log "Status: $status ($elapsed minutes elapsed)"
                }
            }
        }
    }

    Write-Log "Refresh timed out after $TimeoutMinutes minutes" -Level "WARN"
    return @{ Status = "Timeout"; DatasetId = $DatasetId }
}
catch {
    Write-Log "Error: $($_.Exception.Message)" -Level "ERROR"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue | Out-Null
}
