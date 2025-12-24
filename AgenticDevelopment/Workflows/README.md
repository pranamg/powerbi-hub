# Professional Workflows for Agentic Development

> Enterprise-ready development patterns for AI-assisted semantic modeling

## Overview

There are three primary workflows for agentic development of semantic models. Each has pros and cons, and effective development often combines all three.

## Workflow Comparison

| Workflow | Best For | Pros | Cons |
|----------|----------|------|------|
| **Direct TMDL** | Search, simple edits | Fast, source control | Fragile, no validation |
| **MCP Server** | Bulk operations | Validated, efficient | Context heavy, rigid |
| **CLI Tools** | Automation, CI/CD | Flexible, deterministic | Setup complexity |

## Choosing the Right Workflow

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │ What type of  │
              │   operation?  │
              └───────┬───────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   ┌─────────┐  ┌──────────┐  ┌──────────┐
   │ Search/ │  │  Bulk    │  │ Automated│
   │ Simple  │  │  Create/ │  │ Pipeline │
   │  Edit   │  │  Update  │  │   Task   │
   └────┬────┘  └────┬─────┘  └────┬─────┘
        │            │             │
        ▼            ▼             ▼
   ┌─────────┐  ┌──────────┐  ┌──────────┐
   │  Direct │  │   MCP    │  │   CLI    │
   │  TMDL   │  │  Server  │  │  Tools   │
   └─────────┘  └──────────┘  └──────────┘
```

## Combined Workflow (Recommended)

The most effective approach combines all three methods:

```
┌────────────────────────────────────────────────────────────────┐
│                   COMBINED WORKFLOW                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. EXPLORE (Direct TMDL)                                      │
│     └─ Agent searches model files                              │
│     └─ Fast, efficient token usage                             │
│                                                                 │
│  2. MODIFY (MCP Server)                                        │
│     └─ Agent uses MCP tools for bulk changes                   │
│     └─ Validation ensures valid changes                        │
│                                                                 │
│  3. VALIDATE (CLI Tools)                                       │
│     └─ Run BPA via TabularEditor.exe                           │
│     └─ Deploy to test workspace                                │
│                                                                 │
│  4. COMMIT (Direct TMDL)                                       │
│     └─ Review changes in TMDL files                            │
│     └─ Commit to source control                                │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

## Workflow Documentation

| Document | Description |
|----------|-------------|
| [Direct Metadata Modification](./DirectMetadataModification.md) | Working with TMDL files directly |
| [MCP Server Workflow](./MCPServerWorkflow.md) | Using MCP servers for bulk operations |
| [CLI Tools Workflow](./CLIToolsWorkflow.md) | Tabular Editor CLI with agents |

## Enterprise Patterns

### Pattern 1: Feature Branch Development

```
1. Create feature branch
2. Agent explores and modifies model
3. Agent runs validation (BPA)
4. Human reviews changes in PR
5. Automated deployment to dev workspace
6. Human validates in Power BI
7. Merge to main
8. Deploy to production
```

### Pattern 2: Sandbox Testing

```
1. Agent makes changes to local TMDL
2. CLI deploys to sandbox workspace
3. Agent runs test queries
4. If tests pass:
   └─ Commit changes
   └─ Human reviews
5. If tests fail:
   └─ Agent adjusts and retries
```

### Pattern 3: Documentation Sprint

```
1. Agent reads all measures
2. For each measure:
   └─ Analyze DAX
   └─ Generate description
   └─ Update via MCP
3. Human reviews generated docs
4. Bulk approve/reject
5. Commit approved descriptions
```

## Security Considerations

### Data Access

| Workflow | Data Exposure Risk |
|----------|-------------------|
| Direct TMDL | Low (metadata only) |
| MCP Server | Medium (can query data) |
| CLI Tools | Medium (depends on script) |

### Best Practices

1. **Use approved enterprise AI tools** - Verify terms of service
2. **Work on sandboxed copies** - Never let agents modify production
3. **Review all changes** - Human validation before deployment
4. **Source control everything** - Enable audit and rollback
5. **Limit permissions** - Agents should have minimal required access

## Context File Standards

### Required Files

```
project-root/
├── AGENTS.md           # Universal agent instructions
├── CLAUDE.md           # Claude-specific instructions (if using Claude)
├── .cursorrules        # Cursor-specific rules (if using Cursor)
└── context/
    ├── model-overview.md
    ├── dax-conventions.md
    └── naming-standards.md
```

### AGENTS.md Template

```markdown
# Agent Instructions for [Model Name]

## Model Overview
[Brief description of the model's purpose]

## Tables
[Key tables and their purposes]

## Conventions
### Naming
- Tables: PascalCase, singular
- Measures: [Table] Measure Name
- Columns: PascalCase

### DAX
- Use DIVIDE() over /
- Use variables for clarity
- Format with standard indentation

## Forbidden Operations
- Never delete without confirmation
- Never modify partition queries
- Never change relationships without review

## Workflow
1. Search before modifying
2. Validate DAX before creating measures
3. Run BPA after changes
4. Commit with descriptive messages
```

## Measuring Success

### Metrics to Track

| Metric | Description |
|--------|-------------|
| Time saved | Hours saved vs manual approach |
| Error rate | Invalid changes caught before commit |
| Rework rate | Changes that needed human correction |
| Context iterations | Improvements needed to AGENTS.md |

### Quality Gates

- [ ] All BPA rules pass
- [ ] No DAX syntax errors
- [ ] All new measures have descriptions
- [ ] Naming conventions followed
- [ ] Human review completed
