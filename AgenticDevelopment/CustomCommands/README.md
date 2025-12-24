# Custom Commands: Reusable Workflow Automation

> Command-line tools and scripts for automated semantic model management

## Overview

Custom commands enable agents to perform deterministic, repeatable operations on semantic models. This includes CLI tools like Tabular Editor and reusable C# scripts.

## Available Tools

### Tabular Editor CLI

The primary CLI tool for semantic model automation.

| Capability | Description |
|------------|-------------|
| Script execution | Run C# scripts against models |
| Best Practice Analyzer | Validate models against rules |
| Deployment | Deploy to Analysis Services |
| Format conversion | BIM ↔ TMDL ↔ Folder |

[Full CLI Reference](./TabularEditorCLI.md)

### Fabric CLI

Microsoft's command-line tool for Fabric resources.

```bash
# Install
pip install azure-cli
az extension add --name fabric

# Example: List workspaces
az fabric workspace list
```

### Power BI CLI (pbi-tools)

Open-source tool for Power BI automation.

```bash
# Extract PBIX
pbi-tools extract "Report.pbix" -outPath "./extracted"

# Compile to PBIX
pbi-tools compile "./extracted" -outPath "Report.pbix"
```

## Script Categories

### Model Management Scripts

Scripts for structural operations:

- Create tables, columns, measures
- Modify relationships
- Configure partitions
- Manage security roles

### DAX Scripts

Scripts for DAX operations:

- Create time intelligence measures
- Refactor DAX patterns
- Format DAX expressions
- Validate DAX syntax

### Documentation Scripts

Scripts for model documentation:

- Generate descriptions
- Create model documentation
- Export metadata to Excel/JSON
- Sync with external documentation

### Deployment Scripts

Scripts for CI/CD:

- Validate before deployment
- Environment-specific connection strings
- Incremental deployment
- Rollback procedures

## Agent Integration

### Providing Scripts to Agents

Create a scripts folder that agents can discover:

```
AgenticDevelopment/
└── CustomCommands/
    └── ScriptExamples/
        ├── README.md
        ├── AddDescriptions.cs
        ├── SetFormatStrings.cs
        └── CreateTimeIntelligence.cs
```

### Agent Instructions

Include in your AGENTS.md:

```markdown
## Available Scripts

### TabularEditor CLI
Location: TabularEditor.exe (in PATH)

### Scripts Directory
./AgenticDevelopment/CustomCommands/ScriptExamples/

### Common Operations

1. **Validate Model**
   ```bash
   TabularEditor.exe "Model.bim" -A
   ```

2. **Run Script**
   ```bash
   TabularEditor.exe "Model.bim" -S "script.cs" -B "Model.bim"
   ```

3. **Deploy**
   ```bash
   TabularEditor.exe "Model.bim" -D "server" "database" -O
   ```
```

## Creating Custom Commands

### Step 1: Identify Repeatable Task

Tasks that benefit from automation:

- Applied frequently (weekly+)
- Consistent logic each time
- Multiple objects affected
- Error-prone when done manually

### Step 2: Write the Script

```csharp
// Example: SetStandardFormatStrings.cs

// Define format string mappings
var formatMappings = new Dictionary<string, string>
{
    { "revenue", "$#,##0.00" },
    { "cost", "$#,##0.00" },
    { "price", "$#,##0.00" },
    { "quantity", "#,##0" },
    { "count", "#,##0" },
    { "percent", "0.00%" },
    { "ratio", "0.00%" }
};

foreach(var m in Model.AllMeasures)
{
    var nameLower = m.Name.ToLower();
    
    foreach(var mapping in formatMappings)
    {
        if(nameLower.Contains(mapping.Key))
        {
            m.FormatString = mapping.Value;
            Info($"Set {m.Name} format to {mapping.Value}");
            break;
        }
    }
}
```

### Step 3: Test Thoroughly

```bash
# Test on copy first
cp Model.bim Model_backup.bim
TabularEditor.exe Model.bim -S SetStandardFormatStrings.cs -B Model_test.bim

# Validate
TabularEditor.exe Model_test.bim -A

# If good, apply to original
TabularEditor.exe Model.bim -S SetStandardFormatStrings.cs -B Model.bim
```

### Step 4: Document the Script

```csharp
/*
 * Script: SetStandardFormatStrings.cs
 * Purpose: Apply standard format strings based on measure names
 * 
 * Usage:
 *   TabularEditor.exe "Model.bim" -S "SetStandardFormatStrings.cs" -B "Model.bim"
 * 
 * Behavior:
 *   - Measures with "revenue", "cost", "price" → $#,##0.00
 *   - Measures with "quantity", "count" → #,##0
 *   - Measures with "percent", "ratio" → 0.00%
 * 
 * Author: Your Name
 * Date: 2024-12
 */
```

## Command Patterns

### Pattern: Validate-Then-Deploy

```bash
#!/bin/bash
# validate-deploy.sh

MODEL="Model.SemanticModel/definition"
SERVER="devserver"
DATABASE="SalesModel"

# Step 1: Run BPA
echo "Validating model..."
TabularEditor.exe "$MODEL" -A -V
if [ $? -ne 0 ]; then
    echo "Validation failed!"
    exit 1
fi

# Step 2: Deploy
echo "Deploying model..."
TabularEditor.exe "$MODEL" -D "$SERVER" "$DATABASE" -O -V
if [ $? -ne 0 ]; then
    echo "Deployment failed!"
    exit 1
fi

echo "Success!"
```

### Pattern: Parameterized Connection String

```bash
# Deploy with environment-specific connection
TabularEditor.exe "Model.bim" \
    -S "ClearConnectionStrings.cs" \
    -D "server" "database" \
    -C "PLACEHOLDER" "Provider=SQLOLEDB;Data Source=prodserver;..."
```

### Pattern: Script Chain

```bash
# Run multiple scripts in sequence
TabularEditor.exe "Model.bim" \
    -S "Step1_SetDefaults.cs" \
    -S "Step2_AddMeasures.cs" \
    -S "Step3_Validate.cs" \
    -TMDL "output/"
```

## Folder Contents

| File | Description |
|------|-------------|
| [TabularEditorCLI.md](./TabularEditorCLI.md) | Complete CLI reference |
| [ScriptExamples/](./ScriptExamples/) | Ready-to-use C# scripts |

## Best Practices

1. **Version Control Scripts**: Keep scripts in source control with the model
2. **Document Parameters**: Explain any required inputs
3. **Handle Errors**: Use try/catch and provide meaningful messages
4. **Log Operations**: Use Info(), Warning(), Error() for visibility
5. **Test on Copies**: Never run untested scripts on production models
6. **Idempotent Design**: Scripts should be safe to run multiple times
