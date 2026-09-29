---
title: Buttons
tags: [design, visuals]
audience: [report-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Buttons

> Navigation and action buttons.

## Uses

| Purpose | Notes |
|---------|-------|
| Navigation | Move to another report page or report. |
| Drill-through | Present a filtered detail page. |
| State toggling | Switch a slicer or a bookmark to compare views. |
| Reset state | Return the page to a known filter state. |

## Guidance

- **Label the destination.** A button reading "Explore" is vague; "See detail
  by store" tells the reader where they are going.
- Keep button **styling consistent** and visually distinct from data visuals,
  so controls are not mistaken for content.
- Use **bookmarks** to store filter state. Reconstructing slicer state
  manually with DAX is fragile and hard to maintain.
- A button whose action is unavailable should be hidden or disabled, not left
  inert.
- Remember that report **navigation order** matters: a reader who lands on a
  page with no way back is stuck.

## Related

- [Cards](../Cards/) · [Tables](../Tables/) · [Other](../Other/)
- [Design guidelines](../../Guidelines/)
