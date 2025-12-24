# CLI Tools Workflow

> Using Tabular Editor CLI and other command-line tools with agents

## Overview

In this workflow, the agent executes command-line tools to interact with semantic models. This approach provides maximum flexibility and is ideal for automation, CI/CD pipelines, and deterministic operations.

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│                    CLI TOOLS WORKFLOW                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│    User Prompt                                                │
│        │                                                      │
│        ▼                                                      │
│    ┌───────────────┐                                         │
│    │ Agent reads   │                                         │
│    │ instructions  │                                         │
│    └───────┬───────┘                                         │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐      ┌─────────────┐                   │
│    │ Agent writes  │ ───► │ C# Script   │                   │
│    │ or selects    │      │ or CLI args │                   │
│    │ script        │      └──────┬──────┘                   │
│    └───────┬───────┘             │                           │
│            │                     ▼                           │
│            │              ┌─────────────┐                   │
│            │              │TabularEditor│                   │
│            │              │    CLI      │                   │
│            │              └──────┬──────┘                   │
│            │                     │                           │
│            │                     ▼                           │
│            │              ┌─────────────┐                   │
│            │              │ Model.bim / │                   │
│            │              │ TMDL / SSAS │                   │
│            │              └─────────────┘                   │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐                                         │
│    │ Agent reports │                                         │
│    │ results       │                                         │
│    └───────────────┘                                         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Tabular Editor 2 CLI**: Download from [GitHub](https://github.com/TabularEditor/TabularEditor/releases)
2. **PATH Configuration**: Add TabularEditor.exe to system PATH
3. **Coding Agent**: With bash/terminal execution capability
4. **Model Files**: Model.bim, TMDL folder, or connection string

## Tabular Editor CLI Basics

### Command Structure

```bash
TabularEditor.exe <input> [options]

# Input options:
#   file.bim          - Model.bim file
#   folder/           - TMDL folder
#   "server" "db"     - Server connection
#   -L [name]         - Local Power BI Desktop
```

### Common Options

| Option | Description |
|--------|-------------|
| `-S script.cs` | Execute C# script |
| `-A [rules.json]` | Run Best Practice Analyzer |
| `-B output.bim` | Save as Model.bim |
| `-TMDL folder` | Save as TMDL |
| `-D server db` | Deploy to server |
| `-V` | Azure DevOps output |
| `-G` | GitHub Actions output |

## Best Use Cases

### 1. Running Best Practice Analyzer

```bash
# Basic BPA run
TabularEditor.exe "Model.bim" -A

# With custom rules
TabularEditor.exe "Model.bim" -A "CustomRules.json"

# With CI/CD output
TabularEditor.exe "Model.bim" -A -V
```

Example agent interaction:

```
User: Run BPA on the model and show me violations

Agent: [Executes CLI command]

$ TabularEditor.exe "Model.SemanticModel/definition" -A

BPA Results:
WARNING: [Gross Margin] - Measure has no description
WARNING: [Revenue YTD] - Consider using TOTALYTD for readability
ERROR: [Bad Calc] - References non-existent column

2 warnings, 1 error found.
```

### 2. Executing C# Scripts

Scripts provide full TOM access:

```bash
# Run a script against model file
TabularEditor.exe "Model.bim" -S "AddDescriptions.cs" -B "Model.bim"

# Run script against Power BI Desktop
TabularEditor.exe -L -S "RefactorMeasures.cs"

# Chain multiple scripts
TabularEditor.exe "Model.bim" -S "Script1.cs" -S "Script2.cs" -TMDL "output/"
```

### 3. Model Deployment

```bash
# Deploy with overwrite
TabularEditor.exe "Model.bim" -D "localhost\tabular" "MyDatabase" -O

# Full deployment (overwrite connections, partitions, roles)
TabularEditor.exe "Model.bim" -D "server" "database" -F

# Generate deployment script only
TabularEditor.exe "Model.bim" -D "server" "database" -X "deploy.xmla"
```

### 4. Format Conversion

```bash
# BIM to TMDL
TabularEditor.exe "Model.bim" -TMDL "output/"

# TMDL to BIM
TabularEditor.exe "definition/" -B "Model.bim"

# Save to folder format
TabularEditor.exe "Model.bim" -F "output/"
```

## C# Scripts for Agents

### Script: Add Descriptions to Measures

```csharp
// AddDescriptions.cs
foreach(var m in Model.AllMeasures.Where(m => string.IsNullOrEmpty(m.Description)))
{
    // Generate description from DAX
    var dax = m.Expression;
    
    if(dax.Contains("SUM("))
        m.Description = $"Sum of {m.Name}";
    else if(dax.Contains("CALCULATE("))
        m.Description = $"Calculated measure for {m.Name}";
    else if(dax.Contains("DIVIDE("))
        m.Description = $"Ratio calculation for {m.Name}";
    else
        m.Description = $"Measure: {m.Name}";
    
    Info($"Added description to {m.Name}");
}
```

### Script: Bulk Format Strings

```csharp
// SetFormatStrings.cs
foreach(var m in Model.AllMeasures)
{
    var name = m.Name.ToLower();
    
    if(name.Contains("%") || name.Contains("percent") || name.Contains("ratio"))
        m.FormatString = "0.00%";
    else if(name.Contains("revenue") || name.Contains("sales") || name.Contains("cost"))
        m.FormatString = "$#,##0.00";
    else if(name.Contains("count") || name.Contains("qty"))
        m.FormatString = "#,##0";
}
```

### Script: Refactor to DIVIDE

```csharp
// RefactorToDivide.cs
var pattern = @"(\[[\w\s]+\])\s*/\s*(\[[\w\s]+\])";
var regex = new System.Text.RegularExpressions.Regex(pattern);

foreach(var m in Model.AllMeasures)
{
    if(regex.IsMatch(m.Expression))
    {
        var oldExpr = m.Expression;
        var newExpr = regex.Replace(oldExpr, "DIVIDE($1, $2, 0)");
        m.Expression = newExpr;
        Info($"Refactored {m.Name}");
    }
}
```

### Script: Create Time Intelligence

```csharp
// CreateTimeIntelligence.cs
var baseMeasures = Model.AllMeasures.Where(m => 
    !m.Name.Contains("YTD") && 
    !m.Name.Contains("PY") && 
    !m.Name.Contains("YoY")).ToList();

foreach(var m in baseMeasures)
{
    var table = m.Table;
    var name = m.Name;
    
    // YTD
    if(!table.Measures.Any(x => x.Name == $"{name} YTD"))
    {
        var ytd = table.AddMeasure($"{name} YTD", $"TOTALYTD([{name}], 'Date'[Date])");
        ytd.DisplayFolder = m.DisplayFolder + "\\Time Intelligence";
        ytd.FormatString = m.FormatString;
    }
    
    // PY
    if(!table.Measures.Any(x => x.Name == $"{name} PY"))
    {
        var py = table.AddMeasure($"{name} PY", 
            $"CALCULATE([{name}], SAMEPERIODLASTYEAR('Date'[Date]))");
        py.DisplayFolder = m.DisplayFolder + "\\Time Intelligence";
        py.FormatString = m.FormatString;
    }
}
```

## Agent-Generated Scripts

Agents can write scripts on the fly:

```
User: Write a script to rename all measures that start with 
      "Total" to start with "Sum of" instead

Agent: I'll create a C# script for this...

[Writes RefactorNames.cs]

// RefactorNames.cs
foreach(var m in Model.AllMeasures.Where(m => m.Name.StartsWith("Total ")))
{
    var newName = m.Name.Replace("Total ", "Sum of ");
    Info($"Renaming '{m.Name}' to '{newName}'");
    m.Name = newName;
}

[Executes]
$ TabularEditor.exe "Model.bim" -S "RefactorNames.cs" -B "Model.bim"

Renamed 12 measures.
```

## Advantages

### Deterministic Results

Same script = same result every time:

```bash
# This will always produce identical output
TabularEditor.exe "Model.bim" -S "StandardSetup.cs" -B "Model.bim"
```

### Full Flexibility

Scripts can do anything TOM allows:

- Create complex objects
- Implement custom logic
- Conditional modifications
- Integration with external systems

### No Context Window Cost

Unlike MCP, CLI tools don't consume LLM context:

```
┌────────────────────────────────────────┐
│ Context Window Usage                    │
├────────────────────────────────────────┤
│ ██████░░░░░░░░░░░░░░ System (15%)     │
│ ░░░░░░░░░░░░░░░░░░░░ Available (85%)  │
└────────────────────────────────────────┘
```

### CI/CD Integration

Perfect for automated pipelines:

```yaml
- script: |
    TabularEditor.exe "Model.bim" -A -V
    TabularEditor.exe "Model.bim" -D $(Server) $(Database) -O -V
  displayName: 'Validate and Deploy'
```

## Limitations

### Requires Good Context

Agent needs instructions on how to use CLI:

```markdown
# CLI Instructions for Agent

## Tabular Editor CLI
Location: C:\Tools\TabularEditor.exe

## Common Commands
- Validate: TabularEditor.exe "Model.bim" -A
- Deploy: TabularEditor.exe "Model.bim" -D "server" "db" -O
- Script: TabularEditor.exe "Model.bim" -S "script.cs" -B "Model.bim"
```

### Script Knowledge Required

Agent needs to know C# scripting patterns:

- Provide example scripts in context
- Use script templates

### No Interactive Validation

Changes apply immediately:

- No preview before execution
- Use `-B` to save to new file first
- Check with BPA after changes

## Tips for Success

### 1. Create Script Library

Maintain reusable scripts:

```
Scripts/
├── CSharp/
│   ├── TabularEditor/
│   │   ├── AddDescriptions.cs
│   │   ├── SetFormatStrings.cs
│   │   ├── CreateTimeIntelligence.cs
│   │   └── RefactorDivide.cs
```

### 2. Test Scripts Safely

```bash
# Save to new file first
TabularEditor.exe "Model.bim" -S "Script.cs" -B "Model_Modified.bim"

# Validate the result
TabularEditor.exe "Model_Modified.bim" -A

# If good, overwrite original
mv Model_Modified.bim Model.bim
```

### 3. Use Exit Codes

Check command success:

```bash
TabularEditor.exe "Model.bim" -A
if [ $? -ne 0 ]; then
    echo "BPA found errors"
    exit 1
fi
```

### 4. Combine with Source Control

```bash
# Before changes
git add -A && git commit -m "Before script execution"

# Run script
TabularEditor.exe "Model.bim" -S "Changes.cs" -TMDL "definition/"

# Review and commit
git diff
git add -A && git commit -m "Applied changes via CLI"
```

## Example Session

```
User: I need to validate the model, fix any BPA warnings, 
      and then deploy to the dev server

Agent: I'll run this in three steps...

Step 1: Run BPA
$ TabularEditor.exe "definition/" -A

Found 3 warnings:
- [Revenue] missing description
- [Cost] missing format string
- [Margin %] in wrong display folder

Step 2: Fix issues with scripts

[Writes and executes FixWarnings.cs]

$ TabularEditor.exe "definition/" -S "FixWarnings.cs" -TMDL "definition/"

Fixed 3 issues.

Step 3: Verify and deploy

$ TabularEditor.exe "definition/" -A

No BPA violations found.

$ TabularEditor.exe "definition/" -D "devserver" "SalesModel" -O -V

Deployment successful.
```

## Related

- [Tabular Editor CLI Reference](../CustomCommands/TabularEditorCLI.md)
- [Script Examples](../CustomCommands/ScriptExamples/)
- [Direct Metadata Modification](./DirectMetadataModification.md)
