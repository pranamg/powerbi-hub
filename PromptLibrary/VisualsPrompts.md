# Visualization & Design Prompts

Use these prompts for creating effective Power BI visualizations and designs.

## Chart Selection

```
I need to visualize [describe data]:
- Dimensions: [list]
- Measures: [list]
- Goal: [comparison/trend/distribution/composition/relationship]
- Audience: [executives/analysts/operations]
What chart type(s) would you recommend and why?
```

```
Compare the pros and cons of using [Chart Type A] vs [Chart Type B] 
for showing [data description] to [audience type].
```

## DAX for Visuals

### Conditional Formatting
```
Create DAX measures for conditional formatting:
1. Background color based on [condition]
2. Font color (ensuring readability)
3. Icon indicators (up/down arrows, traffic lights)
4. Data bars scaling
Return hex color codes.
```

### Dynamic Titles & Labels
```
Write a DAX measure for a dynamic chart title that shows:
"[Metric Name] by [Selected Dimension] - [Selected Date Range]"
Handle cases when no selection is made.
```

```
Create a measure that formats numbers dynamically:
- Under 1000: show as-is
- 1000-999999: show as X.XK
- 1000000+: show as X.XM
Include proper decimal handling.
```

## Theme & Design

```
Create a Power BI theme JSON with:
- Primary color: [hex code]
- Secondary colors: [describe palette]
- Font: [font name]
- Style: [modern/corporate/minimal]
Include settings for all visual types.
```

```
Design a consistent color palette for [industry/brand]:
- 10 data colors (distinct but harmonious)
- Good/Neutral/Bad sentiment colors
- Background colors (light and dark versions)
Explain the color theory behind choices.
```

## Layout & Composition

```
I'm designing a dashboard with:
- KPI cards: [list metrics]
- Charts: [list visualizations]
- Filters: [list slicers]
Suggest an optimal layout for [screen size/device].
Include spacing, alignment, and visual hierarchy recommendations.
```

```
Review this dashboard layout for UX issues:
[describe current layout]
Suggest improvements for:
- Visual flow (F-pattern, Z-pattern)
- Grouping related information
- Reducing cognitive load
- Mobile responsiveness
```

## Accessibility

```
Review my Power BI report for accessibility:
- Color palette: [list colors]
- Font sizes: [list sizes]
- Chart types used: [list]
Suggest improvements for:
- Color blindness compatibility
- Screen reader support
- Keyboard navigation
```

```
Create an accessible color palette that:
- Has sufficient contrast ratios (WCAG AA)
- Works for common color blindness types
- Maintains brand alignment with [brand colors]
```

## Custom Visuals

```
I need a visualization that [describe requirement].
Standard Power BI visuals don't meet this need because [reason].
Suggest:
1. AppSource custom visuals that could work
2. Alternative approaches with standard visuals
3. Whether custom development is needed
```

```
Write Deneb/Vega-Lite specification for:
[describe desired visualization]
Data structure: [describe columns]
Include interactivity and tooltips.
```

## Storytelling & Narrative

```
I have these key findings from my data:
[list insights]
Help me structure a Power BI report that:
- Tells a compelling story
- Guides the viewer through insights
- Uses progressive disclosure
- Ends with actionable recommendations
```

```
Write tooltip text for [chart type] showing [metric]:
- Keep under 100 characters
- Include context (vs target, vs prior period)
- Use plain language, not jargon
```

## Performance

```
My report with [X] visuals on a page loads slowly.
Visuals include: [list types and measures]
How can I optimize without losing functionality?
Consider:
- Visual reduction strategies
- Measure optimization
- Aggregation levels
```

## Mobile Optimization

```
Adapt this desktop dashboard layout for mobile:
[describe current layout]
Prioritize: [list most important elements]
Suggest which elements to:
- Keep as-is
- Resize
- Move to separate pages
- Hide on mobile
```

## Tips for Visual Design Prompts

Always include:
1. Target audience and their technical level
2. Key message or decision the visual should support
3. Data structure (measures, dimensions)
4. Constraints (branding, accessibility requirements)
5. Device/screen considerations
