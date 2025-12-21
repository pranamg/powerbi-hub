# General Power BI Prompts

Prompts for architecture, administration, troubleshooting, and general Power BI tasks.

## Architecture & Planning

```
Design a Power BI architecture for:
- Users: [number and types]
- Data sources: [list sources]
- Refresh frequency: [requirements]
- Security needs: [describe]
Recommend workspace structure, deployment strategy, and licensing.
```

```
Compare these approaches for my scenario:
- Import mode vs DirectQuery vs Live Connection
- Single dataset vs multiple datasets
- Personal vs shared datasets
Given: [describe data volume, refresh needs, user count]
```

## Administration

```
Create a Power BI governance framework covering:
- Naming conventions
- Workspace organization
- Security policies
- Development standards
- Change management
For organization type: [enterprise/SMB/department]
```

```
What tenant settings should I configure for:
- Security requirement: [describe]
- User self-service level: [low/medium/high]
- External sharing needs: [yes/no]
Explain each recommended setting.
```

## Security

```
Implement row-level security for:
- Requirement: [users see only their data]
- User identification: [UPN, email, custom]
- Data model: [describe tables and relationships]
- Edge cases: [managers see team, admins see all]
Provide DAX expressions and testing approach.
```

## Troubleshooting

```
Diagnose this Power BI issue:
- Symptom: [describe what's happening]
- Expected: [what should happen]
- Environment: [Desktop/Service/Embedded]
- Recent changes: [any changes made]
What are possible causes and how do I investigate?
```

```
My scheduled refresh is failing with error:
[paste error message]
Data source: [type]
Gateway: [yes/no, type]
What's causing this and how do I fix it?
```

## Development Workflow

```
Set up a Power BI development workflow with:
- Environments: [Dev/Test/Prod]
- Source control: [Git/Azure DevOps]
- Team size: [number]
Include branching strategy and deployment process.
```

## Embedding & Integration

```
Compare Power BI embedding options for:
- Use case: [internal app/customer-facing/portal]
- Users: [internal/external, count]
- Authentication: [AAD/app owns data]
- Budget: [considerations]
Recommend approach with architecture.
```

## Capacity Planning

```
Size Power BI Premium capacity for:
- Concurrent users: [number]
- Datasets: [count and sizes]
- Refresh frequency: [schedule]
- Report complexity: [simple/medium/complex]
Recommend SKU and justify.
```

## Training & Adoption

```
Create a Power BI training curriculum for:
- Audience: [business users/developers/admins]
- Current skill level: [beginner/intermediate]
- Time available: [hours/days]
- Focus areas: [list priorities]
Include topics, exercises, and resources.
```

## Prompt Tips

For general Power BI questions, include:
1. Organization context (size, industry)
2. Technical environment (cloud/on-prem, licensing)
3. Current state and desired state
4. Constraints (budget, timeline, skills)
5. Specific requirements vs nice-to-haves
