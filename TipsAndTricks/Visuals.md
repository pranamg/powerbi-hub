---
title: Visuals Tips & Tricks
tags: [tips]
audience: [all]
difficulty: intermediate
last_verified: 2026-09-29
---

# Visuals Tips & Tricks

How to build reports people can read. The recurring theme: **every mark on
screen should answer a question the reader already has**.

> The written rules live in [Design Guidelines](../Design/Guidelines/README.md)
> and [Design Best Practices](../Design/BestPractices/README.md). This page
> is the short, practical version.

---

## Pick the right visual for the question

Most bad charts are the wrong type for the question being asked.

| The reader's question | Use | Not |
|------------------------|-----|-----|
| What is the value right now? | Card or multi-row card | A chart of one bar |
| How does it compare to a target? | Bullet chart | A line chart |
| How does it trend over time? | Line or area | A column chart with 200 bars |
| How do categories rank? | Bar (sorted) | A pie with 12 slices |
| How do two variables relate? | Scatter | A clustered column |
| How do parts make the whole? | Stacked bar, treemap | A 3D pie |
| Where is the distribution? | Histogram, box plot | An average-only line |

Sort bars by value unless the category has a natural order (time, size, a
hierarchy). A bar chart sorted alphabetically communicates nothing.

**Fewer visuals is better.** A page with one chart that answers one question
beats a dashboard of eight that each answer half of one.

---

## Size the field well

A common beginner error: putting a high-cardinality text field on a visual's
axis, producing hundreds of bars and an unreadable chart.

Before adding a field to an axis, ask what the visual will look like with a
million distinct values. Usually the answer is "a top N filter" instead:

- Add a top N visual-level filter (by the measure being shown)
- Put the remainder in an "Other" row so the total still reconciles
- Let users change the N via a parameter or a field parameter

Field parameters let the *filtering column* be chosen by the reader without
editing the visual. See
[Field Parameters](../Queries/DAX/FieldParameters/README.md).

---

## Use dual axes carefully

A dual-axis chart is a claim: "these two measures are related." That claim
needs to be true, and the reader needs to notice the shared axis is hidden.

- Only when the relationship is real and worth asserting
- Colour the series so it is clear which axis it belongs to
- Consider a scatter plot with a trend line instead — it shows the
  relationship without the axis trick
- Never dual-axis two measures with unrelated units just to fill space

---

## Format for the reader, not the source

Formatting is how you make a number answer a question.

| Instead of | Use |
|------------|-----|
| `1234567.89` | `1.2M` |
| `0.1534` | `15.3%` |
| `4711` | `4,711` |
| `2026-01-15 00:00:00` | `15 Jan 2026` |
| `TRUE` / `FALSE` | A word that means something |

- Always set a number format on a measure, even a simple one. The default is
  rarely what you want.
- Keep formats consistent across a report. If revenue is abbreviated on one
  page, it must be on all of them.
- Precision should match the data's actual certainty. Two decimal places on a
  whole-number count is noise.
- Put units in the label or the measure name, not in every value:
  `Revenue (£m)` beats appending "m" to each number.

---

## Conditional formatting

Conditional formatting should encode a decision, not decorate.

- **Icons** for status against a threshold (RAG). See
  [RAG_Icons.dax](../Visuals/CustomVisuals/SVG/RAG_Icons.dax).
- **Data bars** for magnitude within a table — they let the reader rank
  without reading numbers.
- **Colours** for categories or trends, and nothing else.

Keep the threshold logic in a measure or a field parameter rather than in the
visual's formatting settings, so it stays consistent across pages and is
reviewable in source control. See
[ConditionalFormatting.dax](../Queries/DAX/Measures/ConditionalFormatting.dax).

Do not use red/green alone. Around 8% of men have a red-green colour vision
deficiency, and a report that relies on it excludes them. Add an icon or a
text label alongside the colour.

---

## Tooltips do the explaining

The tooltip is the natural place for detail, which means the visual itself can
stay simple.

- Show the measure name, the value, and the comparison period
- Put variance and the prior-period value in the tooltip, not on the axis
- Use the tooltip for the caveat — "excludes returns" belongs there
- Avoid a tooltip that repeats the value already visible on the visual

---

## Interactions deserve a pass

Default interactions often fight the design.

- Turn off interactions between visuals that do not support each other
- Cross-filter is usually helpful; cross-highlight is usually noise
- Drill-through should be set up deliberately with a clear instruction
- A slicer that affects only one visual needs that restriction set explicitly
- Test with several slicers selected at once — the combination often breaks
  the intended reading

---

## Bookmarks and buttons

Bookmarks capture a view state: filters, page, and selections. They are the
mechanism behind drill-through-style navigation and guided storytelling.

- Give bookmarks meaningful names, or they become unmaintainable
- Duplicate a bookmark before editing it — bookmarks inherit the state they
  were captured from
- A reset button is not optional. Anyone who filters into a corner needs a
  way back.
- Combine bookmark navigation with buttons rather than expecting users to
  guess the bookmark list

See [Buttons](../Design/AtomicElements/Buttons/README.md).

---

## Layout and grid

- Align visuals to a grid. Power BI's *Snap objects to grid* plus the
  *Align* menu does most of the work.
- Use the same visual height within a row, and the same width within a column.
  Inconsistency is what makes a report feel amateur.
- Whitespace is not wasted space. It is what separates one visual from the
  next.
- Consistent margins: pick one value and apply it everywhere.
- A 1080p canvas is the default; a 16:9 report viewed full-screen on a laptop
  should be designed for that.

See [Layouts](../Visuals/Layouts/README.md) and the theme JSON in
[Themes](../Design/Themes/README.md), which sets fonts, colours, and visual
padding consistently.

---

## Accessibility

Accessibility is a correctness requirement, not a nice-to-have.

| Requirement | How |
|-------------|-----|
| Contrast | Text and background at 4.5:1 minimum (WCAG AA) |
| Colour independence | Never encode meaning in colour alone — add an icon or label |
| Alt text | Every visual needs alt text describing what it shows, not "a bar chart" |
| Reading order | Set a logical tab order; screen readers follow it |
| Fonts | Avoid thin weights and all-caps; they fail at projector contrast |
| Hover-only information | Anything on a tooltip must also be reachable another way |

Power BI Desktop has a built-in accessibility checker in the ribbon. Run it
before publishing.

---

## Performance

A report is not finished when it is correct — it is finished when it is fast.

- Check [DAX Query View](../Documentation/UserGuides/DAXQueryView.md) for
  what a visual actually queries. A measure used in twenty visuals runs
  twenty times per page load.
- Remove visuals nobody uses. They cost on every load.
- Avoid high-cardinality fields on axis and legend — they inflate the visual's
  size and the query it sends.
- Limit slicer cardinality; a slicer over millions of distinct values is
  unusable regardless of performance.
- Set sensible page load behaviour for complex pages.

See [Performance Tuning](../Optimization/PerformanceTuning/README.md).

---

## New in recent Power BI releases

The visual layer changes monthly. Verify current behaviour against
[Microsoft Learn](https://learn.microsoft.com/en-us/power-bi/create-reports/)
rather than relying on any static list, including this one. Recurring themes
worth knowing:

- **Modern visual defaults and Fluent 2 base theme** — new reports start from
  an updated base theme with style presets and consistent padding
- **Card with States** — the successor to the older card visuals
- **Custom totals** — overrides how a visual totals without changing the
  measure
- **Table and matrix improvements** — column width defaults and fixed columns
- **Narrative visual** — Copilot-generated summaries, and now embeddable

---

## Pre-publish checklist

- [ ] Every visual answers a specific question
- [ ] Bars sorted by value where no natural order exists
- [ ] Number formats set on every measure, consistently
- [ ] Units in labels, not repeated per value
- [ ] Conditional formatting encodes meaning, not decoration
- [ ] Red/green supplemented with an icon or label
- [ ] Alt text on every visual
- [ ] Contrast passes 4.5:1
- [ ] A reset button exists
- [ ] Interactions checked, including multi-slicer combinations
- [ ] Accessibility checker run
- [ ] DAX Query View checked for expensive visuals
- [ ] Tested on a laptop screen, not just a 4K monitor

---

## Related

- [Design Guidelines](../Design/Guidelines/README.md) — the written rules
- [Atomic Elements](../Design/AtomicElements/README.md) — cards, tables, buttons
- [Themes](../Design/Themes/README.md) — light and dark JSON
- [Field Parameters](../Queries/DAX/FieldParameters/README.md) — let the reader pick the measure
- [Report Author learning path](../Documentation/LearningPaths/README.md#5-report-author)
