# Workspaces

> Workspace structure, roles, and lifecycle guidance.

## Choosing a workspace

| Workspace type | Use for |
|----------------|---------|
| My workspace | Personal, unsaved work in progress. Not backed up or shareable. |
| Shared workspace | Team content. Backed up, and access is managed. |
| Premium capacity | Large models requiring dedicated memory. |

Content in **My workspace** is not preserved when you leave an organisation,
and datasets there cannot be shared. Anything durable belongs in a shared
workspace.

## Naming

Follow the conventions in
[Governance/NamingConventions.md](../../Governance/NamingConventions.md) so
workspaces are identifiable in inventories and logs. Include the owning team
and the environment, for example `FIN-Analytics-Prod`.

## Grouping content

- Keep related datasets, reports, and dashboards in the same workspace so
  that permissions and lineage stay together.
- Avoid nesting workspaces more than one level deep; it complicates migration.
- Tag workspaces where your governance programme requires it.

## Related

- [Permissions](../Permissions/)
- [Team Collaboration](../../Documentation/UserGuides/TeamCollaboration.md)
- [Collaboration folder overview](../)
