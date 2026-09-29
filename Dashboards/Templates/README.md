# Dashboard Templates

> Starting points for new dashboards.

## Status

This folder is a stub. No content has been written yet.

## What belongs in a template

A dashboard is mostly **coordination between reports**, so a dashboard
template is usually a page arrangement rather than a single artefact:

- The tile layout, with each tile's intended report and purpose noted.
- Navigation preserved between the source reports.
- Any shared slicer or filter defaults the reader is expected to start from.
- The house theme applied consistently across every tile.

## What does not

- Real data, for the same reason as report templates: residue gets copied.
- Tiles pointing at a specific customer's reports.
- Hard-coded workspace or environment names; use parameters.

## Keeping a dashboard coherent

- Give every tile a **one-line purpose**. A tile that needs a paragraph to
  explain does not belong on the dashboard.
- Keep the **filter context visible** on each embedded report, so a reader
  knows what a tile is showing.
- Be consistent about which measure appears on which tile. The same KPI in two
  places with two different numbers destroys trust in both.

## Related

- [Dashboard examples](../Examples/) — reference implementations
- [Report templates](../Templates/) — single-report equivalents
- [Design guidelines](../../Design/Guidelines/) — layout and colour standards
- [Themes](../../Design/Themes/) — house themes to apply
