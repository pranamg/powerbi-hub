# Azure Services

> Connecting Power BI to other Azure services.

## Common integrations

| Service | Typical use |
|---------|-------------|
| Azure Synapse | Large-scale analytical workloads behind a SQL or dedicated pool endpoint |
| Azure Data Lake / OneLake | File-based data with DirectLake or Spark processing |
| Azure Functions | Server-side logic for refresh-time or query-time automation |
| Azure SQL | Operational and analytical SQL sources |
| Azure DevOps | CI/CD for content deployed via the REST API or XMLA endpoint |

## Guidance

- **Keep credentials in the gateway**, not in the report definition. See
  [Gateway scripts](../../Scripts/PowerShell/Gateway/).
- Use a **managed identity or service principal** for automated access rather
  than a user account, which breaks when the person leaves.
- Deploy through the **XMLA endpoint** or Power BI REST API for anything
  automated; the file-based upload path does not scale.
- Confirm **data residency** requirements before routing sensitive data
  through a new service.

## Related

- [Fabric](../Fabric/) · [Power Automate](../PowerAutomate/) · [Power Apps](../PowerApps/)
- [Service principal setup](../../Governance/ServicePrincipalSetup.md)
- [Deployment pipelines](../../Deployment/Pipelines/)
