# TMDL (Tabular Model Definition Language) Scripts

> **TMDL** is a human-readable, text-based format for defining tabular data models in Power BI and Analysis Services.

## What is TMDL?

TMDL (Tabular Model Definition Language) is Microsoft's text-based format for defining semantic models. It enables:

- **Version Control** - Track model changes in Git
- **Code Reviews** - Review model changes like code
- **Team Collaboration** - Multiple developers can work on different model parts
- **CI/CD Integration** - Automate model deployments
- **Reusable Patterns** - Create template libraries

## TMDL File Structure

A TMDL model consists of multiple files organized by object type:

```
model/
├── definition.tmdl          # Model metadata and properties
├── model.tmdl               # Model-level settings
├── relationships.tmdl       # All relationships
├── roles/                   # Security roles
│   └── Reader.tmdl
├── tables/                  # One file per table
│   ├── Sales.tmdl
│   ├── Products.tmdl
│   └── Date.tmdl
├── perspectives/            # Perspectives (if any)
└── cultures/                # Translations (if any)
```

## TMDL Syntax Reference

### Table Definition
```tmdl
table Sales
    lineageTag: abc123-def456
    
    column 'Sales Amount'
        dataType: decimal
        formatString: $#,##0.00
        summarizeBy: sum
        lineageTag: col123
        
    column 'Order Date'
        dataType: dateTime
        formatString: Short Date
        lineageTag: col456
        
    measure 'Total Sales' = SUM(Sales[Sales Amount])
        formatString: $#,##0.00
        lineageTag: mea123
```

### Measure Definition
```tmdl
measure 'YTD Sales' = 
    CALCULATE(
        [Total Sales],
        DATESYTD('Date'[Date])
    )
    formatString: $#,##0.00
    displayFolder: Time Intelligence
    lineageTag: ytd123
```

### Relationship Definition
```tmdl
relationship rel_Sales_Date
    fromColumn: Sales.'Order Date'
    toColumn: 'Date'.Date
    isActive: true
    crossFilteringBehavior: singleDirection
```

### Calculated Table
```tmdl
table 'Date Table' = 
    CALENDAR(DATE(2020, 1, 1), DATE(2025, 12, 31))
    lineageTag: dt123
    
    column 'Date'
        dataType: dateTime
        isKey: true
        lineageTag: dtcol1
```

### Role-Level Security
```tmdl
role Reader
    modelPermission: read
    
    tablePermission Sales = 
        [Region] = USERPRINCIPALNAME()
```

## Available Templates

| Template | Description |
|----------|-------------|
| `Table_Template.tmdl` | Standard table structure |
| `DateTable_Template.tmdl` | Date dimension table |
| `Measures_Template.tmdl` | Common measure patterns |
| `RLS_Template.tmdl` | Row-level security patterns |
| `Relationship_Template.tmdl` | Relationship patterns |

## Using TMDL in Power BI Desktop

### Enable TMDL View (GA September 2024)

1. Open Power BI Desktop
2. Go to **File > Options and Settings > Options**
3. Navigate to **Preview features**
4. Enable **TMDL View** (now Generally Available)
5. Restart Power BI Desktop

### Access TMDL View

1. Open your .pbix file
2. Go to the **Model view**
3. Click **TMDL View** in the ribbon (or View menu)
4. Edit model objects as text

### Export as TMDL

1. **Right-click** on a model object
2. Select **Script to TMDL**
3. Copy or save the output

## Best Practices

### 1. Consistent Naming
```tmdl
// Use descriptive names
measure 'Sales YTD' = ...
measure 'Sales QTD' = ...
measure 'Sales vs PY' = ...
```

### 2. Use Display Folders
```tmdl
measure 'Growth %' = ...
    displayFolder: KPIs\Growth
```

### 3. Add Descriptions
```tmdl
measure 'Revenue' = SUM(Sales[Amount])
    description: "Total revenue from all sales transactions"
```

### 4. Maintain LineageTags
LineageTags enable Power BI to track object identity across changes:
```tmdl
column 'Product Name'
    lineageTag: 7f8e9d0c-1234-5678-abcd-ef0123456789
```

## Integration with External Tools

### Tabular Editor
```bash
# Open TMDL folder in Tabular Editor
TabularEditor.exe "C:\Models\MyModel\model.tmdl"
```

### Git Workflow
```bash
# Export model as TMDL
pbi-tools extract -pbixPath "Report.pbix" -extractFolder "model/"

# Track changes
git add model/
git commit -m "Updated sales measures"
```

### Azure DevOps / GitHub Actions
```yaml
# Deploy TMDL model
- task: PowerPlatformDeployPackage@2
  inputs:
    authenticationType: 'PowerPlatformSPN'
    PowerPlatformSPN: 'ServiceConnection'
    PackageFile: 'model/'
```

## Resources

- [TMDL Overview (Microsoft Docs)](https://learn.microsoft.com/analysis-services/tmdl/tmdl-overview)
- [TMDL View in Power BI Desktop](https://learn.microsoft.com/power-bi/transform-model/desktop-tmdl-view)
- [Tabular Editor Documentation](https://docs.tabulareditor.com/)
- [pbi-tools](https://pbi.tools/) - Extract/deploy TMDL models
