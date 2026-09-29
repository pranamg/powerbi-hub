---
title: Icons
tags: [design, assets]
audience: [report-author]
difficulty: beginner
last_verified: 2026-09-29
---

# Icons

> Icon assets for reports and dashboards.

## Choosing icons

- Prefer a **single consistent set**. Mixing icon styles is immediately visible
  and reads as unfinished.
- Match the icon's visual weight and colour to the surrounding text.
- **Icons must be paired with a label** unless the meaning is unambiguous from
  context. An unexplained icon is a barrier, not a shortcut.

## Technical notes

- **SVG** scales cleanly and supports theming via currentColor. See the
  [SVG custom visuals](../../../Visuals/CustomVisuals/SVG/) for measure-driven
  icons.
- **PNG** is a reasonable fallback where SVG is not supported, at 2x resolution
  for retina displays.
- Small icons embedded inline are fine; avoid large bitmap assets that bloat
  the report.

## Related

- [High resolution](../HighRes/) · [Low resolution](../LowRes/)
- [Visuals tips](../../../TipsAndTricks/Visuals.md)
