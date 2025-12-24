# Direct Metadata Modification Workflow

> Working with TMDL files directly using coding agents

## Overview

In this workflow, the agent uses its built-in read/write tools to directly modify semantic model metadata files. This is the simplest approach and works best for search operations and simple edits.

## How It Works

```
┌──────────────────────────────────────────────────────────────┐
│                    DIRECT TMDL WORKFLOW                       │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│    User Prompt                                                │
│        │                                                      │
│        ▼                                                      │
│    ┌───────────────┐                                         │
│    │ Agent reads   │ ──────► TMDL files                      │
│    │ instructions  │         (tables/*.tmdl)                 │
│    └───────┬───────┘                                         │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐                                         │
│    │ Agent searches│ ◄────► model.tmdl                       │
│    │ or modifies   │        relationships.tmdl               │
│    └───────┬───────┘        roles.tmdl                       │
│            │                                                  │
│            ▼                                                  │
│    ┌───────────────┐                                         │
│    │ User validates│ ──────► Tabular Editor                  │
│    │ in tool       │         Power BI Desktop                │
│    └───────────────┘                                         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **PBIP Format**: Save your model as Power BI Project
2. **TMDL Format**: Enable TMDL in definition folder
3. **Coding Agent**: Claude Code, GitHub Copilot, etc.
4. **VS Code**: With TMDL extension for syntax highlighting
5. **Tabular Editor**: For validation

## TMDL File Structure

```
Model.SemanticModel/
├── definition/
│   ├── database.tmdl
│   ├── model.tmdl
│   ├── relationships.tmdl
│   ├── roles.tmdl
│   ├── tables/
│   │   ├── Sales.tmdl
│   │   ├── Products.tmdl
│   │   ├── Customers.tmdl
│   │   └── Date.tmdl
│   └── expressions/
│       └── shared-expressions.tmdl
└── .platform
```

## TMDL Syntax Basics

### Table Definition

```tmdl
table Sales
    lineageTag: abc123-def456

    measure 'Total Revenue' = SUM(Sales[Revenue])
        formatString: $#,##0.00
        displayFolder: Revenue
        description: Sum of all revenue

    column OrderID
        dataType: int64
        formatString: 0
        lineageTag: xyz789
        sourceColumn: OrderID
```

### Measure Definition

```tmdl
measure 'Revenue YTD' = TOTALYTD([Total Revenue], 'Date'[Date])
    formatString: $#,##0.00
    displayFolder: Revenue\Time Intelligence
    description: Year-to-date revenue calculation
```

## Best Use Cases

### 1. Searching the Model

Fast and efficient for finding patterns:

```
User: "Find all measures that use CALCULATE"

Agent: [Searches .tmdl files for CALCULATE pattern]
       [Returns list with file locations and line numbers]
```

### 2. Simple Property Updates

Single changes to existing objects:

```
User: "Change the display folder of [Total Revenue] to 'KPIs'"

Agent: [Reads Sales.tmdl]
       [Updates displayFolder property]
       [Writes file]
```

### 3. Refactoring Names

Finding and replacing across files:

```
User: "Rename 'Sales Amount' to 'Total Sales' everywhere"

Agent: [Searches all .tmdl files]
       [Updates measure name and all references]
```

### 4. Reading DAX Expressions

Understanding existing calculations:

```
User: "Explain what the [Gross Margin %] measure does"

Agent: [Reads measure definition from .tmdl]
       [Analyzes DAX expression]
       [Provides explanation]
```

## Challenges

### TMDL is Whitespace-Sensitive

Incorrect indentation breaks the model:

```tmdl
// CORRECT
measure 'Total Revenue' = SUM(Sales[Revenue])
    formatString: $#,##0.00
    displayFolder: Revenue

// INCORRECT (wrong indentation)
measure 'Total Revenue' = SUM(Sales[Revenue])
  formatString: $#,##0.00    // Wrong indent
      displayFolder: Revenue  // Wrong indent
```

### Multi-Syntax Files

TMDL files contain embedded DAX and M:

```tmdl
table Sales
    // TMDL syntax here

    measure 'Complex Calc' =
        // DAX syntax here
        VAR Revenue = SUM(Sales[Amount])
        VAR Cost = SUM(Sales[Cost])
        RETURN DIVIDE(Revenue - Cost, Revenue, 0)

    partition Sales = m
        mode: import
        source =
            // M syntax here
            let
                Source = Sql.Database("server", "database")
            in
                Source
```

### New Format = Less Training Data

LLMs have less exposure to TMDL compared to TMSL:

- May generate invalid TMDL syntax
- May confuse TMDL with YAML
- Needs good context files with examples

## Tips for Success

### 1. Use the TMDL Extension

Install in VS Code for:
- Syntax highlighting
- Basic validation
- Error indicators

### 2. Provide TMDL Examples

Include correct TMDL patterns in your context:

```markdown
# TMDL Measure Format

Always use this exact format for measures:

​```tmdl
measure 'Measure Name' = <DAX Expression>
    formatString: <format>
    displayFolder: <folder>
    description: <description>
​```
```

### 3. Use Faster Models for Search

- Haiku 4.5 for searching and summarizing
- Sonnet/Opus for generating new content

### 4. Validate After Every Change

```bash
# Load in Tabular Editor to validate
TabularEditor.exe "Model.SemanticModel/definition" -V
```

### 5. Use Checkpoints

Before risky operations:

```
Agent: Creating checkpoint before bulk changes...
[Checkpoint saved]

Agent: Proceeding with modifications...
```

### 6. Combine with Source Control

```bash
# Before starting
git status
git add -A
git commit -m "Checkpoint before agent modifications"

# After agent changes
git diff  # Review changes
git add -A
git commit -m "Agent: Added YTD measures"
```

## Example Session

```
User: Find all measures that don't have descriptions and add 
      descriptions based on their DAX expressions

Agent: I'll search for measures without descriptions...

[Searches .tmdl files]

Found 15 measures without descriptions:
1. [Total Revenue] in Sales.tmdl
2. [Unit Price] in Products.tmdl
...

Let me analyze each DAX expression and generate descriptions.

[For each measure]:
- Reading DAX expression
- Generating description
- Updating .tmdl file

[Shows diff for each change]

Done. Updated 15 measures with descriptions.
Please validate in Tabular Editor before committing.
```

## When NOT to Use This Workflow

- **Creating new tables**: Use MCP or Tabular Editor
- **Complex DAX changes**: Validation not immediate
- **Bulk operations**: MCP is more efficient
- **When you need validation**: Use MCP or CLI

## Related

- [MCP Server Workflow](./MCPServerWorkflow.md)
- [CLI Tools Workflow](./CLIToolsWorkflow.md)
- [TMDL Scripts](../../Scripts/TMDL/)
