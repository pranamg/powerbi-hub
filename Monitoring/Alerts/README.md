# Alerts

> Alert definitions and routing.

## What to alert on

Alert on things that need a **human decision**. An alert nobody acts on trains
people to ignore alerts.

| Signal | Priority |
|--------|----------|
| Dataset refresh failure | High — the data is stale and readers do not know |
| Capacity throttling or memory pressure | High — affects everyone on the capacity |
| Gateway offline or unavailable | High — blocks refresh entirely |
| Refresh duration trending upward | Medium — early warning of a future failure |
| Unusually low row counts after refresh | Medium — often a silent upstream failure |
| Report load time regression | Low — investigate during normal work |

## Practice

- Route alerts to a **group mailbox or Teams channel**, not an individual's
  inbox. Personal alerts stop when the person changes role.
- Include enough context to act: **which dataset, which gateway, when it last
  succeeded, and the error**.
- Set a **deduplication window** so a retrying dataset does not generate a
  flood.
- Review alerts periodically and **delete the ones that never lead to action**.

## Related

- [Logs](../Logs/) · [Metrics](../Metrics/)
- [Dataset refresh scripts](../../Scripts/PowerShell/Dataset/)
- [Optimization](../../Optimization/)
