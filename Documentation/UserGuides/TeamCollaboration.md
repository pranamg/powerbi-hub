# Team Collaboration Patterns

> **Purpose:** Best practices for Power BI team development, version control, and collaboration workflows

---

## Overview

Effective team collaboration in Power BI development requires clear processes for:
- Version control and branching
- Code review and quality gates
- Environment management
- Communication and handoffs

---

## Team Roles

| Role | Responsibilities |
|------|------------------|
| **Data Modeler** | Semantic model design, relationships, DAX measures |
| **Report Developer** | Visualizations, UX, report design |
| **Data Engineer** | Data pipelines, Dataflows, Lakehouse |
| **BI Admin** | Workspace management, security, deployment |
| **Business Analyst** | Requirements, validation, UAT |

---

## Git Workflow Patterns

### Pattern 1: GitFlow for Power BI

```
main (production)
│
├── hotfix/critical-fix ────────────────────┐
│                                           │
├── release/v1.2 ◄──────────────────────────┼───┐
│                                           │   │
└── develop ◄───────────────────────────────┘   │
    │                                           │
    ├── feature/new-sales-report ───────────────┤
    ├── feature/model-optimization ─────────────┤
    └── feature/rls-implementation ─────────────┘
```

**Branch Purposes:**
| Branch | Purpose | Merges To |
|--------|---------|-----------|
| `main` | Production-ready code | - |
| `develop` | Integration branch | `main` via release |
| `feature/*` | New features | `develop` |
| `release/*` | Release preparation | `main` + `develop` |
| `hotfix/*` | Production fixes | `main` + `develop` |

### Pattern 2: Trunk-Based Development

```
main ─────●─────●─────●─────●─────●─────●─────►
          │     │     │     │     │     │
          ▼     ▼     ▼     ▼     ▼     ▼
       feature feature fix  feature fix feature
       (short-lived branches, <1 day)
```

**Best for:**
- Small teams (2-4 developers)
- Continuous deployment
- High automation maturity

### Pattern 3: Environment Branches

```
┌─────────────────────────────────────────────────────┐
│                     Branches                         │
├─────────────────────────────────────────────────────┤
│  dev ──────► test ──────► prod                      │
│   │           │            │                        │
│   ▼           ▼            ▼                        │
│ Dev WS    Test WS     Prod WS                       │
│ (auto)    (manual)   (approval)                     │
└─────────────────────────────────────────────────────┘
```

**Workflow:**
1. Developers work in `dev` branch
2. Auto-deploy to Dev workspace
3. PR to `test` for QA
4. PR to `prod` with approvals

---

## Branching Conventions

### Branch Naming

```
<type>/<ticket-id>-<short-description>

Examples:
feature/JIRA-123-sales-ytd-measure
bugfix/JIRA-456-fix-filter-context
refactor/JIRA-789-optimize-date-table
docs/JIRA-101-update-readme
```

### Commit Messages

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
| Type | Description |
|------|-------------|
| `feat` | New feature (measure, visual, report) |
| `fix` | Bug fix |
| `refactor` | Code restructuring |
| `perf` | Performance improvement |
| `docs` | Documentation |
| `style` | Formatting, naming |
| `test` | Adding tests |

**Examples:**
```
feat(measures): add YTD sales with fiscal year support

- Created Sales YTD measure using TOTALYTD
- Added fiscal year parameter support
- Updated TimeIntelligence calculation group

Closes JIRA-123
```

```
fix(rls): correct region filter for APAC users

Users in APAC region were seeing all regions due to
missing filter in RLS role definition.

Fixes JIRA-456
```

---

## Code Review Process

### Pull Request Template

```markdown
## Description
<!-- What changes does this PR introduce? -->

## Type of Change
- [ ] New feature (measure, visual, report page)
- [ ] Bug fix
- [ ] Performance improvement
- [ ] Refactoring
- [ ] Documentation

## Changes Made
<!-- List specific changes -->
- 
- 
- 

## Testing Done
- [ ] Tested in Power BI Desktop
- [ ] Verified DAX calculations
- [ ] Checked RLS (if applicable)
- [ ] Performance tested with production data volume
- [ ] Cross-browser tested (if applicable)

## Screenshots
<!-- Add before/after screenshots for visual changes -->

## Checklist
- [ ] Follows naming conventions
- [ ] No hardcoded values
- [ ] Measures have descriptions
- [ ] No breaking changes to existing reports
- [ ] Updated documentation (if needed)

## Related Issues
Closes #
```

### Review Checklist

**For Data Model Changes:**
- [ ] Relationships are correct (cardinality, direction)
- [ ] No circular dependencies
- [ ] Column data types appropriate
- [ ] No unnecessary columns imported
- [ ] Naming conventions followed

**For DAX Measures:**
- [ ] Logic is correct
- [ ] Handles edge cases (blanks, zeros)
- [ ] Performance acceptable
- [ ] Format string appropriate
- [ ] Description added
- [ ] Folder organization correct

**For Reports:**
- [ ] Visuals render correctly
- [ ] Filters work as expected
- [ ] Mobile layout (if required)
- [ ] Accessibility considerations
- [ ] Consistent styling/theme

### Review Workflow

```
Developer                    Reviewer                    Approver
    │                           │                           │
    ├── Create PR ─────────────►│                           │
    │                           │                           │
    │◄── Request changes ───────┤                           │
    │                           │                           │
    ├── Address feedback ──────►│                           │
    │                           │                           │
    │                           ├── Approve ───────────────►│
    │                           │                           │
    │                           │                    Merge ─┤
    │                           │                           │
```

---

## Parallel Development

### Avoiding Conflicts

**Model.bim / TMDL Conflicts:**
1. **Divide by area** - Different developers own different tables/measures
2. **Feature flags** - Develop in separate measure groups, merge later
3. **Short-lived branches** - Reduce merge window
4. **Frequent integration** - Merge to develop often

### Work Division Strategies

**By Functional Area:**
```
Developer A: Sales measures, Sales report pages
Developer B: Inventory measures, Inventory reports
Developer C: Finance measures, Finance reports
```

**By Layer:**
```
Data Engineer: Data model, relationships, base tables
DAX Developer: Measures, calculation groups
Report Developer: Visualizations, UX
```

**By Feature:**
```
Sprint 1:
- Dev A: Feature X (end-to-end)
- Dev B: Feature Y (end-to-end)
- Dev C: Feature Z (end-to-end)
```

### Handling Merge Conflicts

**TMDL Conflicts:**
```bash
# When conflicts occur in .tmdl files
git checkout --theirs Tables/DimDate.tmdl  # Take their version
git checkout --ours Tables/DimDate.tmdl    # Take our version

# Or manually merge in VS Code with TMDL extension
```

**Best Practice:** Use semantic merge tools that understand TMDL structure

---

## Environment Strategy

### Workspace Mapping

| Environment | Workspace | Branch | Refresh |
|-------------|-----------|--------|---------|
| Development | Sales-Dev | `develop` | On-demand |
| Test/QA | Sales-Test | `test` | Scheduled |
| UAT | Sales-UAT | `release/*` | Scheduled |
| Production | Sales-Prod | `main` | Scheduled |

### Promotion Flow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│   Dev   │───►│  Test   │───►│   UAT   │───►│  Prod   │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │
  Auto PR       QA Sign-off   UAT Sign-off   Change Approval
  to Test       Required      Required       Required
```

### Data Strategies

| Environment | Data Source | Data Volume |
|-------------|-------------|-------------|
| Dev | Dev database / Sample | 1% of prod |
| Test | Test database | 10% of prod |
| UAT | Prod copy (masked) | 100% |
| Prod | Production | 100% |

---

## Communication Patterns

### Daily Standups (BI Team)

```
1. What I completed yesterday
2. What I'm working on today
3. Any blockers
4. Any model/report dependencies on others
```

### Handoff Documentation

When handing off work:

```markdown
## Handoff: [Feature/Report Name]

### Current State
- [ ] Model complete
- [ ] Measures complete
- [ ] Report layout complete
- [ ] RLS configured
- [ ] Testing complete

### What's Done
- List completed items

### What's Remaining
- List remaining work

### Known Issues
- List any issues

### How to Test
1. Step-by-step testing instructions

### Dependencies
- External dependencies
- Other team members' work needed

### Notes for Next Developer
- Any gotchas or context needed
```

### Slack/Teams Channels

| Channel | Purpose |
|---------|---------|
| #bi-team | General team communication |
| #bi-deployments | Deployment notifications |
| #bi-incidents | Production issues |
| #bi-code-review | PR notifications |
| #bi-questions | Technical Q&A |

---

## Quality Gates

### Pre-Commit Checks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-tmdl
        name: Validate TMDL syntax
        entry: scripts/validate-tmdl.ps1
        language: system
        files: \.tmdl$
      
      - id: check-naming
        name: Check naming conventions
        entry: scripts/check-naming.ps1
        language: system
```

### CI Pipeline Checks

```yaml
# Automated checks on PR
stages:
  - stage: Validate
    jobs:
      - job: QualityGates
        steps:
          - script: |
              # Check for hardcoded values
              # Validate measure descriptions exist
              # Run Best Practice Analyzer
              # Check naming conventions
```

### Definition of Done

A feature is complete when:
- [ ] Code reviewed and approved
- [ ] All automated checks pass
- [ ] Manual testing completed
- [ ] Documentation updated
- [ ] Deployed to Test environment
- [ ] QA sign-off obtained
- [ ] No critical/high bugs open

---

## Conflict Resolution

### Technical Conflicts

1. **Discuss in PR comments** - Document the technical discussion
2. **Pair session** - Screen share to resolve complex issues
3. **Team review** - Bring to team if no consensus
4. **Architecture decision** - Document in ADR if significant

### Process Conflicts

1. **Retrospective** - Raise in team retro
2. **Process improvement** - Propose changes
3. **Trial period** - Test new process
4. **Evaluate** - Measure improvement

---

## Tools Integration

### Recommended Stack

| Tool | Purpose |
|------|---------|
| **Git** | Version control |
| **Azure DevOps / GitHub** | Repository, PRs, CI/CD |
| **VS Code** | TMDL editing |
| **Power BI Desktop** | Development |
| **Tabular Editor** | Advanced modeling |
| **DAX Studio** | Query testing |
| **Slack/Teams** | Communication |
| **Jira/Azure Boards** | Work tracking |

### VS Code Extensions

```json
{
  "recommendations": [
    "analysis-services.TMDL",
    "PowerBI.vscode-powerbi",
    "ms-vscode.powershell",
    "eamodio.gitlens",
    "github.vscode-pull-request-github"
  ]
}
```

---

## Onboarding New Team Members

### Week 1 Checklist

- [ ] Access to Git repository
- [ ] Access to all workspace environments
- [ ] Local development environment setup
- [ ] Walkthrough of codebase structure
- [ ] Review coding standards documentation
- [ ] Shadow existing team member
- [ ] Complete first small PR (documentation/minor fix)

### Resources to Review

1. This Team Collaboration guide
2. [Development Standards](../../Governance/DevelopmentStandards.md)
3. [Naming Conventions](../../Governance/NamingConventions.md)
4. Repository README
5. Architecture documentation

---

## Related Documents

- [Development Standards](../../Governance/DevelopmentStandards.md)
- [Naming Conventions](../../Governance/NamingConventions.md)
- [Fabric Git Integration](./FabricGitIntegration.md)
- [Deployment Pipelines](../../Deployment/Pipelines/README.md)
- [Change Management](../../Governance/ChangeManagement.md)

---

*Last Updated: December 2024*
