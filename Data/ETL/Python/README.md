# Python

> Python-based ETL.

## Practice

- **Use only where M is genuinely awkward** — statistical modelling, fuzzy
  matching, or specialised parsing. Ordinary shaping belongs in Power Query.
- The Python runtime must exist on every machine that refreshes, including the
  gateway. A script that works in Desktop and fails in Service almost always
  means a missing runtime or package.
- Return a **pandas DataFrame** and keep dtypes and column names stable.
- Python cannot fold, so filter and project in M **before** the Python step.
- **Pin package versions** and record them, since an unpinned upgrade is a
  silent way to change results.

## Related

- [Python data sources](../../DataSources/Python/)
- [Jupyter notebooks](../../../Scripts/JupyterNotebooks/)
- [Custom functions](../../../Queries/PowerQuery/CustomFunctions/)
