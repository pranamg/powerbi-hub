# Hooks: Automated Triggers and Quality Gates

> Integrate validation and automation into your agentic development workflow

## Overview

Hooks are automated triggers that run at specific points in your development workflow. They ensure quality, validate changes, and can integrate with CI/CD pipelines.

## Types of Hooks

### Pre-Commit Hooks

Run before changes are committed to source control:

```yaml
# Example: .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-tmdl
        name: Validate TMDL Syntax
        entry: TabularEditor.exe model.bim -A rules.json -V
        language: system
        files: \.tmdl$
      - id: best-practice-analyzer
        name: Run Best Practice Analyzer
        entry: TabularEditor.exe model.bim -A -V
        language: system
        pass_filenames: false
```

### Post-Commit Hooks

Run after changes are committed:

- Trigger automated deployments
- Notify team members
- Update documentation

### CI/CD Pipeline Hooks

Integrate with Azure DevOps, GitHub Actions, or other CI/CD systems.

## Best Practice Analyzer Integration

The Tabular Editor Best Practice Analyzer (BPA) is essential for quality gates.

### Running BPA via CLI

```bash
# Basic analysis
TabularEditor.exe "Model.bim" -A

# With custom rules file
TabularEditor.exe "Model.bim" -A "CustomRules.json"

# Output for Azure DevOps
TabularEditor.exe "Model.bim" -A -V

# Output for GitHub Actions
TabularEditor.exe "Model.bim" -A -G
```

### BPA Severity Levels

| Severity | CI/CD Behavior |
|----------|----------------|
| 1 | Informational only |
| 2 | Warning (SucceededWithIssues) |
| 3+ | Error (Failed) |

### Sample BPA Rules for Agentic Development

```json
[
  {
    "ID": "AGENT_001",
    "Name": "Measures must have descriptions",
    "Category": "Documentation",
    "Description": "All measures should have descriptions for AI context",
    "Severity": 2,
    "Scope": "Measure",
    "Expression": "string.IsNullOrWhiteSpace(Description)"
  },
  {
    "ID": "AGENT_002", 
    "Name": "Tables must follow naming convention",
    "Category": "Naming",
    "Severity": 3,
    "Scope": "Table",
    "Expression": "!System.Text.RegularExpressions.Regex.IsMatch(Name, \"^[A-Z][a-zA-Z0-9 ]*$\")"
  }
]
```

## Schema Check Hook

Validate data source schemas before deployment:

```bash
# Check for schema changes
TabularEditor.exe "Model.bim" -SC

# Combined with script execution
TabularEditor.exe "Model.bim" -S "UpdateConnections.cs" -SC
```

### Schema Check Output

| Level | Meaning |
|-------|---------|
| Warning | Mismatched data types, unmapped source columns |
| Error | Unmapped model columns (breaking changes) |

## Azure DevOps Integration

### Pipeline YAML Example

```yaml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
  - task: PowerShell@2
    displayName: 'Validate Model'
    inputs:
      targetType: 'inline'
      script: |
        $p = Start-Process -FilePath "TabularEditor.exe" `
          -Wait -NoNewWindow -PassThru `
          -ArgumentList '"$(Build.SourcesDirectory)\Model.bim" -A -V -SC'
        exit $p.ExitCode

  - task: PowerShell@2
    displayName: 'Deploy to Dev'
    condition: succeeded()
    inputs:
      targetType: 'inline'
      script: |
        $p = Start-Process -FilePath "TabularEditor.exe" `
          -Wait -NoNewWindow -PassThru `
          -ArgumentList '"$(Build.SourcesDirectory)\Model.bim" -D $(ServerName) $(DatabaseName) -O -C -P -S -V -E -W'
        exit $p.ExitCode
```

## GitHub Actions Integration

```yaml
name: Validate Semantic Model

on:
  pull_request:
    paths:
      - '**.tmdl'
      - '**.bim'

jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Best Practice Analyzer
        run: |
          TabularEditor.exe "Model.bim" -A -G
        shell: cmd
```

## Quality Gate Checklist

Before merging/deploying, ensure:

- [ ] BPA returns no errors (Severity 3+)
- [ ] Schema check passes
- [ ] TMDL files are valid (model loads in Tabular Editor)
- [ ] DAX syntax is valid (no semantic analysis errors)
- [ ] All measures have descriptions
- [ ] Naming conventions are followed

## Agent-Specific Hooks

### Validation After Agent Changes

Create a script that runs after agent modifications:

```csharp
// ValidateAgentChanges.cs
// Run after agent modifies model

// Check for common agent mistakes
foreach(var m in Model.AllMeasures)
{
    // Verify DAX syntax
    if(m.ErrorMessage != null)
        Error($"Measure {m.Name} has DAX error: {m.ErrorMessage}");
    
    // Check for placeholder descriptions
    if(m.Description?.Contains("TODO") == true)
        Warning($"Measure {m.Name} has placeholder description");
}

// Verify no orphaned objects
foreach(var c in Model.AllColumns.Where(c => c.IsReferenced == false && !c.IsKey))
    Info($"Column {c.DaxObjectFullName} is not referenced anywhere");
```

## References

- [Tabular Editor CLI Options](../CustomCommands/TabularEditorCLI.md)
- [Best Practice Analyzer Documentation](https://docs.tabulareditor.com/te2/Best-Practice-Analyzer.html)
- [Azure DevOps Integration Guide](https://tabulareditor.github.io/2019/10/08/DevOps3.html)
