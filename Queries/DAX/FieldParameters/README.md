# Field Parameters

> Dynamic dimension and measure selection in Power BI visuals

## Overview

Field parameters allow users to dynamically change which fields (columns or measures) are displayed in visuals without creating multiple versions of the same visualization.

## Creating Field Parameters

### In Power BI Desktop

1. **Modeling** → **New parameter** → **Fields**
2. Select columns or measures to include
3. Name the parameter
4. Click **Create**

### Generated DAX

When you create a field parameter, Power BI generates:

```dax
// Dimension Parameter
Product Dimension = {
    ("Product Name", NAMEOF('Product'[ProductName]), 0),
    ("Category", NAMEOF('Product'[Category]), 1),
    ("Subcategory", NAMEOF('Product'[Subcategory]), 2),
    ("Brand", NAMEOF('Product'[Brand]), 3)
}
```

```dax
// Measure Parameter
Sales Metrics = {
    ("Total Sales", NAMEOF([Total Sales]), 0),
    ("Profit", NAMEOF([Profit]), 1),
    ("Profit Margin %", NAMEOF([Profit Margin %]), 2),
    ("Order Count", NAMEOF([Order Count]), 3)
}
```

## Common Patterns

### 1. Dynamic Dimension Selection

Allow users to change the grouping axis:

```dax
Analysis Dimension = {
    ("By Product", NAMEOF('Product'[ProductName]), 0),
    ("By Category", NAMEOF('Product'[Category]), 1),
    ("By Region", NAMEOF('Geography'[Region]), 2),
    ("By Customer", NAMEOF('Customer'[CustomerName]), 3)
}
```

**Usage:**
- Add "Analysis Dimension" to X-axis
- Add a slicer for "Analysis Dimension"
- Users can switch between groupings

### 2. Dynamic Measure Selection

Allow users to choose which metric to display:

```dax
Performance Metric = {
    ("Revenue", NAMEOF([Total Revenue]), 0),
    ("Units Sold", NAMEOF([Total Units]), 1),
    ("Average Price", NAMEOF([Avg Unit Price]), 2),
    ("Growth %", NAMEOF([YoY Growth %]), 3)
}
```

### 3. Combined Dimension/Measure

Mixed field parameter:

```dax
KPI Selector = {
    ("Sales by Product", NAMEOF([Total Sales]), 0, "Product"),
    ("Sales by Region", NAMEOF([Total Sales]), 1, "Region"),
    ("Profit by Category", NAMEOF([Profit]), 2, "Category")
}
```

**Note:** Custom combinations require manual DAX editing.

### 4. Time Granularity

Switch between time aggregations:

```dax
Time Granularity = {
    ("Year", NAMEOF('Date'[Year]), 0),
    ("Quarter", NAMEOF('Date'[Quarter]), 1),
    ("Month", NAMEOF('Date'[Month Name]), 2),
    ("Week", NAMEOF('Date'[Week Number]), 3),
    ("Day", NAMEOF('Date'[Date]), 4)
}
```

## Advanced Techniques

### Custom Sort Order

Add sort index as third value:

```dax
Month Selector = {
    ("January", NAMEOF('Date'[January Sales]), 1),
    ("February", NAMEOF('Date'[February Sales]), 2),
    ("March", NAMEOF('Date'[March Sales]), 3)
}
```

### Conditional Formatting Based on Selection

```dax
Dynamic Color = 
VAR SelectedMetric = SELECTEDVALUE('Performance Metric'[Performance Metric])
RETURN
SWITCH(
    SelectedMetric,
    "Revenue", "#2E86AB",
    "Profit", "#28A745",
    "Growth %", "#FFC107",
    "#6C757D"
)
```

### Dynamic Title

```dax
Chart Title = 
"Sales Analysis by " & SELECTEDVALUE('Analysis Dimension'[Analysis Dimension], "All Dimensions")
```

## Use Cases

### Executive Dashboard
- Single visual with measure selector
- Switch between Revenue, Profit, Units, Growth
- Reduces dashboard clutter

### Regional Analysis
- Same visual structure
- Switch between regions dynamically
- Compare without multiple charts

### Time Series Analysis
- Dynamic time granularity
- Year → Quarter → Month → Day
- Single visual serves all needs

## Best Practices

### Do's
- Include clear, business-friendly names
- Set appropriate sort order
- Use with slicers for user selection
- Document what each option shows

### Don'ts
- Don't include too many options (< 10)
- Don't mix incompatible data types
- Don't forget default selection
- Don't use for critical static reports

## Visual Integration

### Adding to Visuals

1. Drag field parameter to axis/value field
2. The visual will respond to slicer selection
3. Or use as slicer directly

### Slicer Configuration

- **Single select**: One option at a time
- **Dropdown**: Save space
- **Buttons**: Quick toggle

## Limitations

- Cannot combine with calculation groups dynamically
- Limited formatting per selection
- Requires Power BI Desktop (March 2022+)
- Not all visuals support field parameters fully

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Options not showing | Check field parameter is in visual |
| Wrong sort order | Edit DAX to adjust ordinal values |
| Can't multi-select | Field parameters are single-select by design |
| Visual doesn't update | Refresh visual or check slicer sync |

## Related Resources

- [Calculation Groups](../CalculationGroups/)
- [Microsoft Documentation](https://learn.microsoft.com/power-bi/create-reports/power-bi-field-parameters)
