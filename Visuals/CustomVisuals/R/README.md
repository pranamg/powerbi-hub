# R Visual Templates

> **Purpose:** R scripts for creating custom visualizations in Power BI

---

## Prerequisites

### Tenant Settings
1. Go to Admin Portal > Tenant Settings
2. Enable "R visuals"

### Local Setup
1. Install R 3.4+ (CRAN or Microsoft R Open)
2. Install required packages:
```r
install.packages(c("ggplot2", "dplyr", "treemap", "igraph", "ggrepel"))
```

### Power BI Desktop
1. File > Options > R scripting
2. Set R home directory
3. Restart Power BI Desktop

---

## Limitations

- Output is a static PNG image
- No interactivity with other visuals
- Cross-filtering not supported
- Max execution time: 5 minutes
- Max output size: 2MB

---

## Templates

| Template | Package | Use Case |
|----------|---------|----------|
| ggplot_Violin.R | ggplot2 | Distribution analysis |
| Treemap.R | treemap | Hierarchical proportions |
| Network.R | igraph | Relationship visualization |

---

## Usage

1. Add R visual to report
2. Add required fields to the visual
3. Copy template code to script editor
4. Modify as needed
5. Run script

---

## Tips

### Field Names
- Power BI converts field names to valid R names
- Spaces become periods
- Special chars are removed
- Example: "Sales Amount" → "Sales.Amount"

### Performance
- Pre-aggregate data when possible
- Limit rows to <100,000 for complex visuals
