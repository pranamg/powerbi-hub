# Access Control Matrix

> **Purpose:** Define and document access permissions across Power BI content

---

## Overview

The Access Control Matrix documents who has access to what Power BI content and at what permission level. This serves as the authoritative source for access reviews and audits.

---

## Workspace Access Matrix

### Template

| Workspace | Role | User/Group | Access Level | Justification | Review Date |
|-----------|------|------------|--------------|---------------|-------------|
| {Name} | {Job Role} | {Identity} | Admin/Member/Contributor/Viewer | {Reason} | {Date} |

### Production Workspaces

| Workspace | Role | User/Group | Access Level | Justification | Review Date |
|-----------|------|------------|--------------|---------------|-------------|
| Sales Analytics - Prod | BI Admin | bi-admins@contoso.com | Admin | Workspace management | 2024-Q4 |
| Sales Analytics - Prod | Report Developer | analytics-devs@contoso.com | Member | Report development | 2024-Q4 |
| Sales Analytics - Prod | Sales Team | sales-all@contoso.com | Viewer | Report consumption | 2024-Q4 |
| Finance Reports - Prod | BI Admin | bi-admins@contoso.com | Admin | Workspace management | 2024-Q4 |
| Finance Reports - Prod | Finance Analysts | finance-analysts@contoso.com | Member | Report development | 2024-Q4 |
| Finance Reports - Prod | Finance Team | finance-all@contoso.com | Viewer | Report consumption | 2024-Q4 |
| Executive Dashboard - Prod | BI Admin | bi-admins@contoso.com | Admin | Workspace management | 2024-Q4 |
| Executive Dashboard - Prod | Executive Assistant | exec-assistant@contoso.com | Contributor | Content updates | 2024-Q4 |
| Executive Dashboard - Prod | Executive Team | executives@contoso.com | Viewer | Report consumption | 2024-Q4 |

### Development Workspaces

| Workspace | Role | User/Group | Access Level | Justification | Review Date |
|-----------|------|------------|--------------|---------------|-------------|
| Sales Analytics - Dev | BI Developer | analytics-devs@contoso.com | Admin | Development work | 2024-Q4 |
| Finance Reports - Dev | BI Developer | analytics-devs@contoso.com | Admin | Development work | 2024-Q4 |

---

## Dataset Access Matrix

### RLS Role Assignments

| Dataset | RLS Role | User/Group | Filter Applied | Review Date |
|---------|----------|------------|----------------|-------------|
| Sales Model | EastRegion | sales-east@contoso.com | Region = "East" | 2024-Q4 |
| Sales Model | WestRegion | sales-west@contoso.com | Region = "West" | 2024-Q4 |
| Sales Model | NorthRegion | sales-north@contoso.com | Region = "North" | 2024-Q4 |
| Sales Model | SouthRegion | sales-south@contoso.com | Region = "South" | 2024-Q4 |
| Sales Model | AllRegions | sales-managers@contoso.com | No filter | 2024-Q4 |
| HR Analytics | DirectReports | all-managers@contoso.com | Dynamic - manager hierarchy | 2024-Q4 |
| HR Analytics | HRFull | hr-team@contoso.com | No filter | 2024-Q4 |

### OLS Role Assignments

| Dataset | OLS Role | User/Group | Hidden Objects | Review Date |
|---------|----------|------------|----------------|-------------|
| HR Analytics | StandardUser | all-employees@contoso.com | Salary, SSN, PerformanceRating | 2024-Q4 |
| HR Analytics | HRUser | hr-team@contoso.com | SSN only | 2024-Q4 |
| Customer Model | GeneralUser | sales-all@contoso.com | CustomerSSN, CreditScore | 2024-Q4 |

---

## Service Principal Access

| Service Principal | Purpose | Workspaces | Permission | Secret Expiry |
|-------------------|---------|------------|------------|---------------|
| SP-PowerBI-CICD-Prod | Production deployments | All Prod workspaces | Admin | 2025-06-15 |
| SP-PowerBI-CICD-Dev | Dev deployments | All Dev workspaces | Admin | 2025-06-15 |
| SP-PowerBI-Refresh | Automated refresh | Data workspaces | Member | 2025-06-15 |
| SP-PowerBI-Embed | App embedding | Embed workspace | Viewer | 2025-06-15 |

---

## Gateway Access

| Gateway Cluster | Admin Users/Groups | Data Source Admins | Review Date |
|-----------------|--------------------|--------------------|-------------|
| OnPrem-Gateway-Prod | gateway-admins@contoso.com | dba-team@contoso.com | 2024-Q4 |
| OnPrem-Gateway-Dev | gateway-admins@contoso.com | analytics-devs@contoso.com | 2024-Q4 |

---

## Capacity Access

| Capacity | Capacity Admins | Workspace Assignment Rights | Review Date |
|----------|-----------------|----------------------------|-------------|
| Premium-Prod | capacity-admins@contoso.com | bi-admins@contoso.com | 2024-Q4 |
| Premium-Dev | capacity-admins@contoso.com | analytics-devs@contoso.com | 2024-Q4 |

---

## Role Definitions

### Standard Roles

| Role | Description | Typical Access |
|------|-------------|----------------|
| BI Administrator | Full administrative access | Workspace Admin, Capacity Admin |
| Report Developer | Creates and maintains reports | Workspace Member |
| Data Modeler | Creates and maintains datasets | Workspace Member |
| Content Consumer | Views reports only | Workspace Viewer |
| External Partner | Limited external access | Specific report sharing |

### Job Function Mapping

| Job Function | Standard BI Role | Additional Permissions |
|--------------|------------------|----------------------|
| Executive | Content Consumer | Executive-only workspaces |
| Manager | Content Consumer | RLS access to team data |
| Analyst | Report Developer | Development workspaces |
| Data Engineer | Data Modeler | Gateway, Dataflow access |
| IT Admin | BI Administrator | Full tenant access |

---

## Access Request Process

### Request Form

```markdown
## Power BI Access Request

**Requestor:** ________________
**Date:** ________________
**Manager Approval:** ________________

### Request Details
**User/Group:** ________________
**Current Access:** ________________
**Requested Access:** ________________

### Justification
**Business Need:**
_Explain why this access is needed:_

**Duration:**
[ ] Permanent  [ ] Temporary (End Date: _______)

### Workspace Access Needed
| Workspace | Permission Level | Reason |
|-----------|------------------|--------|
| | | |

### Dataset Access Needed
| Dataset | RLS/OLS Role | Reason |
|---------|--------------|--------|
| | | |

### Approvals
- [ ] Manager Approval
- [ ] Data Owner Approval
- [ ] Security Review (for Confidential+)
- [ ] BI Admin Implementation
```

### Approval Matrix

| Access Type | Manager | Data Owner | Security | BI Admin |
|-------------|---------|------------|----------|----------|
| Viewer access | ✓ | - | - | ✓ |
| Contributor access | ✓ | ✓ | - | ✓ |
| Member access | ✓ | ✓ | - | ✓ |
| Admin access | ✓ | ✓ | ✓ | ✓ |
| Confidential data | ✓ | ✓ | ✓ | ✓ |
| Highly Confidential | ✓ | ✓ | ✓ | ✓ |

---

## Access Review Schedule

### Quarterly Reviews

| Quarter | Review Focus | Due Date | Reviewer |
|---------|--------------|----------|----------|
| Q1 | Production workspaces | March 31 | BI Admin + Data Owners |
| Q2 | Service principals, gateways | June 30 | BI Admin + Security |
| Q3 | Production workspaces | Sept 30 | BI Admin + Data Owners |
| Q4 | Full review all access | Dec 31 | BI Admin + Security + Audit |

### Review Checklist

```markdown
## Quarterly Access Review

**Review Period:** ________________
**Reviewer:** ________________
**Completion Date:** ________________

### Workspace Review
- [ ] All workspace members verified
- [ ] Terminated employees removed
- [ ] Role assignments appropriate
- [ ] External access reviewed

### Dataset Security Review
- [ ] RLS roles tested
- [ ] OLS configuration verified
- [ ] No unauthorized direct access

### Service Principal Review
- [ ] Active SPs still needed
- [ ] Permissions appropriate
- [ ] Secrets not expired

### Findings
| Finding | Severity | Action Taken |
|---------|----------|--------------|
| | | |

### Sign-off
- [ ] Review completed
- [ ] Issues remediated
- [ ] Documentation updated
```

---

## Offboarding Checklist

When employees leave or change roles:

```markdown
## Access Removal Checklist

**Employee:** ________________
**Last Day:** ________________
**Processed By:** ________________

### Power BI Access Removal
- [ ] Removed from all workspaces
- [ ] Removed from all RLS roles
- [ ] Removed from security groups
- [ ] Removed from app audiences
- [ ] Removed from gateway access
- [ ] Personal workspace contents handled

### Verification
- [ ] Verified removal via admin portal
- [ ] Documented in access matrix
- [ ] Notified relevant data owners
```

---

## Compliance Reports

### Access Summary Report

```powershell
# Generate access summary
$workspaces = Get-PowerBIWorkspace -Scope Organization -All

$accessReport = foreach ($ws in $workspaces) {
    $users = Get-PowerBIWorkspaceUser -Id $ws.Id
    
    foreach ($user in $users) {
        [PSCustomObject]@{
            Workspace       = $ws.Name
            WorkspaceId     = $ws.Id
            UserIdentity    = $user.Identifier
            PrincipalType   = $user.PrincipalType
            AccessRight     = $user.AccessRight
            ReportDate      = Get-Date
        }
    }
}

$accessReport | Export-Csv "access-report-$(Get-Date -Format 'yyyyMMdd').csv"
```

### Audit Evidence

Maintain evidence of:
- Access request forms
- Approval emails
- Review completion
- Removal confirmations

---

## Related Documents

- [Data Classification](./DataClassification.md)
- [Audit Procedures](./AuditProcedures.md)
- [RLS Patterns](./RLSPatterns.md)
- [OLS Configuration](./OLSConfiguration.md)

---

*Last Updated: December 2024*
*Next Review: March 2025*
