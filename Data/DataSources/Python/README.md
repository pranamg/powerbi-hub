# Python

> Python-based data sources.

## Practice

- Use Python for transformations that are genuinely awkward in M, typically
  statistical or machine-learning work. For ordinary shaping, Power Query is
  faster and better supported.
- The **Python source** must be installed on every machine that refreshes,
  including the gateway host. This is the most common cause of a refresh that
  works locally and fails in Service.
- Return a **pandas DataFrame**, and keep the column types stable between
  runs. Changing dtypes silently between refreshes causes downstream errors.
- Remember that a Python step **does not fold**, so source filtering and
  projection must happen in M before it.


## General guidance

- **Prefer a shared semantic model** in Power BI over importing the same source
  into many reports. It centralises logic and refresh.
- **Import by default.** Choose DirectQuery when data volume or freshness
  genuinely rules it out, and see [Composite Models](../../../Optimization/CompositeModels.md).
- **Protect credentials** in a gateway rather than embedding them in the file.

## Related

- [Python ETL](../../ETL/Python/)
- [Python visuals](../../../Visuals/PythonVisuals/)
- [Custom functions](../../../Queries/PowerQuery/CustomFunctions/)
