# TMDL View User Guide

> **TMDL View** is a built-in code editor in Power BI Desktop for viewing and editing your semantic model as text-based TMDL (Tabular Model Definition Language).

## Overview

TMDL View was introduced in Power BI Desktop and became Generally Available (GA) in **September 2024**. It allows you to:

- View model definitions as readable text
- Edit tables, columns, measures, and relationships as code
- Copy and paste model objects between files
- Use familiar code editing features (IntelliSense, search, etc.)
- Compare changes using diff view

## Enabling TMDL View

### For GA Version (September 2024+)
TMDL View is enabled by default in Power BI Desktop versions from September 2024 onwards.

### For Earlier Versions
1. Open **Power BI Desktop**
2. Go to **File > Options and Settings > Options**
3. Navigate to **Preview features**
4. Check **TMDL View**
5. Click **OK** and restart Power BI Desktop

## Accessing TMDL View

### Method 1: From the View Menu
1. Open your .pbix file
2. Click **View** in the ribbon
3. Select **TMDL View**

### Method 2: From Model View
1. Switch to **Model view** (data model diagram)
2. Look for **TMDL View** button in the ribbon

### Method 3: Keyboard Shortcut
- Press `Ctrl + Alt + T` to toggle TMDL View

## Interface Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ Explorer Panel    │    Code Editor                              │
│                   │                                             │
│ 📁 Model          │  table Sales                                │
│   📄 definition   │      lineageTag: abc123                     │
│   📄 model        │                                             │
│   📁 tables       │      column 'Sales Amount'                  │
│     📄 Sales      │          dataType: decimal                  │
│     📄 Products   │          formatString: $#,##0.00            │
│     📄 Date       │                                             │
│   📁 roles        │      measure 'Total Sales' =                │
│   📄 relationships│          SUM(Sales[Sales Amount])           │
│                   │                                             │
└─────────────────────────────────────────────────────────────────┘
```

### Explorer Panel
- **Folder structure** mirroring TMDL organization
- **Tables folder** - One file per table
- **Roles folder** - Security roles
- **Relationships file** - All relationships
- Click any file to open in editor

### Code Editor
- Full-featured text editor
- Syntax highlighting for TMDL
- IntelliSense code completion
- Line numbers and code folding
- Find and replace (`Ctrl+F`, `Ctrl+H`)

## Common Workflows

### 1. Viewing a Table Definition

1. Expand **tables** folder in Explorer
2. Click on a table name (e.g., `Sales`)
3. View complete table definition including columns, measures, hierarchies

### 2. Adding a New Measure

```tmdl
// In the table's TMDL file, add:

measure 'Sales YTD' = 
    CALCULATE(
        [Total Sales],
        DATESYTD('Date'[Date])
    )
    formatString: $#,##0.00
    displayFolder: Time Intelligence
    lineageTag: new-measure-001
```

**Important:** LineageTags are auto-generated. You can leave them out and Power BI will create them.

### 3. Editing Column Properties

```tmdl
// Find the column and modify properties:

column 'Product Name'
    dataType: string
    summarizeBy: none
    isHidden: false                // Show/hide column
    displayFolder: Product Info    // Organize in folders
    description: "Name of product" // Add documentation
```

### 4. Creating a Calculated Column

```tmdl
column 'Profit Margin' = 
    DIVIDE(
        Sales[Profit],
        Sales[Revenue]
    )
    dataType: decimal
    formatString: 0.0%
    displayFolder: Calculations
```

### 5. Defining a Relationship

Open `relationships.tmdl` and add:

```tmdl
relationship rel_Sales_to_Products
    fromColumn: Sales.ProductID
    toColumn: Products.ProductID
    isActive: true
    crossFilteringBehavior: singleDirection
```

### 6. Adding Row-Level Security

Create or edit a role file in the `roles` folder:

```tmdl
role RegionalSales
    modelPermission: read
    
    tablePermission Sales = 
        Sales[Region] = USERPRINCIPALNAME()
```

## Code Editor Features

### IntelliSense
- Press `Ctrl+Space` for suggestions
- Auto-completes keywords, table names, column names
- Shows DAX function signatures

### Find and Replace
- `Ctrl+F` - Find
- `Ctrl+H` - Replace
- Supports regex patterns

### Code Folding
- Click `-` next to line numbers to collapse sections
- Collapse table definitions for overview

### Multi-cursor Editing
- `Alt+Click` to add cursors
- Edit multiple lines simultaneously

### Go to Definition
- `Ctrl+Click` on referenced objects
- Jump to table/column definitions

## Drag-and-Drop Scripting

TMDL View supports drag-and-drop from the model:

1. Open TMDL View alongside Model View
2. Drag a table from Model View
3. Drop into TMDL editor
4. Table definition is inserted as text

## Diff View (Comparing Changes)

When you make changes in TMDL View:

1. Changes are tracked automatically
2. View changes before applying
3. Compare original vs modified code
4. Accept or reject changes

### Viewing Pending Changes
1. Look for change indicators in Explorer (● symbol)
2. Click to see diff view
3. Red = removed, Green = added

## Synchronization

### TMDL View ↔ Model View
- Changes in TMDL View reflect in Model View
- Changes in Model View reflect in TMDL View
- Real-time synchronization

### Validation
- Syntax errors shown with red underlines
- Error messages in Problems panel
- Must fix errors before closing TMDL View

## Best Practices

### 1. Use for Bulk Edits
TMDL View excels at:
- Adding multiple measures at once
- Copying measure patterns
- Bulk property changes (format strings, display folders)

### 2. Leverage Find/Replace
- Rename measures across entire model
- Update format strings consistently
- Change display folder organization

### 3. Document with Descriptions
```tmdl
measure 'Revenue' = SUM(Sales[Amount])
    description: "Total revenue from all sales. Excludes returns."
```

### 4. Organize with Display Folders
```tmdl
measure 'Sales YTD' = ...
    displayFolder: Time Intelligence\Year
    
measure 'Sales QTD' = ...
    displayFolder: Time Intelligence\Quarter
```

### 5. Copy from Templates
- Keep a library of measure templates
- Copy/paste from external TMDL files
- Standardize patterns across projects

## Limitations

1. **Cannot create new tables** - Use Power Query for data import
2. **Partition definitions** - M queries are view-only
3. **Some validations** - Complex DAX errors may only appear on save
4. **File encoding** - Always UTF-8

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+T` | Toggle TMDL View |
| `Ctrl+S` | Save changes |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |
| `Ctrl+Space` | IntelliSense |
| `Ctrl+/` | Comment/Uncomment |
| `Ctrl+D` | Duplicate line |
| `Alt+Up/Down` | Move line |
| `Ctrl+G` | Go to line |
| `Ctrl+Shift+K` | Delete line |

## Troubleshooting

### Changes Not Applying
- Check for validation errors (red underlines)
- Save the file (`Ctrl+S`)
- If errors persist, check DAX syntax

### IntelliSense Not Working
- Ensure model is loaded completely
- Try `Ctrl+Space` to trigger manually
- Restart Power BI Desktop if persistent

### Performance Issues
- Large models may take time to load
- Consider splitting into smaller files
- Close unused tabs

## External Tools Integration

TMDL View works well with:
- **Tabular Editor** - Advanced model editing
- **VS Code** - External TMDL editing
- **Git** - Version control for TMDL folders

### Export for External Editing
1. Save your .pbix file
2. Use **pbi-tools** to extract TMDL
3. Edit in VS Code or other editors
4. Import back using pbi-tools

## Resources

- [TMDL View Documentation](https://learn.microsoft.com/power-bi/transform-model/desktop-tmdl-view)
- [TMDL Language Reference](https://learn.microsoft.com/analysis-services/tmdl/tmdl-overview)
- [Power BI Blog - TMDL Announcements](https://powerbi.microsoft.com/blog/)

---

*Last Updated: December 2024*
