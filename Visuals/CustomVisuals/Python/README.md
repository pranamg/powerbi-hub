# Python Visual Templates

> **Purpose:** Python scripts for creating custom visualizations in Power BI

---

## Prerequisites

### Tenant Settings
1. Go to Admin Portal > Tenant Settings
2. Enable "Python visuals"
3. Configure allowed packages (optional)

### Local Setup
1. Install Python 3.7+ (Anaconda recommended)
2. Install required packages:
```bash
pip install pandas matplotlib seaborn plotly wordcloud
```

### Power BI Desktop
1. File > Options > Python scripting
2. Set Python home directory
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

| Template | Library | Use Case |
|----------|---------|----------|
| Seaborn_Heatmap.py | seaborn | Correlation matrices |
| Plotly_Scatter.py | plotly | Statistical scatter plots |
| WordCloud.py | wordcloud | Text analysis |

---

## Usage

1. Add Python visual to report
2. Add required fields to the visual
3. Copy template code to script editor
4. Modify as needed
5. Run script
