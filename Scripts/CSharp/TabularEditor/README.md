# Tabular Editor Resources

> Best Practice Analyzer rules and C# scripts for Power BI model development

## Contents

| File | Description |
|------|-------------|
| [BestPracticeRules.json](./BestPracticeRules.json) | Custom BPA rules for model validation |
| [GenerateDocumentation.cs](./GenerateDocumentation.cs) | Auto-generate model documentation |
| [CreateTimeIntelligence.cs](./CreateTimeIntelligence.cs) | Generate time intelligence measures |

## Best Practice Analyzer (BPA)

### Loading Custom Rules

**Tabular Editor 2:**
```
Tools → Manage BPA Rules → Import
Select BestPracticeRules.json
```

**Tabular Editor 3:**
```
Preferences → Best Practice Analyzer → Add Custom Rules
Point to BestPracticeRules.json
```

### Running BPA
```
View → Best Practice Analyzer (Ctrl+B)
Click "Run Analysis"
```

### Rule Categories

| Category | Description |
|----------|-------------|
| DAX Expressions | Code quality and patterns |
| Performance | Performance-impacting patterns |
| Documentation | Missing descriptions |
| Organization | Display folders, naming |
| User Experience | Formatting, sorting |
| Data Model | Relationships, tables |
| Naming Conventions | Consistent naming |

### Severity Levels

- **1 (Info):** Suggestion for improvement
- **2 (Warning):** Should be addressed
- **3 (Error):** Must be fixed before deployment

## C# Scripts

### Using Scripts

**Tabular Editor 2/3:**
1. Open Advanced Scripting pane
2. Paste script content
3. Run (F5)

**Command Line:**
```powershell
tabular-editor Model.bim -S "ScriptFile.cs"
```

### Script: Generate Time Intelligence

Creates standard time intelligence measures for a base measure:

```csharp
// Select a measure, then run this script
// Creates: YTD, PY, YoY, QTD, MTD variants

var baseMeasure = Selected.Measure;
var dateTable = "Date";  // Adjust to your date table name
var dateColumn = "Date"; // Adjust to your date column

// YTD
var ytd = baseMeasure.Table.AddMeasure(
    baseMeasure.Name + " YTD",
    $"TOTALYTD([{baseMeasure.Name}], '{dateTable}'[{dateColumn}])"
);
ytd.DisplayFolder = "Time Intelligence";

// Previous Year
var py = baseMeasure.Table.AddMeasure(
    baseMeasure.Name + " PY",
    $"CALCULATE([{baseMeasure.Name}], SAMEPERIODLASTYEAR('{dateTable}'[{dateColumn}]))"
);
py.DisplayFolder = "Time Intelligence";

// YoY Change
var yoy = baseMeasure.Table.AddMeasure(
    baseMeasure.Name + " YoY",
    $"[{baseMeasure.Name}] - [{baseMeasure.Name} PY]"
);
yoy.DisplayFolder = "Time Intelligence";

// YoY %
var yoyPct = baseMeasure.Table.AddMeasure(
    baseMeasure.Name + " YoY %",
    $"DIVIDE([{baseMeasure.Name} YoY], [{baseMeasure.Name} PY])"
);
yoyPct.FormatString = "0.00%";
yoyPct.DisplayFolder = "Time Intelligence";
```

### Script: Generate Documentation

Exports model documentation to markdown:

```csharp
// Run this script to generate documentation
using System.IO;

var sb = new System.Text.StringBuilder();

sb.AppendLine("# Model Documentation");
sb.AppendLine($"\nGenerated: {DateTime.Now:yyyy-MM-dd HH:mm}");
sb.AppendLine($"\nTables: {Model.Tables.Count}");
sb.AppendLine($"Measures: {Model.AllMeasures.Count()}");

sb.AppendLine("\n## Tables\n");
foreach (var table in Model.Tables.OrderBy(t => t.Name))
{
    sb.AppendLine($"### {table.Name}");
    if (!string.IsNullOrEmpty(table.Description))
        sb.AppendLine($"\n{table.Description}");
    
    sb.AppendLine($"\n- Columns: {table.Columns.Count}");
    sb.AppendLine($"- Measures: {table.Measures.Count}");
}

sb.AppendLine("\n## Measures\n");
foreach (var measure in Model.AllMeasures.OrderBy(m => m.Table.Name).ThenBy(m => m.Name))
{
    sb.AppendLine($"### [{measure.Table.Name}].[{measure.Name}]");
    if (!string.IsNullOrEmpty(measure.Description))
        sb.AppendLine($"\n{measure.Description}");
    sb.AppendLine($"\n```dax\n{measure.Expression}\n```");
}

// Output to file
File.WriteAllText(@"C:\Temp\ModelDocumentation.md", sb.ToString());
Info("Documentation generated to C:\\Temp\\ModelDocumentation.md");
```

### Script: Hide Key Columns

Automatically hides columns ending with ID, Key, or SK:

```csharp
foreach (var column in Model.AllColumns)
{
    if (column.Name.EndsWith("ID") || 
        column.Name.EndsWith("Key") || 
        column.Name.EndsWith("SK"))
    {
        column.IsHidden = true;
    }
}
Info("Key columns hidden");
```

### Script: Create Display Folders

Organizes measures into display folders based on naming patterns:

```csharp
foreach (var m in Model.AllMeasures)
{
    if (m.Name.Contains("YTD") || m.Name.Contains("QTD") || 
        m.Name.Contains("MTD") || m.Name.Contains("YoY"))
    {
        m.DisplayFolder = "Time Intelligence";
    }
    else if (m.Name.Contains("Rank") || m.Name.Contains("Top"))
    {
        m.DisplayFolder = "Rankings";
    }
    else if (m.Name.Contains("%") || m.Name.Contains("Pct") || 
             m.Name.Contains("Ratio"))
    {
        m.DisplayFolder = "Ratios & Percentages";
    }
}
Info("Display folders assigned");
```

## CI/CD Integration

### Running BPA in Pipeline

```yaml
- task: PowerShell@2
  displayName: 'Run Best Practice Analyzer'
  inputs:
    targetType: 'inline'
    script: |
      # Install Tabular Editor CLI
      dotnet tool install -g TabularEditor.TOMWrapper.NetCore
      
      # Run BPA and fail on errors
      $result = tabular-editor Model.bim -A BestPracticeRules.json -W
      
      if ($LASTEXITCODE -ne 0) {
        Write-Error "BPA found issues"
        exit 1
      }
```

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:
```bash
#!/bin/sh
tabular-editor Model.bim -A BestPracticeRules.json
if [ $? -ne 0 ]; then
    echo "BPA validation failed. Fix issues before committing."
    exit 1
fi
```

## Related Resources

- [Tabular Editor Documentation](https://docs.tabulareditor.com/)
- [BPA Rule Reference](https://docs.tabulareditor.com/Best-Practice-Analyzer.html)
- [C# Scripting Guide](https://docs.tabulareditor.com/Advanced-Scripting.html)
- [TMDL Templates](../../TMDL/)
