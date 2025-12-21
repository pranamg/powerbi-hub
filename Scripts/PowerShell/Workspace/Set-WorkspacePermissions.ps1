<#
.SYNOPSIS
    Manages Power BI workspace permissions.

.DESCRIPTION
    Add, update, or remove users and groups from a workspace.
    Supports Admin, Member, Contributor, and Viewer roles.

.PARAMETER WorkspaceId
    The workspace ID (GUID).

.PARAMETER WorkspaceName
    Alternative to WorkspaceId - workspace name to look up.

.PARAMETER UsersToAdd
    Hashtable of users to add. Key = email, Value = role (Admin/Member/Contributor/Viewer).

.PARAMETER UsersToRemove
    Array of user emails to remove from workspace.

.PARAMETER GroupsToAdd
    Hashtable of groups to add. Key = group ID, Value = role.

.EXAMPLE
    .\Set-WorkspacePermissions.ps1 -WorkspaceName "Sales" -UsersToAdd @{"user@company.com"="Viewer"}

.EXAMPLE
    .\Set-WorkspacePermissions.ps1 -WorkspaceId "guid" -UsersToRemove @("old@company.com")

.NOTES
    Requires Admin or Member role on the target workspace.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $false)]
    [hashtable]$UsersToAdd = @{},

    [Parameter(Mandatory = $false)]
    [string[]]$UsersToRemove = @(),

    [Parameter(Mandatory = $false)]
    [hashtable]$GroupsToAdd = @{}
)

$ErrorActionPreference = "Stop"

$ValidRoles = @("Admin", "Member", "Contributor", "Viewer")

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Connecting to Power BI Service..."
    Connect-PowerBIServiceAccount | Out-Null

    # Resolve workspace
    if (-not $WorkspaceId) {
        if (-not $WorkspaceName) {
            throw "Either WorkspaceId or WorkspaceName must be provided"
        }
        $workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        if (-not $workspace) {
            throw "Workspace '$WorkspaceName' not found"
        }
        $WorkspaceId = $workspace.Id
    }

    Write-Log "Managing permissions for workspace: $WorkspaceId"

    # Get current permissions
    $currentUsers = Get-PowerBIWorkspaceUser -Id $WorkspaceId
    Write-Log "Current user count: $($currentUsers.Count)"

    # Add users
    foreach ($email in $UsersToAdd.Keys) {
        $role = $UsersToAdd[$email]
        
        if ($role -notin $ValidRoles) {
            Write-Log "Invalid role '$role' for $email. Skipping." -Level "WARN"
            continue
        }

        $existing = $currentUsers | Where-Object { $_.UserPrincipalName -eq $email }
        
        if ($existing) {
            if ($existing.AccessRight -eq $role) {
                Write-Log "User $email already has $role access. Skipping."
                continue
            }
            Write-Log "Updating $email from $($existing.AccessRight) to $role"
            # Remove and re-add with new role
            Remove-PowerBIWorkspaceUser -Id $WorkspaceId -UserEmailAddress $email | Out-Null
        }

        Write-Log "Adding $email as $role"
        Add-PowerBIWorkspaceUser -Id $WorkspaceId -UserEmailAddress $email -AccessRight $role | Out-Null
    }

    # Add groups
    foreach ($groupId in $GroupsToAdd.Keys) {
        $role = $GroupsToAdd[$groupId]
        
        if ($role -notin $ValidRoles) {
            Write-Log "Invalid role '$role' for group $groupId. Skipping." -Level "WARN"
            continue
        }

        Write-Log "Adding group $groupId as $role"
        $body = @{
            groupUserAccessRight = $role
            identifier = $groupId
            principalType = "Group"
        } | ConvertTo-Json

        Invoke-PowerBIRestMethod -Url "groups/$WorkspaceId/users" -Method Post -Body $body | Out-Null
    }

    # Remove users
    foreach ($email in $UsersToRemove) {
        $existing = $currentUsers | Where-Object { $_.UserPrincipalName -eq $email }
        
        if (-not $existing) {
            Write-Log "User $email not found in workspace. Skipping." -Level "WARN"
            continue
        }

        Write-Log "Removing $email"
        Remove-PowerBIWorkspaceUser -Id $WorkspaceId -UserEmailAddress $email | Out-Null
    }

    # Summary
    $updatedUsers = Get-PowerBIWorkspaceUser -Id $WorkspaceId
    Write-Log "Permission update complete. Current user count: $($updatedUsers.Count)"

    return $updatedUsers
}
catch {
    Write-Log "Error: $($_.Exception.Message)" -Level "ERROR"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue | Out-Null
}
