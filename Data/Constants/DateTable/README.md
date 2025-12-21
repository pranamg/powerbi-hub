# Date Table Templates

DAX-based date table generators for Power BI data models.

## Available Templates

| File | Description | Use Case |
|------|-------------|----------|
| `DateTable_Basic.dax` | Standard calendar with common attributes | Simple reports |
| `DateTable_Extended.dax` | Calendar + fiscal year + relative flags | Enterprise reports |
| `DateTable_MultiCalendar.dax` | Multiple calendar systems | Multi-regional, retail |

## Usage

1. Open Power BI Desktop
2. Go to Modeling > New Table
3. Copy/paste the DAX code
4. Modify the `MinDate`/`MaxDate` variables
5. Mark as Date table: Modeling > Mark as Date Table
