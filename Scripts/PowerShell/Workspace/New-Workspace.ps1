<#
.SYNOPSIS
    Creates a new Power BI workspace with optional configuration.

.DESCRIPTION
    Creates a workspace in Power BI Service with specified settings including:
    - Capacity assignment (Premium/Fabric)
    - Initial permissions
    - Description and contact

.PARAMETER WorkspaceName
    Name of the workspace to create.

.PARAMETER Description
    Optional description for the workspace.

.PARAMETER CapacityId
    Optional capacity ID to assign (Premium/Fabric).

.PARAMETER Owners
    Array of user emails to add as workspace owners.

.EXAMPLE
    .\New-Workspace.ps1 -WorkspaceName "Sales Analytics" -Description "Sales team reports"

.EXAMPLE
    .\New-Workspace.ps1 -WorkspaceName "Finance DEV" -CapacityId "guid" -Owners @("user@company.com")

.NOTES
    Requires MicrosoftPowerBIMgmt module and appropriate permissions.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $false)]
    [string]$Description = "",

    [Parameter(Mandatory = $false)]
    [string]$CapacityId,

    [Parameter(Mandatory = $false)]
    [string[]]$Owners = @()
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

    # Check if workspace already exists
    $existing = Get-PowerBIWorkspace -Name $WorkspaceName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Log "Workspace '$WorkspaceName' already exists (ID: $($existing.Id))" -Level "WARN"
        return $existing
    }

    # Create workspace
    Write-Log "Creating workspace: $WorkspaceName"
    $workspace = New-PowerBIWorkspace -Name $WorkspaceName

    if (-not $workspace) {
        throw "Failed to create workspace"
    }

    Write-Log "Workspace created successfully (ID: $($workspace.Id))"

    # Update description if provided
    if ($Description) {
        Write-Log "Setting workspace description..."
        $body = @{
            name = $WorkspaceName
            description = $Description
        } | ConvertTo-Json

        Invoke-PowerBIRestMethod -Url "groups/$($workspace.Id)" -Method Patch -Body $body | Out-Null
    }

    # Assign to capacity if provided
    if ($CapacityId) {
        Write-Log "Assigning workspace to capacity: $CapacityId"
        $body = @{
            capacityId = $CapacityId
        } | ConvertTo-Json

        Invoke-PowerBIRestMethod -Url "groups/$($workspace.Id)/AssignToCapacity" -Method Post -Body $body | Out-Null
        Write-Log "Capacity assignment complete"
    }

    # Add owners
    foreach ($owner in $Owners) {
        Write-Log "Adding owner: $owner"
        Add-PowerBIWorkspaceUser -Id $workspace.Id -UserEmailAddress $owner -AccessRight Admin | Out-Null
    }

    Write-Log "Workspace setup complete!" -Level "SUCCESS"
    return $workspace
}
catch {
    Write-Log "Error: $($_.Exception.Message)" -Level "ERROR"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue | Out-Null
}
