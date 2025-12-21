# Documentation Generation via MCP

> Auto-generate comprehensive model documentation using AI assistants

## Overview

Manual documentation of Power BI semantic models is time-consuming and often outdated. Using the MCP Server, AI can query your model metadata and generate accurate, up-to-date documentation automatically.

## Documentation Types

### 1. Model Overview Document

**Prompt:**
```
"Generate a complete documentation overview of this semantic model including:
- All tables with row counts
- Relationships
- Measure count per table
- Data types summary"
```

**AI generates queries and compiles:**
```dax
-- Get tables
EVALUATE 
ADDCOLUMNS(
    INFO.TABLES(),
    "Row Count", COUNTROWS([Name])
)

-- Get relationships  
EVALUATE INFO.RELATIONSHIPS()

-- Get measures by table
EVALUATE
GROUPBY(
    INFO.MEASURES(),
    [TableID],
    "Measure Count", COUNTX(CURRENTGROUP(), 1)
)
```

**Output:**
```markdown
# Sales Analytics Model Documentation

## Model Statistics
- Tables: 8
- Relationships: 12  
- Total Measures: 47
- Last Refreshed: 2024-12-21

## Tables Overview

| Table | Rows | Type | Description |
|-------|------|------|-------------|
| Sales | 1.2M | Fact | Transaction data |
| Product | 5,420 | Dimension | Product catalog |
| Customer | 89,234 | Dimension | Customer master |
| Date | 3,652 | Dimension | Calendar (10 years) |
| Geography | 195 | Dimension | Region hierarchy |

## Relationship Summary
[Diagram or table of relationships...]
```

### 2. Measure Dictionary

**Prompt:**
```
"Create a complete measure dictionary with categories, 
definitions, and DAX expressions for all measures"
```

**AI queries and organizes:**
```dax
EVALUATE
SELECTCOLUMNS(
    INFO.MEASURES(),
    "Table", [TableID],
    "Measure", [Name],
    "Expression", [Expression],
    "Display Folder", [DisplayFolder],
    "Format String", [FormatString],
    "Description", [Description]
)
```

**Output:**
```markdown
# Measure Dictionary

## Sales Measures

### Total Sales
- **Category:** Base Metrics
- **Format:** Currency
- **Expression:** 
  ```dax
  Total Sales = SUM(Sales[Amount])
  ```
- **Dependencies:** Sales[Amount]
- **Used In:** Dashboard KPIs, Regional Analysis

### Sales YTD
- **Category:** Time Intelligence
- **Format:** Currency
- **Expression:**
  ```dax
  Sales YTD = TOTALYTD([Total Sales], 'Date'[Date])
  ```
- **Dependencies:** [Total Sales], Date[Date]
- **Used In:** Executive Summary, YoY Comparisons

[... continues for all measures ...]
```

### 3. Column Documentation

**Prompt:**
```
"Document all columns in the Customer table including data types,
sample values, and any calculated columns"
```

**AI explores and documents:**
```markdown
# Customer Table Documentation

## Table Overview
- **Row Count:** 89,234
- **Columns:** 15
- **Calculated Columns:** 3
- **Related Tables:** Sales (1:N), Geography (N:1)

## Column Details

### CustomerID
- **Data Type:** Integer
- **Role:** Primary Key
- **Unique Values:** 89,234
- **Sample Values:** 10001, 10002, 10003

### CustomerName
- **Data Type:** Text
- **Max Length:** 100
- **Contains Nulls:** No
- **Sample Values:** "Contoso Ltd", "Adventure Works"

### CustomerSegment (Calculated)
- **Data Type:** Text
- **Expression:**
  ```dax
  CustomerSegment = 
  SWITCH(
      TRUE(),
      Customer[TotalPurchases] > 100000, "Enterprise",
      Customer[TotalPurchases] > 10000, "Mid-Market",
      "SMB"
  )
  ```
- **Distinct Values:** 3
- **Distribution:** Enterprise (5%), Mid-Market (25%), SMB (70%)
```

### 4. Data Lineage Document

**Prompt:**
```
"Generate data lineage documentation showing how measures 
depend on each other and which tables/columns they use"
```

**Output:**
```markdown
# Data Lineage Documentation

## Measure Dependencies

### [Profit Margin %]
```
[Profit Margin %]
├── [Total Profit]
│   ├── [Total Revenue] 
│   │   └── Sales[Amount]
│   └── [Total Cost]
│       └── Sales[Cost]
└── [Total Revenue]
    └── Sales[Amount]
```

### [Customer Lifetime Value]
```
[Customer Lifetime Value]
├── Sales[Amount]
├── Sales[OrderDate]
├── Sales[CustomerID]
└── Customer[CustomerID]
```

## Column Usage Matrix

| Measure | Sales[Amount] | Sales[Date] | Product[Category] | Customer[Segment] |
|---------|--------------|-------------|-------------------|-------------------|
| Total Sales | ✓ | | | |
| Sales by Category | ✓ | | ✓ | |
| Customer Revenue | ✓ | | | ✓ |
| Monthly Trend | ✓ | ✓ | | |
```

### 5. Relationship Documentation

**Prompt:**
```
"Document all relationships including cardinality, 
cross-filter direction, and any inactive relationships"
```

**Output:**
```markdown
# Model Relationships

## Active Relationships

| From Table | From Column | To Table | To Column | Cardinality | Cross-Filter |
|------------|-------------|----------|-----------|-------------|--------------|
| Sales | ProductID | Product | ProductID | Many:1 | Single |
| Sales | CustomerID | Customer | CustomerID | Many:1 | Single |
| Sales | DateKey | Date | DateKey | Many:1 | Single |
| Customer | GeographyID | Geography | GeographyID | Many:1 | Single |

## Inactive Relationships
| From | To | Purpose |
|------|-----|---------|
| Sales[ShipDateKey] | Date[DateKey] | Ship date analysis (use USERELATIONSHIP) |
| Sales[DueDateKey] | Date[DateKey] | Due date analysis (use USERELATIONSHIP) |

## Role-Playing Dimensions
The Date table has 3 relationships to Sales:
1. **OrderDate** (Active) - Default transaction date
2. **ShipDate** (Inactive) - Fulfillment analysis
3. **DueDate** (Inactive) - Receivables analysis
```

## Automated Documentation Workflows

### Weekly Documentation Update

**Prompt:**
```
"Generate a changelog comparing the current model state to last week:
- New measures added
- Modified measure expressions
- New columns or tables
- Changed relationships"
```

### Pre-Deployment Documentation

**Prompt:**
```
"Create deployment documentation for the changes in this model version:
- List all modified objects
- Impact analysis
- Rollback considerations"
```

### Onboarding Guide

**Prompt:**
```
"Create a new user onboarding guide for this model:
- Key business metrics and their definitions
- Most commonly used measures
- Typical analysis patterns
- Filter recommendations"
```

## Export Formats

AI can generate documentation in multiple formats:

### Markdown (Default)
```
"Document all measures in Markdown format"
```

### HTML
```
"Generate an HTML documentation page with navigation"
```

### JSON (for systems integration)
```
"Export measure definitions as JSON for our documentation system"
```

### Wiki Format
```
"Format documentation for Confluence/SharePoint wiki"
```

## Best Practices

### 1. Schedule Regular Updates
```
"Generate updated documentation and highlight what changed 
since the last version from December 1st"
```

### 2. Include Business Context
```
"Document measures with both technical details AND 
business explanations for non-technical users"
```

### 3. Add Usage Examples
```
"For each measure, include 2-3 example use cases 
and recommended visual types"
```

### 4. Cross-Reference Related Items
```
"When documenting a measure, link to related measures 
and the reports that use it"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing descriptions | AI infers from measure names and expressions |
| Complex expressions | Request step-by-step breakdown |
| Large model | Generate documentation in sections |
| Outdated docs | Compare against live model metadata |

## Related Resources

- [TMDL Documentation](../../../Scripts/TMDL/)
- [Model Query Use Cases](./QueryingModels.md)
- [DAX Query View](../../../Documentation/UserGuides/DAXQueryView.md)
