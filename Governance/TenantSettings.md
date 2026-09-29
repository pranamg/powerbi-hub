---
title: "Tenant Settings Reference"
tags: [governance, security, administration]
audience: [bi-admin]
difficulty: advanced
last_verified: 2026-09-29
---

# Tenant Settings Reference

The rest of this folder **assumes these settings exist** without ever naming
them. This page is that reference.

> Settings change. Verify the current list in the
> [Power BI Admin portal](https://learn.microsoft.com/en-us/power-bi/admin/service-admin-portal)
> rather than treating this page as authoritative. Use it to know **which
> settings matter and why**, and to spot a setting that has been renamed or
> retired.

---

## How tenant settings work

- Set in the **Power BI Admin portal** by a Fabric or Power BI administrator
- Apply to the **whole tenant**, not per user or workspace
- Some can be **overridden by workspace admins**, so a tenant-wide setting is
  not always the effective one
- **Security group exceptions** can re-enable a setting for specific users
- Changing a setting can **interrupt open sessions** — apply in a window, and
  tell people first

The three states you will see: **Enabled**, **Disabled**, and **Not
configured** (which behaves as disabled, but is distinguishable in the portal).

---

## Settings that block Power BI outright

Disable these only with a specific reason. They stop people doing their jobs.

| Setting | When you would disable it |
|---|---|
| Allow users to publish to the service | Restricting a pilot to Desktop only |
| Allow users to create personal workspaces | Managing workspace sprawl at scale |
| Allow exit-time promotion of personal content | Before an organisational Fabric rollout |
| Allow export of report content | Data-exfiltration risk. Strong candidate for a security group exception |
| Allow subscriptions and scheduled reports | Report distribution risk |
| Allow live connections | Regulating which sources reach the service |
| Allow ad hoc analysis of service data | Data-governance requirement |

> **Export and live connections** are the two most commonly reconsidered. Both
> cause real friction for analysts, so before disabling either, decide whether
> your response is a real one or a symptom of a missing data-loss-prevention
> process.

---

## Security settings

| Setting | Default | Notes |
|---|---|---|
| Allow access to Azure AD objects in the Power BI app | Enabled | Being deprecated in favour of Entra-only access. Plan the migration |
| Require email one-time passcode (OTP) for activation | Enabled | |
| Allow service principals to use Power BI APIs | Disabled | Must be enabled for CI/CD — see [Service Principal Setup](./ServicePrincipalSetup.md) |
| Block service principal creation | Varies | If set, admin-created principals are still allowed |
| Allow users to add users to workspaces | Enabled | |
| Limit users who can add others to workspaces | — | Prefer contributor roles over member |
| Allow workspace admins to share semantic models | Enabled | |

### The XMLA endpoint setting

This one causes the most support calls, because its failure mode is confusing.

The XMLA endpoint governs every tool that connects to semantic models over XMLA
— **including the Power BI MCP server**. There is no tenant setting that blocks
MCP specifically.

| Capability | XMLA read/write | Consequences |
|---|---|---|
| Semantic model in the service | **Read** | Power BI Desktop, external tools, and the MCP server can **read** but not **write** |
| Semantic model in the service | **Read write** | Full read/write for those tools |

If the MCP server can read your model but every change fails with a permission
error, the cause is one of two things, in this order:

1. The user has **Build** but not **Write** permission on the semantic model
2. The capacity's XMLA endpoint is set to **Read**

Note this is separate from the memory limit — the XMLA setting is a gateway
capability, not a capacity size question.

---

## AI and Copilot settings

These are the fastest-moving group, and the ones most likely to have changed
since this page was written.

| Setting | Notes |
|---|---|
| Users can use Copilot in Power BI | The master switch. Off by default on many tenants |
| Allow Copilot to prepare semantic models for AI | Governs whether authors can use **Prep data for AI** |
| Users can use the Power BI Model Context Protocol server endpoint | Required for the **hosted** Power BI Authoring MCP server |

> The MCP server endpoint setting is easy to miss. If a Fabric administrator
> has not enabled it, hosted MCP sign-in fails with an error that does not
> mention tenant settings. See [MCP Server Guide](../Integrations/MCP/ServerGuide.md).

Also relevant to governance, though not a single switch: **Approving a semantic
model for Copilot** is a deliberate act, and your AI data-handling policy
governs what leaves the tenant. See [AI Readiness](../Data/AIReadiness/README.md).

---

## Refresh and capacity settings

| Setting | Notes |
|---|---|
| Allow service principals to refresh semantic models in the background | Enables unattended refresh in CI |
| Allow refresh on semantic models with row-level security enforced by an identity | If blocked, RLS refresh breaks for service principals |
| Prolong automatic refresh of cached data | Defaults to 24 hours for Pro/PPU |
| Set minimum refresh frequency for automatic refresh | Default 15 minutes |
| Allow sharing of individual reports and dashboards | Prefer workspace-level sharing |
| Limit sharing of individual reports and dashboards to users in the same group | Hard sharing restriction |

> The RLS-with-identity setting is a common surprise: a semantic model secured
> with RLS driven by an identity needs this enabled or scheduled refresh fails
> for service principals while working fine interactively.

---

## Tenant-wide security integration

| Setting | Notes |
|---|---|
| Allow information protection sensitivity labels to be applied in Power BI | Pairs with [Data Classification](./DataClassification.md) |
| Allow users to apply sensitivity labels to semantic models they create | |
| Require sensitivity labels in semantic models | Strong governance stance, high friction |

---

## Auditing and monitoring

| Setting | Notes |
|---|---|
| Allow access to dataset details in the Power BI Activity Log | Off by default. Needed for most audit reporting |
| Allow access to Power BI Audit Logs Premium | For long retention |
| Allow users to see their personal usage metrics | |
| Allow users to modify their own regional settings | |
| Send usage data to Power BI | On by default. Required for adoption reporting |

Audit log access being off by default is a common finding in governance
assessments — the audit programme cannot start without it. See
[Audit Procedures](./AuditProcedures.md).

---

## Using security groups as exceptions

The mechanism that makes restrictive settings workable.

1. Create an Entra security group for the people who need the capability
2. Configure the setting to **Disabled** tenant-wide
3. Enable it for that security group as an exception

This is how you can disable export for the organisation while keeping it for a
data team, without a policy exception process that undermines the setting.

A setting configured this way shows as disabled in the portal, which surprises
people auditing the configuration. Document which groups have which exceptions
where — [Access Control Matrix](./AccessControlMatrix.md) is the natural home.

---

## Reviewing settings

Do it on a **cadence**, not once:

| Frequency | Review |
|---|---|
| Quarterly | Walk the full list; check nothing has changed or been retired |
| After any incident | Which setting would have limited the blast radius? |
| Before a rollout | Will this setting block the thing you are deploying? |
| Annually | Compare against a recognised baseline |

For each setting, be able to answer: what is its value, why is it that value,
and who owns changing it. A setting nobody can justify is a setting nobody will
maintain.

---

## Related

- [Development Standards](./DevelopmentStandards.md)
- [Data Classification](./DataClassification.md)
- [Access Control Matrix](./AccessControlMatrix.md)
- [Audit Procedures](./AuditProcedures.md)
- [Service Principal Setup](./ServicePrincipalSetup.md)
- [Admin portal documentation](https://learn.microsoft.com/en-us/power-bi/admin/service-admin-portal)
