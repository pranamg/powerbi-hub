# MSAccess

> Microsoft Access database sources.

## Caveats

Access is a legacy file format with limited concurrent read behaviour, and
Power BI support is limited. Treat it as a transitional source rather than a
target architecture.

## Practice

- Prefer migrating to SQL Server or a Fabric Lakehouse where the option exists.
- If Access must be used, query **saved queries or views** in the `.mdb`
  rather than raw tables, and copy the file to a controlled location before
  import so a local edit does not affect refresh.
- Import rather than DirectQuery; live querying of an Access file is fragile.


## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [SQL](../SQL/)
- [Data sources folder](../)
