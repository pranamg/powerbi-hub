<#
.SYNOPSIS
    Get status of Power BI on-premises data gateways.

.DESCRIPTION
    Retrieves gateway cluster information, member status, and data source configurations.

.PARAMETER GatewayId
    Optional. Specific gateway cluster ID to query.

.PARAMETER IncludeDataSources
    Include data source details for each gateway.

.EXAMPLE
    .\Get-GatewayStatus.ps1
    Get all gateways accessible to the current user.

.EXAMPLE
    .\Get-GatewayStatus.ps1 -GatewayId "guid-here" -IncludeDataSources
    Get specific gateway with data source details.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$GatewayId,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDataSources,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

# Requires MicrosoftPowerBIMgmt module
#Requires -Modules MicrosoftPowerBIMgmt

function Get-GatewayClusterStatus {
    param([string]$ClusterId)
    
    $gateway = Get-PowerBIGatewayCluster -GatewayClusterId $ClusterId
    
    $status = [PSCustomObject]@{
        ClusterId           = $gateway.Id
        ClusterName         = $gateway.Name
        Type                = $gateway.Type
        PublicKey           = $gateway.PublicKey.Exponent
        Version             = $null
        MemberCount         = 0
        OnlineMembers       = 0
        Members             = @()
        DataSources         = @()
    }
    
    # Get cluster members
    $members = Get-PowerBIGatewayClusterMember -GatewayClusterId $ClusterId
    $status.MemberCount = $members.Count
    $status.OnlineMembers = ($members | Where-Object { $_.Status -eq "Live" }).Count
    
    foreach ($member in $members) {
        $status.Members += [PSCustomObject]@{
            MemberId    = $member.Id
            MachineName = $member.Name
            Status      = $member.Status
            Version     = $member.Version
            LastOnline  = $member.LastOnline
        }
        
        if (-not $status.Version) {
            $status.Version = $member.Version
        }
    }
    
    return $status
}

function Get-GatewayDataSources {
    param([string]$ClusterId)
    
    $dataSources = Get-PowerBIGatewayClusterDatasource -GatewayClusterId $ClusterId
    
    $result = @()
    foreach ($ds in $dataSources) {
        $result += [PSCustomObject]@{
            DataSourceId       = $ds.Id
            DataSourceName     = $ds.DatasourceName
            DataSourceType     = $ds.DatasourceType
            ConnectionDetails  = $ds.ConnectionDetails
            CredentialType     = $ds.CredentialType
            GatewayClusterId   = $ClusterId
        }
    }
    
    return $result
}

# Main execution
try {
    Write-Host "Connecting to Power BI Service..." -ForegroundColor Cyan
    Connect-PowerBIServiceAccount | Out-Null
    
    Write-Host "Retrieving gateway information..." -ForegroundColor Cyan
    
    $results = @()
    
    if ($GatewayId) {
        $results += Get-GatewayClusterStatus -ClusterId $GatewayId
        
        if ($IncludeDataSources) {
            $results[0].DataSources = Get-GatewayDataSources -ClusterId $GatewayId
        }
    }
    else {
        $gateways = Get-PowerBIGatewayCluster
        
        foreach ($gw in $gateways) {
            $status = Get-GatewayClusterStatus -ClusterId $gw.Id
            
            if ($IncludeDataSources) {
                $status.DataSources = Get-GatewayDataSources -ClusterId $gw.Id
            }
            
            $results += $status
        }
    }
    
    # Display summary
    Write-Host "`n=== Gateway Summary ===" -ForegroundColor Green
    foreach ($r in $results) {
        Write-Host "`nCluster: $($r.ClusterName)" -ForegroundColor Yellow
        Write-Host "  Type: $($r.Type)"
        Write-Host "  Version: $($r.Version)"
        Write-Host "  Members: $($r.OnlineMembers)/$($r.MemberCount) online"
        
        if ($r.Members) {
            Write-Host "  Member Details:" -ForegroundColor Cyan
            foreach ($m in $r.Members) {
                $statusColor = if ($m.Status -eq "Live") { "Green" } else { "Red" }
                Write-Host "    - $($m.MachineName): " -NoNewline
                Write-Host "$($m.Status)" -ForegroundColor $statusColor
            }
        }
        
        if ($r.DataSources -and $r.DataSources.Count -gt 0) {
            Write-Host "  Data Sources ($($r.DataSources.Count)):" -ForegroundColor Cyan
            foreach ($ds in $r.DataSources) {
                Write-Host "    - $($ds.DataSourceName) ($($ds.DataSourceType))"
            }
        }
    }
    
    # Export if requested
    if ($OutputPath) {
        $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath
        Write-Host "`nExported to: $OutputPath" -ForegroundColor Green
    }
    
    return $results
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
    throw
}
finally {
    Disconnect-PowerBIServiceAccount -ErrorAction SilentlyContinue
}
