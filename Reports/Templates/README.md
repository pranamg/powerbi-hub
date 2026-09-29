# Report Templates

> Starting points for new reports.

## Status

This folder is a stub. No content has been written yet.

## What belongs in a template

- Page structure and visual positions for a common scenario.
- A theme already applied, so the template renders in house style.
- Placeholder measures with naming that signals where real measures go.
- A one-line note on what the template is for and when to prefer it.

## What does not

- **Real data.** A template shipped with sample values is a template that gets
  copied with the wrong numbers still in it, and they reach production.
- Environment-specific paths, workspace names, or URLs. Use a parameter table
  instead so the template can be promoted between environments.
- Sensitivity labels or workspace settings. Those are applied per environment,
  not inherited from a template.

## Stripping a template

When promoting a working report to a template, remove anything specific to
that report. A template that still contains a real dataset name, a customer's
slicer values, or a bespoke measure will be copied, and the residue becomes
someone else's defect.

## Adding a template

Prefer **PBIP/PBIR** or a documented TMDL model over a `.pbix` file, so the
template is reviewable in a pull request rather than only in the Power BI
Service.

## Related

- [Report examples](../Examples/) — reference implementations
- [Design templates](../../Design/Templates/) — layout, theming, and visual conventions
- [Themes](../../Design/Themes/) — house themes to apply
- [Dashboards/Templates/](../../Dashboards/Templates/) — dashboard equivalents
