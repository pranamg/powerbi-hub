# Change Management Process

> **Purpose:** Define procedures for managing changes to Power BI content across environments

---

## Overview

All changes to production Power BI content must follow this change management process to ensure quality, minimize risk, and maintain audit trails.

---

## Change Categories

### Standard Change

**Definition:** Pre-approved, low-risk changes that follow established procedures.

| Attribute | Value |
|-----------|-------|
| Approval Required | No (pre-approved) |
| Lead Time | None |
| Examples | Adding measures, updating visuals, fixing typos |

### Normal Change

**Definition:** Changes requiring review and approval before implementation.

| Attribute | Value |
|-----------|-------|
| Approval Required | Yes (Change Advisory Board) |
| Lead Time | 3-5 business days |
| Examples | New reports, data model changes, RLS updates |

### Emergency Change

**Definition:** Urgent changes needed to restore service or fix critical issues.

| Attribute | Value |
|-----------|-------|
| Approval Required | Post-implementation |
| Lead Time | Immediate |
| Examples | Critical bug fixes, security patches |

---

## Change Request Process

### Step 1: Submit Request

```markdown
## Change Request Form

**Request ID:** CHG-YYYY-XXXX
**Submitted By:** ________________
**Date:** ________________

### Change Details
**Title:** ________________
**Category:** [ ] Standard  [ ] Normal  [ ] Emergency
**Priority:** [ ] Low  [ ] Medium  [ ] High  [ ] Critical

**Description:**
_Detailed description of the change:_

**Business Justification:**
_Why is this change needed?_

### Scope
**Affected Workspaces:**
- [ ] Development
- [ ] Test
- [ ] Production

**Affected Items:**
| Item Type | Item Name | Change Type |
|-----------|-----------|-------------|
| Report    |           | New/Modify/Delete |
| Dataset   |           | New/Modify/Delete |
| Dataflow  |           | New/Modify/Delete |

### Risk Assessment
**Risk Level:** [ ] Low  [ ] Medium  [ ] High

**Potential Impact:**
_What could go wrong?_

**Rollback Plan:**
_How to reverse the change if needed:_

### Testing
**Test Plan:**
_How will this be tested?_

**Test Results:**
_Summary of testing outcomes:_

### Implementation
**Planned Date:** ________________
**Planned Time:** ________________
**Estimated Duration:** ________________
**Implementer:** ________________
```

### Step 2: Review and Approval

**Standard Changes:**
- Auto-approved if meets criteria
- Document in change log

**Normal Changes:**
- Technical review by peer
- Business review by data owner
- CAB approval for production

**Emergency Changes:**
- Implement immediately
- Document within 24 hours
- Post-implementation review

### Step 3: Implementation

```
Development → Test → Production
     ↓           ↓         ↓
   Build      Validate   Deploy
```

### Step 4: Verification

Post-deployment checks:
- [ ] Reports render correctly
- [ ] Data refreshes successfully
- [ ] RLS functions as expected
- [ ] Performance acceptable
- [ ] No regression issues

### Step 5: Closure

- Document implementation details
- Update change log
- Notify stakeholders
- Archive request

---

## Approval Matrix

| Change Type | Developer | Tech Lead | Data Owner | CAB |
|-------------|-----------|-----------|------------|-----|
| Standard | ✓ | - | - | - |
| Normal (Low) | ✓ | ✓ | - | - |
| Normal (Medium) | ✓ | ✓ | ✓ | - |
| Normal (High) | ✓ | ✓ | ✓ | ✓ |
| Emergency | ✓ | ✓ (post) | - | ✓ (post) |

---

## Standard Change Catalog

Pre-approved changes that don't require individual approval:

| ID | Change Type | Conditions |
|----|-------------|------------|
| SC-001 | Add/modify measure | No breaking changes |
| SC-002 | Update visual formatting | No data changes |
| SC-003 | Fix typos/labels | Display only |
| SC-004 | Add report page | Existing data model |
| SC-005 | Update tooltip | No logic changes |
| SC-006 | Adjust filters | No security impact |
| SC-007 | Update theme colors | Cosmetic only |
| SC-008 | Add bookmarks | No data changes |
| SC-009 | Update drill-through | Existing pages |
| SC-010 | Refresh schedule change | Within approved window |

---

## Environment Promotion

### Development to Test

**Triggers:**
- Developer completes changes
- Unit testing passed
- Code review completed

**Process:**
1. Create deployment pipeline artifact
2. Run automated tests
3. Deploy to Test workspace
4. Notify QA team

### Test to Production

**Triggers:**
- QA testing passed
- User acceptance approved
- Change request approved

**Process:**
1. Schedule deployment window
2. Notify stakeholders
3. Execute deployment
4. Verify functionality
5. Monitor for issues

### Deployment Checklist

```markdown
## Pre-Deployment
- [ ] All approvals obtained
- [ ] Rollback plan documented
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled

## Deployment
- [ ] Backup current version
- [ ] Deploy changes
- [ ] Verify deployment success
- [ ] Test critical functionality

## Post-Deployment
- [ ] Monitor for errors
- [ ] Verify data refresh
- [ ] Check user access
- [ ] Update documentation
- [ ] Close change request
```

---

## Rollback Procedures

### Immediate Rollback Triggers

- Data accuracy issues
- Security vulnerabilities
- Critical functionality broken
- Performance degradation >50%

### Rollback Steps

1. **Assess Impact**
   - Identify affected users
   - Document symptoms

2. **Execute Rollback**
   ```powershell
   # Using deployment pipeline
   # Revert to previous stage
   
   # Or restore from backup
   Restore-PowerBIReport -WorkspaceId $workspaceId -BackupPath $backupPath
   ```

3. **Verify Restoration**
   - Test functionality
   - Confirm data accuracy
   - Check user access

4. **Root Cause Analysis**
   - Document issue
   - Identify cause
   - Plan remediation

---

## Change Freeze Periods

No production changes during:

| Period | Duration | Reason |
|--------|----------|--------|
| Month-end close | Last 3 days | Financial reporting |
| Quarter-end | Last 5 days | Critical metrics |
| Year-end | Dec 20 - Jan 5 | Annual close |
| Major events | As announced | Business critical |

**Emergency Exception:**
- Requires VP-level approval
- Must be security or compliance related

---

## Communication Plan

### Change Notification Template

```
Subject: [Power BI Change] {Change Title} - {Date}

Hello,

A change has been scheduled for the following Power BI content:

**Change Details:**
- Request ID: CHG-2024-0001
- Title: {Title}
- Date/Time: {DateTime}
- Duration: {Duration}
- Impact: {Impact description}

**Affected Content:**
- {List of reports/datasets}

**What to expect:**
- {Description of changes}

**Action Required:**
- {Any user actions needed}

Questions? Contact: {Contact info}

Best regards,
BI Team
```

### Communication Matrix

| Change Type | Advance Notice | Audience |
|-------------|----------------|----------|
| Standard | None | None |
| Normal (Low) | 24 hours | Direct users |
| Normal (Medium) | 3 days | All users |
| Normal (High) | 1 week | All users + management |
| Emergency | ASAP | Affected users |

---

## Metrics and Reporting

### Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Change success rate | >95% | Successful / Total |
| Mean time to deploy | <2 hours | Request to production |
| Rollback rate | <5% | Rollbacks / Deployments |
| Emergency change rate | <10% | Emergency / Total |

### Monthly Report

```markdown
## Change Management Monthly Report

**Period:** {Month Year}

### Summary
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Changes | XX | - | - |
| Success Rate | XX% | 95% | ✓/✗ |
| Rollbacks | X | - | - |
| Emergency Changes | X | <10% | ✓/✗ |

### Changes by Type
- Standard: XX
- Normal: XX
- Emergency: X

### Notable Changes
1. {Description}
2. {Description}

### Issues/Lessons Learned
- {Issue and resolution}
```

---

## Related Documents

- [Development Standards](./DevelopmentStandards.md)
- [Deployment Pipelines](../Deployment/Pipelines/README.md)
- [Audit Procedures](./AuditProcedures.md)

---

*Last Updated: December 2024*
*Review Date: March 2025*
