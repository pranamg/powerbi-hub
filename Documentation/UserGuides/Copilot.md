# Microsoft Copilot in Power BI

> Complete guide to using AI-powered assistance in Power BI

## Overview

Microsoft Copilot integrates generative AI directly into Power BI, enabling natural language interactions for report creation, data analysis, DAX assistance, and narrative generation.

## Copilot Capabilities

| Feature | Availability | Description |
|---------|-------------|-------------|
| Report Generation | GA | Create reports from natural language |
| Narrative Visual | GA | Auto-generate text summaries |
| DAX Query Assist | GA | Help writing DAX formulas |
| Smart Narratives | GA | Dynamic text insights |
| Q&A Enhanced | GA | Improved natural language queries |
| Data Summarization | Preview | Summarize datasets |

## Prerequisites

### Licensing Requirements
- Power BI Premium capacity (P1+) or Fabric capacity (F64+)
- OR Power BI Pro with Copilot add-on
- Microsoft 365 Copilot license (for some features)

### Admin Settings
Copilot must be enabled by your Power BI admin:

1. **Admin Portal** → Settings → Copilot
2. Enable for specific security groups or entire organization
3. Configure data residency settings
4. Set up audit logging (recommended)

### Data Requirements
- Data must be in a supported region
- Semantic model must be in a workspace on Premium/Fabric capacity
- Direct Lake and Import modes supported
- DirectQuery has limited support

## Report Generation

### Creating a Report with Copilot

1. Open Power BI Desktop or Service
2. Connect to your semantic model
3. Click **Copilot** button in ribbon
4. Describe what you want:

```
"Create a sales dashboard showing:
- Monthly revenue trend for 2024
- Top 10 products by profit
- Regional comparison with last year
- Customer segment breakdown"
```

### Effective Prompts for Report Creation

**Basic Structure:**
```
"Create a [report type] showing [metrics] by [dimensions] for [time period]"
```

**Examples:**

```
✓ Good: "Create an executive summary with KPIs for revenue, 
         profit margin, and customer count, with YoY comparisons"

✗ Bad: "Make me a report"
```

```
✓ Good: "Build a regional performance report comparing 
         North, South, East, West regions with bar charts 
         and a map visualization"

✗ Bad: "Show regional data"
```

### Report Customization Prompts

After initial generation:
```
"Add a slicer for product category"
"Change the bar chart to show top 5 instead of top 10"
"Add conditional formatting - red for negative growth"
"Include a trend line on the monthly chart"
"Make the color scheme blue and gray"
```

## DAX Query Assistance

### Getting DAX Help

Click in DAX formula bar, then use Copilot:

**Prompt:**
```
"Create a measure that calculates year-over-year sales growth percentage"
```

**Copilot Response:**
```dax
Sales YoY Growth % = 
VAR CurrentSales = [Total Sales]
VAR PriorYearSales = 
    CALCULATE(
        [Total Sales],
        SAMEPERIODLASTYEAR('Date'[Date])
    )
RETURN
DIVIDE(
    CurrentSales - PriorYearSales,
    PriorYearSales
)
```

### DAX Prompt Patterns

**Time Intelligence:**
```
"Calculate [metric] for year-to-date/quarter-to-date/month-to-date"
"Show [metric] compared to same period last year"
"Create a rolling [N]-month average of [metric]"
```

**Rankings:**
```
"Rank products by [metric] within each category"
"Show top N items by [metric]"
"Calculate percentile rank for [metric]"
```

**Conditional Logic:**
```
"Create a measure that returns [A] if [condition], otherwise [B]"
"Classify customers as High/Medium/Low based on [metric] thresholds"
```

**Complex Calculations:**
```
"Calculate weighted average of [metric] by [weight column]"
"Show running total of [metric] by [date column]"
"Calculate [metric] excluding [specific filter]"
```

### Explaining Existing DAX

Select a measure and ask:
```
"Explain what this measure does"
"Why might this measure be slow?"
"How can I simplify this calculation?"
```

## Narrative Generation

### Smart Narrative Visual

1. Add **Smart Narrative** visual to canvas
2. Copilot analyzes visible data
3. Generates dynamic text summary

### Customizing Narratives

**Default Generation:**
Copilot automatically identifies:
- Key metrics and trends
- Significant changes
- Outliers and anomalies
- Comparisons

**Custom Prompts:**
```
"Summarize the key insights focusing on profit margin"
"Write an executive summary for stakeholders"
"Highlight any concerning trends in the data"
"Compare this month's performance to target"
```

### Narrative Templates

**Executive Summary:**
```
"Generate a 3-paragraph executive summary covering:
1. Overall performance against targets
2. Top and bottom performers
3. Key recommendations"
```

**Trend Analysis:**
```
"Describe the sales trend over the past 12 months,
noting any seasonal patterns or anomalies"
```

**Comparative Analysis:**
```
"Compare performance across regions, highlighting 
the best and worst performers with specific numbers"
```

## Q&A Enhanced with Copilot

### Natural Language Queries

In Q&A visual or search box:

**Basic Questions:**
```
"What were total sales last month?"
"Which product category is most profitable?"
"Show me the trend of orders this year"
```

**Complex Questions:**
```
"Why did sales drop in March?"
"What factors correlate with high customer retention?"
"Compare Q3 to Q2 performance by region"
```

### Q&A Best Practices

1. **Use Synonyms Setup** - Define business terms
2. **Add Linguistic Schema** - Train model on your vocabulary  
3. **Be Specific** - Include time periods, dimensions
4. **Iterate** - Refine based on initial results

## Data Summarization (Preview)

### Quick Insights

Right-click on visual → **Summarize with Copilot**

**Outputs:**
- Key statistics
- Trend description
- Notable patterns
- Comparison highlights

### Dataset Overview

In Model view:
```
"Describe this dataset"
"What are the main entities and relationships?"
"Identify potential data quality issues"
```

## Best Practices

### Prompt Engineering

1. **Be Specific**
   ```
   ✓ "Show monthly revenue for 2024 by product category as a stacked bar chart"
   ✗ "Show me data"
   ```

2. **Provide Context**
   ```
   ✓ "Our fiscal year starts in April. Show FY24 sales by quarter."
   ✗ "Show yearly sales"
   ```

3. **Iterate Incrementally**
   ```
   Step 1: "Create a basic sales report"
   Step 2: "Add a filter for region"
   Step 3: "Change colors to match brand guidelines"
   ```

4. **Ask for Alternatives**
   ```
   "Show me 3 different ways to visualize this data"
   "What other measures would be useful here?"
   ```

### Security Considerations

- Copilot respects row-level security (RLS)
- Data sent to Azure OpenAI (check compliance)
- Prompts may be logged for improvement
- Don't include sensitive data in prompts

### Limitations

| Limitation | Workaround |
|------------|------------|
| Complex multi-model queries | Use single semantic model |
| Real-time data | Refresh before querying |
| Custom visuals | Use standard visuals, customize after |
| Very large datasets | Apply filters before Copilot |
| Specific formatting | Adjust manually after generation |

## Troubleshooting

### Common Issues

**"Copilot is not available"**
- Check licensing and admin settings
- Verify capacity assignment
- Ensure data is in supported region

**"I don't understand that request"**
- Simplify prompt
- Use column/measure names from model
- Check synonyms setup in Q&A

**Incorrect Results**
- Verify measure definitions
- Check filter context
- Use more specific terminology

**Slow Responses**
- Reduce data volume with filters
- Optimize underlying model
- Check capacity utilization

### Feedback Loop

When results aren't right:
1. Click thumbs down
2. Provide correction: "Actually, [correct interpretation]"
3. Copilot learns from feedback

## Integration with MCP

Copilot in Power BI Service complements MCP:

| Copilot | MCP |
|---------|-----|
| In-product experience | External AI tools |
| Report creation focus | Query/development focus |
| No code export | Full DAX access |
| Consumer-friendly | Developer-oriented |

**Workflow Combination:**
1. Use Copilot for quick report mockups
2. Use MCP + VS Code for complex DAX development
3. Use Copilot narratives for business summaries
4. Use MCP for documentation generation

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl + Enter | Submit prompt |
| Esc | Cancel generation |
| Ctrl + Space | Open Copilot panel |
| Tab | Accept suggestion |

## Resources

- [Microsoft Copilot Documentation](https://learn.microsoft.com/power-bi/create-reports/copilot-introduction)
- [DAX Copilot Tips](https://learn.microsoft.com/power-bi/transform-model/copilot-dax)
- [Q&A Best Practices](https://learn.microsoft.com/power-bi/natural-language/q-and-a-best-practices)

## Related Resources

- [MCP Integration](../../Integrations/MCP/)
- [DAX Prompts](../../PromptLibrary/DAXPrompts.md)
- [DAX Query View](./DAXQueryView.md)
