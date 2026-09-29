---
title: Power Apps
tags: [integration]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Power Apps

> Embedding Power BI content in Power Apps.

## Approaches

| Approach | Use when |
|----------|----------|
| **Power BI tile in Power Apps** | Simple case: a report embedded in a screen |
| **Power Apps report page** | A single page of a report, sized for a phone or tablet |
| **Power BI Embedded** | The report is embedded in a custom app with full control |

## Guidance

- **Test on the target device.** A report designed for a desktop browser is
  usually unusable on a phone, and this is the most common complaint.
- Set the **page layout** deliberately (portrait or landscape) rather than
  letting it default.
- Pass **filter context** through to the report so the user is not shown
  everything and left to find their own data.
- Decide early whether you need Embedded. It requires capacity and licensing,
  and is significantly more work than a tile.
- Remember that a user of the Power App still needs **Power BI permissions**
  unless you are using Embedded, which is a common source of access bugs.

## Related

- [Power Automate](../PowerAutomate/)
- [Collaboration permissions](../../Collaboration/Permissions/)
