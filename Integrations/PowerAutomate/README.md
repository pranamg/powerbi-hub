---
title: Power Automate
tags: [integration]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Power Automate

> Automating Power BI with flows.

## Useful flows

| Trigger | Action |
|---------|--------|
| On refresh failure | Notify the owner, and open a ticket |
| On data arriving in a mailbox or SharePoint folder | Refresh the dataset |
| On a schedule | Export data to CSV or Excel and distribute it |
| On a request in Teams or SharePoint | Run a dataset refresh, then return a link |

## Guidance

- **Avoid using Power Automate where a script will do.** Flows have per-run
  licensing and are harder to version and test. Use
  [PowerShell scripts](../../Scripts/PowerShell/) for scheduled automation, and
  flows for event-driven and human-in-the-loop processes.
- Create flows in a **solution**, not in the personal account of whoever built
  them, so they can be moved between environments.
- Add **error handling** with a scope that catches failure, and make the
  failure visible to someone who can act on it.
- Be careful with **connector defaults**: an action that silently refreshes the
  development dataset rather than production is an easy mistake to ship.

## Related

- [Azure services](../AzureServices/)
- [Power Apps](../PowerApps/)
- [Admin scripts](../../Scripts/PowerShell/Admin/)
