# Permissions

> Access control for workspaces, datasets, and reports.

## Workspace roles

| Role | Can do |
|------|--------|
| Viewer | Read content and shared items. Cannot save or publish. |
| Contributor | Add and edit content. Cannot publish or share. |
| Member | Publish and share content, and manage permissions for others. |
| Admin | Add members and guests, and manage the workspace. |

Assign the **least privileged role that lets someone do their job**. Broad
Member access is a common cause of accidental content duplication.

## Identity types

- **Users** — assigned to individuals. Avoid for anyone who may leave.
- **Groups** — prefer Microsoft Entra ID groups so access follows the group.
- **Service principals** — for automation. See
  [ServicePrincipalSetup.md](../../Governance/ServicePrincipalSetup.md).
- **Guests** — external users; require explicit invitation and a tenant policy.

## Row-level security

Workspace roles do not limit which *rows* a viewer sees. Apply RLS for that:

- [RLSPatterns.md](../../Governance/RLSPatterns.md)
- [AccessControlMatrix.md](../../Governance/AccessControlMatrix.md)

## Auditing

Review membership periodically, since roles persist after someone changes
team. See [AuditProcedures.md](../../Governance/AuditProcedures.md).
