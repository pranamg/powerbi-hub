# Custom Visuals Templates

> **Purpose:** Templates and examples for creating custom visuals in Power BI

---

## Overview

Power BI supports multiple ways to create custom visualizations beyond standard visuals:

| Method | Use Case | Skill Required |
|--------|----------|----------------|
| **Deneb** | Complex data viz with Vega/Vega-Lite | JSON/Vega |
| **Python** | Statistical/ML visualizations | Python |
| **R** | Statistical visualizations | R |
| **SVG** | Simple custom shapes/icons | DAX + SVG |

---

## Directory Structure

```
CustomVisuals/
├── README.md
├── Deneb/
│   ├── README.md
│   ├── BarChart_Animated.json
│   ├── BulletChart.json
│   ├── WaterfallVariance.json
│   ├── SlopeChart.json
│   └── Sparklines.json
├── Python/
│   ├── README.md
│   ├── Seaborn_Heatmap.py
│   ├── Plotly_Scatter.py
│   └── WordCloud.py
├── R/
│   ├── README.md
│   ├── ggplot_Violin.R
│   ├── Treemap.R
│   └── Network.R
└── SVG/
    ├── README.md
    ├── RAG_Icons.dax
    ├── Progress_Ring.dax
    └── Sparkline_DAX.dax
```

---

## Quick Comparison

### Deneb (Vega-Lite)
**Pros:**
- Powerful declarative grammar
- No external dependencies
- Works in Power BI Service
- Great community examples

**Cons:**
- Learning curve for Vega syntax
- Limited interactivity with other visuals

### Python Visuals
**Pros:**
- Full Python ecosystem (matplotlib, seaborn, plotly)
- Great for statistical analysis
- Machine learning visualizations

**Cons:**
- Requires Python runtime
- Static images only
- Security settings needed in tenant

### R Visuals
**Pros:**
- Extensive statistical packages (ggplot2)
- Publication-quality charts
- Great for statistical analysis

**Cons:**
- Requires R runtime
- Static images only
- Security settings needed in tenant

### SVG with DAX
**Pros:**
- No additional dependencies
- Works everywhere
- Dynamic with measure values
- Very lightweight

**Cons:**
- Limited to simple graphics
- SVG knowledge required
- Complex for detailed visuals

---

## Getting Started

### Deneb Setup
1. Install Deneb from AppSource
2. Add to report canvas
3. Map data fields
4. Write Vega/Vega-Lite spec

### Python/R Setup
1. Enable in Admin Portal (Tenant Settings)
2. Install Python/R locally
3. Add Python/R visual to report
4. Write script

### SVG Setup
1. Create DAX measure returning SVG string
2. Add measure to table visual or card
3. Set data category to "Image URL" (for data URI)

---

## Related Resources

- [Deneb Documentation](https://deneb-viz.github.io/)
- [Vega-Lite Examples](https://vega.github.io/vega-lite/examples/)
- [matplotlib Gallery](https://matplotlib.org/stable/gallery/)
- [ggplot2 Gallery](https://r-graph-gallery.com/ggplot2-package.html)
- [SVG Tutorial](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial)
