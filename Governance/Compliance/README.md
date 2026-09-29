# Compliance

> Compliance requirements and the evidence that supports them.

## Evidence to retain

Compliance is demonstrated by evidence, not by assertion. Keep, at minimum:

- **Workspace and dataset inventories**, with owners and last refresh dates.
- **Access reviews** showing who can reach what, and when it was last checked.
- **Data flow documentation** for sensitive data, including where it is stored
  and which regions it passes through.
- **Retention and deletion records.**
- **Change records** for governed content. See
  [ChangeManagement.md](../ChangeManagement.md).

## Practical guidance

- Assign an **owner** to every governed asset. Unowned content cannot be
  defended in an audit.
- Run access reviews on a **schedule** and record the outcome, including
  "reviewed, no change".
- Align retention with the **sensitivity of the data**, not with convenience.
  See [DataClassification.md](../DataClassification.md).
- Use **sensitivity labels** in the Power BI Service so classification travels
  with the content.

## Related

- [Audit procedures](../AuditProcedures.md)
- [Audits](../Audits/)
- [Access control matrix](../AccessControlMatrix.md)
