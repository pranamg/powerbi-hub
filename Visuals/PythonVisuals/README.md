# Python Visuals

> Python-based custom visual scripts.

## Status

This folder is a stub. No content has been written yet.

## Current location

Working implementations currently live under
[CustomVisuals/Python](../CustomVisuals/Python/), including
`Seaborn_Heatmap.py` and `WordCloud.py`. Consider whether this folder is
still needed once content is added, rather than maintaining two places for
the same thing.

## Requirements

- Enable **Python visual support** in Power BI Desktop
  (*File → Options and settings → Options → Preview features*).
- The Python environment must be available on every machine that opens the
  report.
- **Bundle the data** the script needs. Python visuals do not have live
  access to the model and cannot respond to slicers directly.

## Related

- [R visuals](../RVisuals/) · [Custom visuals](../CustomVisuals/)
- [Python ETL](../../Data/ETL/Python/)
- [Python data sources](../../Data/DataSources/Python/)
