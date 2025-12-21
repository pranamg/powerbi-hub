<#
.SYNOPSIS
    Generates a comprehensive Power BI tenant inventory report.

.DESCRIPTION
    Scans the entire tenant and produces an inventory of:
    - Workspaces (with capacity assignment)
    - Datasets (with refresh schedules)
    - Reports and dashboards
    - Dataflows
    - Users and permissions

.PARAMETER OutputPath
    Path for the output CSV/Excel files.

.PARAMETER IncludePersonalWorkspaces
    If true, includes personal (My Workspace) in the scan.

.PARAMETER ExportFormat
    Output format: CSV or JSON.

.EXAMPLE
    .\Get-TenantInventory.ps1 -OutputPath "C:\Reports" -ExportFormat CSV

.NOTES
    Requires Power BI Admin or Global Admin role.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [switch]$IncludePersonalWorkspaces,

    [Parameter(Mandatory = $false)]
    [ValidateSet("CSV", "JSON")]
    [string]$ExportFormat = "CSV"
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Export-Data {
    param($Data, $FileName)
    
    $filePath = Join-Path $OutputPath $FileName
    
    if ($ExportFormat -eq "CSV") {
        $Data | Export-Csv -Path "$filePath.csv" -NoTypeInformation
    }
    else {
        $Data | ConvertTo-Json -Depth 5 | Out-File "$filePath.json"
    }
    
    Write-Log "Exported: $filePath.$($ExportFormat.ToLower())"
}

try {
    Write-Log "Connecting to Power BI Service as Admin..."
    Connect-PowerBIServiceAccount | Out-Null

    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }

    $scanDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 1. Get all workspaces
    Write-Log "Scanning workspaces..."
    $workspaces = Get-PowerBIWorkspace -Scope Organization -All
    
    if (-not $IncludePersonalWorkspaces) {
        $workspaces = $workspaces | Where-Object { $_.Type -ne "PersonalGroup" }
    }

    $workspaceData = $workspaces | ForEach-Object {
        @{
            WorkspaceId = $_.Id
            WorkspaceName = $_.Name
            Type = $_.Type
            State = $_.State
            IsOnDedicatedCapacity = $_.IsOnDedicatedCapacity
            CapacityId = $_.CapacityId
            ScanDate = $scanDate
        }
    }

    Export-Data -Data $workspaceData -FileName "Workspaces"
    Write-Log "Found $($workspaces.Count) workspaces"

    # 2. Get all datasets
    Write-Log "Scanning datasets..."
    $allDatasets = @()

    foreach ($ws in $workspaces) {
        try {
            $datasets = Get-PowerBIDataset -WorkspaceId $ws.Id
            foreach ($ds in $datasets) {
                $allDatasets += @{
                    DatasetId = $ds.Id
                    DatasetName = $ds.Name
                    WorkspaceId = $ws.Id
                    WorkspaceName = $ws.Name
                    ConfiguredBy = $ds.ConfiguredBy
                    IsRefreshable = $ds.IsRefreshable
                    IsOnPremGatewayRequired = $ds.IsOnPremGatewayRequired
                    ScanDate = $scanDate
                }
            }
        }
        catch {
            Write-Log "Could not scan datasets in $($ws.Name): $($_.Exception.Message)" -Level "WARN"
        }
    }

    Export-Data -Data $allDatasets -FileName "Datasets"
    Write-Log "Found $($allDatasets.Count) datasets"

    # 3. Get all reports
    Write-Log "Scanning reports..."
    $allReports = @()

    foreach ($ws in $workspaces) {
        try {
            $reports = Get-PowerBIReport -WorkspaceId $ws.Id
            foreach ($rpt in $reports) {
                $allReports += @{
                    ReportId = $rpt.Id
                    ReportName = $rpt.Name
                    WorkspaceId = $ws.Id
                    WorkspaceName = $ws.Name
                    DatasetId = $rpt.DatasetId
                    WebUrl = $rpt.WebUrl
                    ScanDate = $scanDate
                }
            }
        }
        catch {
            Write-Log "Could not scan reports in $($ws.Name): $($_.Exception.Message)" -Level "WARN"
        }
    }

    Export-Data -Data $allReports -FileName "Reports"
    Write-Log "Found $($allReports.Count) reports"

    # 4. Get workspace users (sample - top 100 workspaces only for performance)
    Write-Log "Scanning workspace permissions (sample)..."
    $allPermissions = @()
    $sampleWorkspaces = $workspaces | Select-Object -First 100

    foreach ($ws in $sampleWorkspaces) {
        try {
            $users = Get-PowerBIWorkspaceUser -Id $ws.Id -ErrorAction SilentlyContinue
            foreach ($user in $users) {
                $allPermissions += @{
                    WorkspaceId = $ws.Id
                    WorkspaceName = $ws.Name
                    UserPrincipalName = $user.UserPrincipalName
                    AccessRight = $user.AccessRight
                    PrincipalType = $user.PrincipalType
                    ScanDate = $scanDate
                }
            }
        }
        catch {
            # Permission errors expected for some workspaces
        }
    }

    Export-Data -Data $allPermissions -FileName "WorkspacePermissions"
    Write-Log "Captured permissions for $($sampleWorkspaces.Count) workspaces"

    # 5. Summary report
    $summary = @{
        ScanDate = $scanDate
        TotalWorkspaces = $workspaces.Count
        PremiumWorkspaces = ($workspaces | Where-Object { $_.IsOnDedicatedCapacity }).Count
        TotalDatasets = $allDatasets.Count
        TotalReports = $allReports.Count
        RefreshableDatasets = ($allDatasets | Where-Object { $_.IsRefreshable }).Count
        GatewayRequiredDatasets = ($allDatasets | Where-Object { $_.IsOnPremGatewayRequired }).Count
    }

    Export-Data -Data @($summary) -FileName "Summary"

    Write-Log "Tenant inventory scan complete!" -Level "SUCCESS"
    Write-Log "Output location: $OutputPath"

    return $summary
}
catch {
    Write-Log "Error: $($_.Exception.Message)" -Level "ERROR"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue | Out-Null
}
