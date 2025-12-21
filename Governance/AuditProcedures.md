# Audit Procedures

> **Purpose:** Define procedures for auditing Power BI content, access, and compliance

---

## Overview

Regular audits ensure Power BI content meets security, compliance, and quality standards. This document outlines audit types, schedules, and procedures.

---

## Audit Types

### 1. Access Audit

**Purpose:** Verify appropriate access to workspaces and content.

**Frequency:** Monthly (Confidential), Quarterly (Internal)

**Scope:**
- Workspace membership
- Report permissions
- Dataset permissions
- RLS role assignments

### 2. Security Audit

**Purpose:** Ensure security controls are properly implemented.

**Frequency:** Quarterly

**Scope:**
- RLS configurations
- OLS configurations
- Sensitivity labels
- External sharing settings
- Export settings

### 3. Content Audit

**Purpose:** Verify content quality and compliance with standards.

**Frequency:** Semi-annually

**Scope:**
- Naming conventions
- Documentation completeness
- Data model best practices
- Performance benchmarks

### 4. Compliance Audit

**Purpose:** Ensure regulatory compliance.

**Frequency:** Annually (or as required)

**Scope:**
- Data classification accuracy
- Retention compliance
- Privacy requirements
- Industry regulations

---

## Audit Schedule

| Audit Type | Q1 | Q2 | Q3 | Q4 |
|------------|----|----|----|----|
| Access (HC) | Monthly | Monthly | Monthly | Monthly |
| Access (Conf) | Monthly | Monthly | Monthly | Monthly |
| Access (Int) | ✓ | - | ✓ | - |
| Security | ✓ | - | ✓ | - |
| Content | - | ✓ | - | ✓ |
| Compliance | - | - | - | ✓ |

---

## Access Audit Procedure

### Step 1: Extract Current Access

```powershell
# Get workspace access
$workspaces = Get-PowerBIWorkspace -Scope Organization -All

foreach ($ws in $workspaces) {
    $access = Get-PowerBIWorkspaceUser -Id $ws.Id
    
    [PSCustomObject]@{
        WorkspaceName = $ws.Name
        WorkspaceId   = $ws.Id
        Users         = ($access | Where-Object { $_.UserType -eq 'User' }).Count
        Groups        = ($access | Where-Object { $_.UserType -eq 'Group' }).Count
        Apps          = ($access | Where-Object { $_.UserType -eq 'App' }).Count
    }
}
```

### Step 2: Review Against Approved List

| Workspace | User/Group | Current Role | Approved Role | Action |
|-----------|------------|--------------|---------------|--------|
| Sales Analytics | user@domain | Admin | Member | Downgrade |
| HR Reports | Former Employee | Member | None | Remove |

### Step 3: Remediation

- Remove unauthorized access immediately
- Adjust roles to match approved levels
- Document exceptions with justification

### Step 4: Document Results

```markdown
## Access Audit Report

**Audit Date:** ________________
**Auditor:** ________________
**Period:** ________________

### Summary
| Metric | Count |
|--------|-------|
| Workspaces Reviewed | XX |
| Users Reviewed | XXX |
| Issues Found | X |
| Issues Remediated | X |

### Findings
| ID | Finding | Severity | Status |
|----|---------|----------|--------|
| 1 | {Description} | High/Med/Low | Open/Closed |

### Recommendations
1. {Recommendation}
```

---

## Security Audit Procedure

### RLS Audit Checklist

```markdown
## RLS Audit - {Dataset Name}

**Audit Date:** ________________
**Dataset:** ________________
**Classification:** ________________

### Role Configuration
| Role Name | DAX Filter | Test User | Test Result |
|-----------|------------|-----------|-------------|
| Sales Rep | [Region] = USERPRINCIPALNAME() | test@user | ✓/✗ |

### Validation Tests
- [ ] Each role tested with representative user
- [ ] Cross-role data isolation verified
- [ ] Admin bypass functions correctly
- [ ] No data leakage between roles
- [ ] Performance acceptable with RLS

### Issues Found
| Issue | Severity | Resolution |
|-------|----------|------------|
| | | |
```

### OLS Audit Checklist

```markdown
## OLS Audit - {Dataset Name}

**Audit Date:** ________________
**Dataset:** ________________

### Column Security
| Table | Column | Contains | OLS Role | Verified |
|-------|--------|----------|----------|----------|
| Customer | SSN | PII | Restricted | ✓/✗ |
| Employee | Salary | Sensitive | HR_Only | ✓/✗ |

### Validation
- [ ] All sensitive columns identified
- [ ] OLS roles assigned correctly
- [ ] Non-privileged users cannot see restricted columns
- [ ] Error messages don't reveal column existence
```

### Sensitivity Label Audit

```powershell
# Get sensitivity labels applied to artifacts
$workspaces = Get-PowerBIWorkspace -Scope Organization -All

foreach ($ws in $workspaces) {
    $reports = Get-PowerBIReport -WorkspaceId $ws.Id
    
    foreach ($report in $reports) {
        [PSCustomObject]@{
            Workspace        = $ws.Name
            Report           = $report.Name
            SensitivityLabel = $report.SensitivityLabel
            ExpectedLabel    = "TBD"  # Compare to classification
            Compliant        = "TBD"
        }
    }
}
```

---

## Content Audit Procedure

### Naming Convention Audit

```powershell
# Check naming compliance
$namingPatterns = @{
    Measure    = '^[A-Z][a-zA-Z0-9]+( [A-Z][a-zA-Z0-9]+)*$'  # Title Case
    Table      = '^[A-Z][a-zA-Z0-9]+$'                        # PascalCase
    Column     = '^[A-Z][a-zA-Z0-9]+$'                        # PascalCase
}

# Review in Tabular Editor or via XMLA endpoint
```

### Best Practice Analyzer Audit

Run BPA rules against all production datasets:

```powershell
# Using Tabular Editor CLI
& "TabularEditor.exe" `
    "Provider=MSOLAP;Data Source=powerbi://api.powerbi.com/v1.0/myorg/WorkspaceName" `
    "DatasetName" `
    -BPA "BestPracticeRules.json" `
    -OUTPUT "bpa-results.json"
```

### Documentation Completeness

| Dataset | Description | Column Descriptions | Measure Descriptions | Score |
|---------|-------------|---------------------|---------------------|-------|
| Sales | ✓/✗ | XX% | XX% | XX% |

---

## Compliance Audit Procedure

### Data Classification Verification

For each dataset, verify:
1. Classification is documented
2. Classification is accurate
3. Controls match classification level
4. Sensitivity label applied

### Regulatory Compliance

```markdown
## Compliance Checklist - {Regulation}

**Dataset:** ________________
**Regulation:** GDPR / HIPAA / SOX / PCI-DSS

### Requirements
| Requirement | Implementation | Evidence | Status |
|-------------|----------------|----------|--------|
| Data minimization | Only required fields | Schema review | ✓/✗ |
| Access controls | RLS implemented | RLS audit | ✓/✗ |
| Encryption | TLS + at-rest | Config review | ✓/✗ |
| Audit logging | Activity log enabled | Log sample | ✓/✗ |
| Retention | 7-year retention | Policy document | ✓/✗ |

### Gaps Identified
| Gap | Risk | Remediation | Due Date |
|-----|------|-------------|----------|
| | | | |
```

---

## Audit Checklists

### Monthly Access Audit Checklist

```markdown
- [ ] Export workspace membership lists
- [ ] Compare to approved access lists
- [ ] Identify terminated employees
- [ ] Remove unauthorized access
- [ ] Review admin assignments
- [ ] Document findings
- [ ] Send report to stakeholders
```

### Quarterly Security Audit Checklist

```markdown
- [ ] Test RLS for all Confidential+ datasets
- [ ] Verify OLS for Highly Confidential datasets
- [ ] Review sensitivity label assignments
- [ ] Check external sharing settings
- [ ] Audit export permissions
- [ ] Review gateway data source credentials
- [ ] Test service principal access
- [ ] Document findings and remediation
```

### Annual Compliance Audit Checklist

```markdown
- [ ] Review all data classifications
- [ ] Verify regulatory compliance
- [ ] Update data catalog
- [ ] Review retention compliance
- [ ] Audit vendor access
- [ ] Review privacy impact assessments
- [ ] Update risk register
- [ ] Executive summary report
```

---

## Audit Tools

### Power BI Activity Log

```powershell
# Get activity log for audit period
$startDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
$endDate = (Get-Date).ToString("yyyy-MM-dd")

Get-PowerBIActivityEvents `
    -StartDateTime "${startDate}T00:00:00" `
    -EndDateTime "${endDate}T23:59:59" |
    ConvertFrom-Json |
    Where-Object { $_.Activity -in @('ViewReport', 'ExportReport', 'ShareReport') } |
    Export-Csv "activity-audit.csv" -NoTypeInformation
```

### Scanner API for Catalog

```powershell
# Get full tenant inventory using Scanner API
# Requires appropriate admin permissions

$scannerUrl = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/getInfo"
$body = @{
    workspaces = @()  # Empty for all
    datasetExpressions = $true
    datasetSchema = $true
    datasourceDetails = $true
    getArtifactUsers = $true
} | ConvertTo-Json

$results = Invoke-PowerBIRestMethod -Url $scannerUrl -Method Post -Body $body
```

---

## Reporting

### Audit Dashboard Metrics

| Metric | Description |
|--------|-------------|
| Access Compliance % | Users with approved access / Total users |
| RLS Coverage % | Datasets with RLS / Total datasets (Conf+) |
| Label Compliance % | Items with correct label / Total items |
| Outstanding Issues | Open audit findings count |
| Remediation Time | Avg days to close findings |

### Executive Summary Template

```markdown
## Power BI Audit Executive Summary

**Period:** {Quarter/Year}
**Prepared By:** ________________
**Date:** ________________

### Overall Compliance Score: XX%

### Key Findings
1. **High Priority:** {Description}
2. **Medium Priority:** {Description}
3. **Low Priority:** {Description}

### Metrics Summary
| Area | Score | Trend | Target |
|------|-------|-------|--------|
| Access Control | XX% | ↑/↓/→ | 95% |
| Security | XX% | ↑/↓/→ | 98% |
| Content Quality | XX% | ↑/↓/→ | 90% |
| Compliance | XX% | ↑/↓/→ | 100% |

### Actions Required
| Action | Owner | Due Date |
|--------|-------|----------|
| | | |

### Next Audit: {Date}
```

---

## Related Documents

- [Data Classification](./DataClassification.md)
- [Access Control Matrix](./AccessControlMatrix.md)
- [Development Standards](./DevelopmentStandards.md)

---

*Last Updated: December 2024*
*Review Date: March 2025*
