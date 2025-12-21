# Deneb Vega-Lite Templates

> **Purpose:** Vega-Lite specifications for Deneb custom visual in Power BI

---

## Overview

Deneb is a certified custom visual that lets you create visualizations using Vega or Vega-Lite grammar. These templates provide starting points for common advanced visualizations.

## Installation

1. Go to AppSource in Power BI Desktop
2. Search for "Deneb"
3. Click "Add" to install

## Usage

1. Add Deneb visual to canvas
2. Add required data fields
3. Click "Edit" to open specification editor
4. Paste the JSON template
5. Modify as needed

---

## Templates Included

| Template | Description | Data Requirements |
|----------|-------------|-------------------|
| BulletChart.json | Bullet chart with target | Actual, Target, Category |
| WaterfallVariance.json | Variance waterfall | Category, Value, Type |
| SlopeChart.json | Period comparison | Category, Value1, Value2 |
| Sparklines.json | Inline sparklines | Category, Date, Value |
| LollipopChart.json | Lollipop/dot chart | Category, Value |

---

## Tips

### Performance
- Limit data to <10,000 rows for complex specs
- Use aggregations before Deneb when possible

### Debugging
- Use browser dev tools (F12) to see errors
- Test specs in Vega Editor first

### Cross-Filtering
- Add selection parameters for interactivity
- Use signals for dynamic behavior
