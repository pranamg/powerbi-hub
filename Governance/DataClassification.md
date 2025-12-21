# Data Classification Policy

> **Purpose:** Define data classification levels and handling requirements for Power BI content

---

## Overview

Data classification ensures appropriate security controls are applied based on data sensitivity. All Power BI content must be classified according to this policy.

---

## Classification Levels

### Level 1: Public

**Definition:** Information intended for public disclosure with no business impact if shared.

| Attribute | Requirement |
|-----------|-------------|
| Examples | Published marketing data, public financial reports |
| RLS Required | No |
| Encryption | Standard (at rest) |
| External Sharing | Allowed |
| Export | Allowed |
| Sensitivity Label | Public |

### Level 2: Internal

**Definition:** General business information not intended for external audiences.

| Attribute | Requirement |
|-----------|-------------|
| Examples | Internal KPIs, operational metrics, sales summaries |
| RLS Required | Recommended |
| Encryption | Standard (at rest) |
| External Sharing | Not allowed |
| Export | Allowed with approval |
| Sensitivity Label | General |

### Level 3: Confidential

**Definition:** Sensitive business information that could cause harm if disclosed.

| Attribute | Requirement |
|-----------|-------------|
| Examples | Financial forecasts, customer data, pricing, HR metrics |
| RLS Required | Required |
| Encryption | Enhanced (at rest + transit) |
| External Sharing | Not allowed |
| Export | Restricted |
| Sensitivity Label | Confidential |

### Level 4: Highly Confidential

**Definition:** Critical information requiring maximum protection.

| Attribute | Requirement |
|-----------|-------------|
| Examples | PII, PHI, M&A data, executive compensation, trade secrets |
| RLS Required | Required + OLS |
| Encryption | Enhanced + additional controls |
| External Sharing | Prohibited |
| Export | Prohibited |
| Sensitivity Label | Highly Confidential |

---

## Classification Matrix

| Data Type | Classification | RLS | OLS | Export | External |
|-----------|---------------|-----|-----|--------|----------|
| Revenue totals | Internal | ✓ | - | ✓ | ✗ |
| Customer names | Confidential | ✓ | - | ✗ | ✗ |
| Customer PII | Highly Confidential | ✓ | ✓ | ✗ | ✗ |
| Employee data | Confidential | ✓ | ✓ | ✗ | ✗ |
| Salary data | Highly Confidential | ✓ | ✓ | ✗ | ✗ |
| Financial forecasts | Confidential | ✓ | - | ✗ | ✗ |
| Published metrics | Public | - | - | ✓ | ✓ |
| Operational KPIs | Internal | ✓ | - | ✓ | ✗ |
| Pricing data | Highly Confidential | ✓ | ✓ | ✗ | ✗ |
| Medical records | Highly Confidential | ✓ | ✓ | ✗ | ✗ |

---

## Implementation Requirements

### Workspace Organization

```
Workspaces by Classification:
├── [Public] Marketing Analytics
├── [Internal] Operations Dashboard
├── [Confidential] Sales Analytics
└── [Highly Confidential] Executive Finance
```

### Naming Conventions

Include classification in workspace names:
- `[PUBLIC] Marketing Metrics`
- `[INT] Sales Operations`
- `[CONF] Customer Analytics`
- `[HC] Executive Compensation`

### Sensitivity Labels

Apply Microsoft Information Protection labels:

```
Power BI Admin Portal:
├── Tenant Settings
│   └── Information Protection
│       ├── Allow users to apply sensitivity labels
│       └── Apply default sensitivity labels
```

**Label Configuration:**
| Label | Color | Encryption | Watermark |
|-------|-------|------------|-----------|
| Public | Green | None | None |
| General | Blue | None | None |
| Confidential | Orange | Required | "Confidential" |
| Highly Confidential | Red | Required | "Highly Confidential" |

---

## Security Controls by Level

### Level 1-2: Standard Controls

- [ ] Workspace access limited to employees
- [ ] Standard authentication
- [ ] Basic audit logging

### Level 3: Enhanced Controls

- [ ] RLS implementation required
- [ ] Workspace access restricted to need-to-know
- [ ] Export disabled or restricted
- [ ] Enhanced audit logging
- [ ] Quarterly access review

### Level 4: Maximum Controls

- [ ] RLS + OLS implementation required
- [ ] Workspace access strictly controlled
- [ ] All export disabled
- [ ] External sharing blocked
- [ ] Watermarks applied
- [ ] Monthly access review
- [ ] Data loss prevention (DLP) policies
- [ ] Privileged access management

---

## Data Handling Procedures

### Classification Assessment

Before creating any report or dataset:

1. **Identify data sources** - List all tables and columns
2. **Assess sensitivity** - Review each data element
3. **Determine classification** - Apply highest level found
4. **Document decision** - Record in data catalog

### Classification Checklist

```markdown
## Data Classification Assessment

**Report/Dataset Name:** ________________
**Owner:** ________________
**Date:** ________________

### Data Elements Review
| Column/Measure | Description | Contains PII? | Classification |
|----------------|-------------|---------------|----------------|
|                |             | Yes/No        |                |

### Classification Decision
- [ ] Public
- [ ] Internal
- [ ] Confidential
- [ ] Highly Confidential

### Justification
_Explain the classification decision:_

### Required Controls
- [ ] RLS configured
- [ ] OLS configured (if HC)
- [ ] Sensitivity label applied
- [ ] Export settings reviewed
- [ ] Access list documented
```

### Reclassification

Data may need reclassification when:
- Data sources change
- Business requirements change
- Regulatory requirements change
- Security incidents occur

**Process:**
1. Submit reclassification request
2. Data steward review
3. Update controls if approved
4. Document change

---

## Compliance Mapping

| Regulation | Applicable Levels | Key Requirements |
|------------|-------------------|------------------|
| GDPR | L3, L4 | PII protection, consent, right to erasure |
| HIPAA | L4 | PHI protection, access controls, audit |
| SOX | L3, L4 | Financial data integrity, access controls |
| PCI-DSS | L4 | Cardholder data protection |
| CCPA | L3, L4 | Consumer data rights |

---

## Responsibilities

### Data Owners
- Classify data appropriately
- Review access quarterly
- Report incidents immediately

### Report Developers
- Implement required security controls
- Apply sensitivity labels
- Document data lineage

### Workspace Admins
- Enforce classification controls
- Review workspace membership
- Monitor usage and access

### BI Administrators
- Configure tenant-level policies
- Monitor compliance
- Conduct audits

---

## Audit Requirements

| Classification | Audit Frequency | Retention |
|----------------|-----------------|-----------|
| Public | Annual | 1 year |
| Internal | Semi-annual | 2 years |
| Confidential | Quarterly | 5 years |
| Highly Confidential | Monthly | 7 years |

---

## Related Documents

- [Development Standards](./DevelopmentStandards.md)
- [RLS Patterns](./RLSPatterns.md)
- [OLS Configuration](./OLSConfiguration.md)
- [Access Control Matrix](./AccessControlMatrix.md)

---

*Last Updated: December 2024*
*Review Date: March 2025*
