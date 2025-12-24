# C# Script Examples for Tabular Editor

> Ready-to-use scripts for agentic development workflows

## Overview

These scripts can be executed via the Tabular Editor CLI to automate common semantic model operations. Agents can use these directly or generate similar scripts based on these patterns.

## Usage

```bash
# Run a script
TabularEditor.exe "Model.bim" -S "ScriptName.cs" -B "Model.bim"

# Run multiple scripts
TabularEditor.exe "Model.bim" -S "Script1.cs" -S "Script2.cs" -TMDL "output/"
```

## Script Library

### Documentation Scripts

#### AddDescriptions.cs

Generate descriptions for measures without them.

```csharp
// AddDescriptions.cs
// Generates descriptions for measures based on their DAX patterns

foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrWhiteSpace(m.Description)))
{
    var dax = m.Expression.ToUpper();
    string desc = "";
    
    if(dax.Contains("SUM("))
        desc = $"Sum of values for {m.Name.Replace("Total ", "")}";
    else if(dax.Contains("AVERAGE(") || dax.Contains("AVERAGEX("))
        desc = $"Average value of {m.Name}";
    else if(dax.Contains("COUNT(") || dax.Contains("COUNTROWS("))
        desc = $"Count of {m.Name.Replace("# ", "").Replace("Count ", "")}";
    else if(dax.Contains("DISTINCTCOUNT("))
        desc = $"Distinct count of {m.Name}";
    else if(dax.Contains("DIVIDE("))
        desc = $"Ratio calculation for {m.Name}";
    else if(dax.Contains("CALCULATE("))
        desc = $"Filtered calculation of {m.Name}";
    else if(dax.Contains("TOTALYTD(") || dax.Contains("DATESYTD("))
        desc = $"Year-to-date value of {m.Name.Replace(" YTD", "")}";
    else if(dax.Contains("SAMEPERIODLASTYEAR("))
        desc = $"Prior year value of {m.Name.Replace(" PY", "")}";
    else
        desc = $"Measure: {m.Name}";
    
    m.Description = desc;
    Info($"Added description to [{m.Name}]");
}
```

### Formatting Scripts

#### SetFormatStrings.cs

Apply standard format strings based on measure names.

```csharp
// SetFormatStrings.cs
// Sets format strings based on measure naming patterns

var formatRules = new (string pattern, string format)[]
{
    ("revenue", "$#,##0.00"),
    ("sales", "$#,##0.00"),
    ("cost", "$#,##0.00"),
    ("price", "$#,##0.00"),
    ("amount", "$#,##0.00"),
    ("profit", "$#,##0.00"),
    ("margin", "$#,##0.00"),
    ("quantity", "#,##0"),
    ("qty", "#,##0"),
    ("count", "#,##0"),
    ("#", "#,##0"),
    ("%", "0.00%"),
    ("percent", "0.00%"),
    ("ratio", "0.00%"),
    ("rate", "0.00%")
};

foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrEmpty(m.FormatString)))
{
    var nameLower = m.Name.ToLower();
    
    foreach(var rule in formatRules)
    {
        if(nameLower.Contains(rule.pattern))
        {
            m.FormatString = rule.format;
            Info($"Set [{m.Name}] format to {rule.format}");
            break;
        }
    }
}
```

### DAX Refactoring Scripts

#### RefactorToDivide.cs

Replace division operators with DIVIDE function.

```csharp
// RefactorToDivide.cs
// Replaces / with DIVIDE() for safer calculations

var divisionPattern = new System.Text.RegularExpressions.Regex(
    @"(\[[^\]]+\]|\([^)]+\))\s*/\s*(\[[^\]]+\]|\([^)]+\))",
    System.Text.RegularExpressions.RegexOptions.IgnoreCase
);

int refactored = 0;

foreach(var m in Model.AllMeasures)
{
    if(divisionPattern.IsMatch(m.Expression))
    {
        var originalExpr = m.Expression;
        var newExpr = divisionPattern.Replace(originalExpr, "DIVIDE($1, $2, 0)");
        
        if(originalExpr != newExpr)
        {
            m.Expression = newExpr;
            refactored++;
            Info($"Refactored [{m.Name}]");
        }
    }
}

Info($"Total measures refactored: {refactored}");
```

### Time Intelligence Scripts

#### CreateTimeIntelligence.cs

Create standard time intelligence measures.

```csharp
// CreateTimeIntelligence.cs
// Creates YTD, PY, YoY measures for base measures

// Configuration
var dateTableName = "Date";
var dateColumnName = "Date";
var tiFolder = "Time Intelligence";

// Get base measures (exclude existing TI measures)
var baseMeasures = Model.AllMeasures
    .Where(m => !m.Name.Contains("YTD") 
             && !m.Name.Contains("MTD")
             && !m.Name.Contains("QTD")
             && !m.Name.Contains(" PY")
             && !m.Name.Contains("YoY")
             && !m.Name.Contains("Prior Year"))
    .ToList();

foreach(var m in baseMeasures)
{
    var table = m.Table;
    var baseName = m.Name;
    var baseFolder = string.IsNullOrEmpty(m.DisplayFolder) ? "" : m.DisplayFolder + "\\";
    var dateRef = $"'{dateTableName}'[{dateColumnName}]";
    
    // YTD
    var ytdName = $"{baseName} YTD";
    if(!table.Measures.Any(x => x.Name == ytdName))
    {
        var ytd = table.AddMeasure(ytdName, $"TOTALYTD([{baseName}], {dateRef})");
        ytd.DisplayFolder = baseFolder + tiFolder;
        ytd.FormatString = m.FormatString;
        ytd.Description = $"Year-to-date {baseName}";
        Info($"Created [{ytdName}]");
    }
    
    // PY (Prior Year)
    var pyName = $"{baseName} PY";
    if(!table.Measures.Any(x => x.Name == pyName))
    {
        var py = table.AddMeasure(pyName, 
            $"CALCULATE([{baseName}], SAMEPERIODLASTYEAR({dateRef}))");
        py.DisplayFolder = baseFolder + tiFolder;
        py.FormatString = m.FormatString;
        py.Description = $"Prior year {baseName}";
        Info($"Created [{pyName}]");
    }
    
    // YoY % Change
    var yoyName = $"{baseName} YoY %";
    if(!table.Measures.Any(x => x.Name == yoyName))
    {
        var yoy = table.AddMeasure(yoyName, 
            $"DIVIDE([{baseName}] - [{pyName}], [{pyName}], 0)");
        yoy.DisplayFolder = baseFolder + tiFolder;
        yoy.FormatString = "0.00%";
        yoy.Description = $"Year-over-year change in {baseName}";
        Info($"Created [{yoyName}]");
    }
}
```

### Organization Scripts

#### SetDisplayFolders.cs

Organize measures into display folders by pattern.

```csharp
// SetDisplayFolders.cs
// Organizes measures into display folders based on naming patterns

var folderRules = new (string pattern, string folder)[]
{
    ("ytd", "Time Intelligence"),
    ("mtd", "Time Intelligence"),
    ("qtd", "Time Intelligence"),
    (" py", "Time Intelligence"),
    ("yoy", "Time Intelligence"),
    ("prior year", "Time Intelligence"),
    ("%", "Ratios"),
    ("ratio", "Ratios"),
    ("margin", "Profitability"),
    ("profit", "Profitability"),
    ("revenue", "Revenue"),
    ("sales", "Revenue"),
    ("cost", "Costs"),
    ("expense", "Costs"),
    ("count", "Counts"),
    ("#", "Counts"),
    ("avg", "Averages"),
    ("average", "Averages")
};

foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrEmpty(m.DisplayFolder)))
{
    var nameLower = m.Name.ToLower();
    
    foreach(var rule in folderRules)
    {
        if(nameLower.Contains(rule.pattern))
        {
            m.DisplayFolder = rule.folder;
            Info($"Set [{m.Name}] folder to '{rule.folder}'");
            break;
        }
    }
}
```

### Validation Scripts

#### ValidateModel.cs

Check model for common issues.

```csharp
// ValidateModel.cs
// Validates model and reports issues

int warnings = 0;
int errors = 0;

// Check for measures without descriptions
foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrWhiteSpace(m.Description)))
{
    Warning($"[{m.Name}] has no description");
    warnings++;
}

// Check for measures without format strings
foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrWhiteSpace(m.FormatString)))
{
    Warning($"[{m.Name}] has no format string");
    warnings++;
}

// Check for DAX errors
foreach(var m in Model.AllMeasures.Where(m => !string.IsNullOrWhiteSpace(m.ErrorMessage)))
{
    Error($"[{m.Name}] has DAX error: {m.ErrorMessage}");
    errors++;
}

// Check for orphaned columns
foreach(var c in Model.AllColumns.Where(c => !c.IsKey && c.ReferencedBy.Count == 0))
{
    Info($"Column [{c.DaxObjectFullName}] is not referenced by any object");
}

// Check for hidden measures that are referenced
foreach(var m in Model.AllMeasures.Where(m => m.IsHidden && m.ReferencedBy.Count > 0))
{
    Warning($"[{m.Name}] is hidden but referenced by other objects");
    warnings++;
}

Info($"Validation complete: {warnings} warnings, {errors} errors");

if(errors > 0)
    Error("Model has validation errors");
```

### Cleanup Scripts

#### RemoveUnusedMeasures.cs

Identify (and optionally remove) unused measures.

```csharp
// RemoveUnusedMeasures.cs
// Lists or removes measures that are not referenced

// Set to true to actually delete (DANGEROUS!)
var deleteUnused = false;

var unusedMeasures = Model.AllMeasures
    .Where(m => m.ReferencedBy.Count == 0)
    .ToList();

if(unusedMeasures.Count == 0)
{
    Info("No unused measures found");
}
else
{
    Info($"Found {unusedMeasures.Count} unused measures:");
    
    foreach(var m in unusedMeasures)
    {
        if(deleteUnused)
        {
            Warning($"Deleting [{m.Name}]");
            m.Delete();
        }
        else
        {
            Info($"  - [{m.Name}] in table [{m.Table.Name}]");
        }
    }
    
    if(!deleteUnused)
        Info("Set deleteUnused = true to remove these measures");
}
```

## Creating Your Own Scripts

### Template

```csharp
/*
 * Script: YourScriptName.cs
 * Purpose: Brief description
 * 
 * Usage:
 *   TabularEditor.exe "Model.bim" -S "YourScriptName.cs" -B "Model.bim"
 * 
 * Parameters:
 *   - param1: Description
 * 
 * Author: Your Name
 * Date: YYYY-MM
 */

// Configuration
var param1 = "value";

// Main logic
foreach(var m in Model.AllMeasures)
{
    // Your logic here
    Info($"Processed [{m.Name}]");
}

Info("Script completed");
```

### Best Practices

1. **Always log operations** with Info(), Warning(), Error()
2. **Test on copies first** before running on real models
3. **Make scripts idempotent** - safe to run multiple times
4. **Document parameters** and expected behavior
5. **Handle edge cases** - null checks, empty strings, etc.

## Related

- [Tabular Editor CLI Reference](../TabularEditorCLI.md)
- [CLI Tools Workflow](../../Workflows/CLIToolsWorkflow.md)
