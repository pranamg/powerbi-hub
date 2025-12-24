# Semantic Model Agents

> Understanding agents that query vs agents that modify semantic models

## Two Types of Semantic Model Agents

### Query Agents (Consumption)

Query agents explore metadata and generate queries to retrieve information and answer user data questions. This is **conversational BI**.

```
┌─────────────────────────────────────────────────┐
│                 Query Agent                      │
├─────────────────────────────────────────────────┤
│  User: "What were sales last quarter?"          │
│                    ↓                             │
│  Agent: Generates DAX query                     │
│         EVALUATE SUMMARIZECOLUMNS(...)          │
│                    ↓                             │
│  Result: Table with sales data                  │
└─────────────────────────────────────────────────┘
```

**Examples:**
- Copilot in Power BI ("Ask data questions")
- Data agents in Microsoft Fabric
- Custom chatbots with semantic model context

**Capabilities:**
- Read model metadata (tables, columns, measures)
- Generate DAX queries
- Execute queries against the model
- Present results in natural language

### Modify Agents (Development)

Modify agents read and modify semantic model metadata, either directly or programmatically. This is **agentic development**.

```
┌─────────────────────────────────────────────────┐
│                Modify Agent                      │
├─────────────────────────────────────────────────┤
│  User: "Add YTD measures for all revenue KPIs" │
│                    ↓                             │
│  Agent: Searches model for revenue measures     │
│         Creates new YTD versions                │
│         Updates TMDL files or uses MCP          │
│                    ↓                             │
│  Result: Modified model metadata                │
└─────────────────────────────────────────────────┘
```

**Examples:**
- Claude Code with MCP server
- GitHub Copilot editing TMDL files
- Scripts executed by agents via CLI

**Capabilities:**
- Read and write model metadata
- Create, modify, delete model objects
- Deploy models to workspaces
- Execute validation scripts

## Comparison

| Aspect | Query Agent | Modify Agent |
|--------|-------------|--------------|
| **Purpose** | Answer data questions | Change model structure |
| **Risk Level** | Low (read-only) | High (can break model) |
| **Validation** | Query results | Tabular Editor, BPA |
| **Typical User** | Business users | Developers |
| **Requires** | Published model | Local metadata |

## Query Agent Patterns

### Pattern 1: Direct Query

User asks a question, agent generates and runs DAX:

```
User: "Show me top 10 products by revenue"

Agent generates:
EVALUATE
TOPN(
    10,
    SUMMARIZECOLUMNS(
        Products[ProductName],
        "Revenue", [Total Revenue]
    ),
    [Revenue], DESC
)
```

### Pattern 2: Metadata Exploration

User asks about the model structure:

```
User: "What measures are in the Sales table?"

Agent reads metadata and responds:
The Sales table contains 12 measures:
- Total Revenue
- Total Cost
- Gross Profit
- Gross Margin %
...
```

### Pattern 3: Guided Analysis

Agent suggests relevant questions based on data:

```
Agent: Based on your Sales model, you might want to explore:
1. Revenue trends over time
2. Top performing regions
3. Product category analysis
4. Customer segmentation
```

## Modify Agent Patterns

### Pattern 1: Bulk Operations

Agent makes the same change to many objects:

```
User: "Add format strings to all currency measures"

Agent:
1. Searches for measures with "Revenue", "Cost", "Price", "Amount"
2. For each measure, sets FormatString = "$#,##0.00"
3. Reports: Updated 47 measures
```

### Pattern 2: Refactoring

Agent restructures existing DAX:

```
User: "Refactor all measures to use DIVIDE instead of /"

Agent:
1. Searches for pattern: ] / [
2. Identifies 23 potential candidates
3. For each, rewrites as DIVIDE(numerator, denominator, 0)
4. Shows diff for approval
```

### Pattern 3: Generation

Agent creates new objects based on patterns:

```
User: "Create time intelligence measures for [Total Sales]"

Agent creates:
- [Total Sales YTD]
- [Total Sales MTD]
- [Total Sales QTD]
- [Total Sales PY]
- [Total Sales YoY %]
```

### Pattern 4: Documentation

Agent generates descriptions and documentation:

```
User: "Document all measures in the Finance folder"

Agent:
1. Reads each measure's DAX
2. Generates description explaining:
   - What the measure calculates
   - Key dependencies
   - Business context
3. Updates Description property via MCP or TMDL
```

## Hybrid Workflows

Many scenarios benefit from both query and modify capabilities:

### Scenario: Performance Optimization

```
1. Query Agent: "Which measures are slowest?"
   → Runs performance queries, identifies bottlenecks

2. Modify Agent: "Optimize the [Complex Calculation] measure"
   → Refactors DAX for better performance

3. Query Agent: "Compare before/after performance"
   → Validates improvement
```

### Scenario: Model Validation

```
1. Modify Agent: Deploy model to dev workspace (CLI)

2. Query Agent: Run test queries to validate calculations

3. Modify Agent: Fix any issues found

4. Modify Agent: Deploy to production (if tests pass)
```

## Security Considerations

### Query Agents

- Lower risk (read-only)
- Still need data access governance
- May expose sensitive information in responses
- Consider row-level security implications

### Modify Agents

- Higher risk (can break models)
- Need clear permission boundaries
- Always use source control
- Require human validation before deployment
- Consider using sandboxed workspaces

## Choosing the Right Agent Type

| Scenario | Agent Type |
|----------|------------|
| Ad-hoc data questions | Query |
| Model documentation | Either (read) or Modify (write) |
| Measure creation | Modify |
| Performance analysis | Query → Modify |
| Model deployment | Modify |
| Data exploration | Query |
| DAX refactoring | Modify |
| Compliance reporting | Query |
