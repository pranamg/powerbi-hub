# Tabular Editor CLI Reference

> Complete command-line options for semantic model automation

## Overview

Tabular Editor 2 provides a powerful command-line interface for automating semantic model operations. This is essential for CI/CD pipelines and agentic development.

**Download:** [GitHub Releases](https://github.com/TabularEditor/TabularEditor/releases)

## Basic Syntax

```bash
TabularEditor.exe <input> [options]
```

**Note:** Since TabularEditor.exe is a WinForms application, use `start /wait` in Windows command prompt:

```cmd
start /wait TabularEditor.exe "Model.bim" -A
```

In PowerShell:

```powershell
$p = Start-Process -FilePath TabularEditor.exe -Wait -NoNewWindow -PassThru -ArgumentList '"Model.bim" -A'
exit $p.ExitCode
```

## Input Options

### File Input

```bash
# Model.bim file
TabularEditor.exe "C:\Models\Model.bim" [options]

# TMDL folder
TabularEditor.exe "C:\Models\definition\" [options]

# Database.json folder (Tabular Editor save-to-folder)
TabularEditor.exe "C:\Models\database.json" [options]
```

### Server Connection

```bash
# Server and database
TabularEditor.exe "localhost\tabular" "SalesModel" [options]

# Azure Analysis Services
TabularEditor.exe "asazure://region.asazure.windows.net/server" "database" [options]

# With connection string
TabularEditor.exe "Provider=MSOLAP;Data Source=server;..." "database" [options]
```

### Power BI Desktop

```bash
# Connect to single running instance
TabularEditor.exe -L [options]

# Connect to specific PBIX (by name)
TabularEditor.exe -L "SalesReport" [options]
```

## Script Execution (-S)

Execute C# scripts against the model.

```bash
# Single script
TabularEditor.exe "Model.bim" -S "Script.cs"

# Multiple scripts (executed in order)
TabularEditor.exe "Model.bim" -S "Script1.cs" -S "Script2.cs"

# Inline script
TabularEditor.exe "Model.bim" -S "foreach(var m in Model.AllMeasures) m.Description = m.Name;"
```

### Script Methods

| Method | Description |
|--------|-------------|
| `Info(string)` | Output informational message |
| `Warning(string)` | Output warning message |
| `Error(string)` | Output error (causes non-zero exit) |
| `Output(string)` | Same as Info() |

### Script Access

Scripts have access to:

- `Model` - The TOM Model object
- `Selected` - Currently selected objects (if any)
- Full .NET framework
- TOM library

## Best Practice Analyzer (-A)

Run BPA rules and output violations.

```bash
# Run with local/model rules
TabularEditor.exe "Model.bim" -A

# Run with specific rules file
TabularEditor.exe "Model.bim" -A "CustomRules.json"

# Exclude model annotations
TabularEditor.exe "Model.bim" -AX "Rules.json"
```

### Severity Levels

| Level | Azure DevOps (-V) | GitHub Actions (-G) |
|-------|-------------------|---------------------|
| 1 | Information | Notice |
| 2 | Warning | Warning |
| 3+ | Error | Error |

## Output Options

### Save as Model.bim (-B)

```bash
TabularEditor.exe "input.bim" -S "Script.cs" -B "output.bim"

# With custom database ID
TabularEditor.exe "input.bim" -B "output.bim" "CustomDatabaseName"
```

### Save as TMDL (-TMDL)

```bash
TabularEditor.exe "Model.bim" -TMDL "output/definition/"

# Convert TMDL to BIM
TabularEditor.exe "definition/" -B "Model.bim"
```

### Save as Folder (-F)

```bash
# Tabular Editor's folder format
TabularEditor.exe "Model.bim" -F "output/"
```

## Deployment (-D)

Deploy model to Analysis Services or Power BI.

```bash
# Basic deployment (requires existing database)
TabularEditor.exe "Model.bim" -D "server" "database"

# Allow overwrite of existing database
TabularEditor.exe "Model.bim" -D "server" "database" -O

# Full deployment (all options)
TabularEditor.exe "Model.bim" -D "server" "database" -O -C -P -S -R -M

# Generate XMLA script instead of deploying
TabularEditor.exe "Model.bim" -D "server" "database" -X "deploy.xmla"
```

### Deployment Flags

| Flag | Full | Description |
|------|------|-------------|
| `-O` | `-OVERWRITE` | Allow overwrite of existing database |
| `-C` | `-CONNECTIONS` | Deploy data source connections |
| `-P` | `-PARTITIONS` | Deploy partitions |
| `-Y` | `-SKIPPOLICY` | Skip incremental refresh partitions |
| `-S` | `-SHARED` | Deploy shared expressions |
| `-R` | `-ROLES` | Deploy roles |
| `-M` | `-MEMBERS` | Deploy role members |
| `-F` | `-FULL` | Equivalent to -O -C -P -S -R -M |
| `-X` | `-XMLA` | Generate XMLA script only |
| `-W` | `-WARN` | Output unprocessed objects as warnings |
| `-E` | `-ERR` | Return error if AS reports errors |

### Connection String Replacement

```bash
# Replace placeholder with actual connection string
TabularEditor.exe "Model.bim" -D "server" "database" \
    -C "PLACEHOLDER" "Provider=SQLOLEDB;Data Source=prodserver;..."

# Multiple replacements
TabularEditor.exe "Model.bim" -D "server" "database" \
    -C "SQL_PLACEHOLDER" "Provider=SQLOLEDB;Data Source=sql;..." \
    -C "BLOB_PLACEHOLDER" "Provider=AzureBlob;AccountName=..."
```

### Authentication

```bash
# Windows authentication (default)
TabularEditor.exe "Model.bim" -D "server" "database" -O

# SQL/AAD authentication
TabularEditor.exe "Model.bim" -D "server" "database" -L "username" "password" -O

# Service Principal (in connection string)
TabularEditor.exe "Provider=MSOLAP;Data Source=server;User ID=app:appid@tenant;Password=secret" "database" -O
```

## Schema Check (-SC)

Validate data source schemas.

```bash
# Check for schema changes
TabularEditor.exe "Model.bim" -SC

# Run after script (e.g., to set credentials first)
TabularEditor.exe "Model.bim" -S "SetCredentials.cs" -SC
```

### Schema Check Output

| Level | Meaning |
|-------|---------|
| Warning | Mismatched data types, unmapped source columns |
| Error | Unmapped model columns (breaking) |

## CI/CD Integration

### Azure DevOps (-V)

```bash
# Output in Azure DevOps format
TabularEditor.exe "Model.bim" -A -V

# Pipeline example
TabularEditor.exe "Model.bim" -A -V -SC
TabularEditor.exe "Model.bim" -D $(Server) $(Database) -O -V -W -E
```

### GitHub Actions (-G)

```bash
# Output in GitHub Actions format
TabularEditor.exe "Model.bim" -A -G
```

### Test Results (-T)

```bash
# Generate TRX test results file
TabularEditor.exe "Model.bim" -A -T "results.trx"
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (invalid arguments, BPA errors, deployment failed, script errors) |

## Common Patterns

### Validate and Deploy

```bash
# Validate
TabularEditor.exe "Model.bim" -A -V
if errorlevel 1 exit /b 1

# Deploy
TabularEditor.exe "Model.bim" -D "server" "database" -O -C -P -S -V -W -E
```

### Convert Formats

```bash
# PBIP TMDL to BIM
TabularEditor.exe "Report.SemanticModel/definition/" -B "Model.bim"

# BIM to TMDL
TabularEditor.exe "Model.bim" -TMDL "definition/"
```

### Script with Output

```bash
# Run script, save result, validate
TabularEditor.exe "Model.bim" -S "AddMeasures.cs" -B "Model_new.bim"
TabularEditor.exe "Model_new.bim" -A -V
```

### Environment-Specific Deployment

```bash
# Development
TabularEditor.exe "Model.bim" -S "ClearConnections.cs" -D "devserver" "SalesModel" -C "DB" "DevDB" -F

# Production  
TabularEditor.exe "Model.bim" -S "ClearConnections.cs" -D "prodserver" "SalesModel" -C "DB" "ProdDB" -F
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Command returns immediately | Use `start /wait` in CMD or `Start-Process -Wait` in PowerShell |
| "File not found" | Use full paths, wrap in quotes |
| Authentication fails | Check connection string, use -L for credentials |
| BPA not finding rules | Check BPARules.json path in %LocalAppData%\TabularEditor |
| Script compilation error | Check C# syntax, verify using statements |

## References

- [Official Documentation](https://docs.tabulareditor.com/te2/Command-line-Options.html)
- [Tabular Editor GitHub](https://github.com/TabularEditor/TabularEditor)
- [Azure DevOps Integration](https://tabulareditor.github.io/2019/10/08/DevOps3.html)
