# Data Exploration Workflows

> Interactive data analysis and discovery using AI assistants with MCP

## Overview

Data exploration is one of the most powerful use cases for MCP. AI assistants can help you understand unfamiliar datasets, discover patterns, and answer ad-hoc business questions without writing DAX.

## Exploration Workflows

### Workflow 1: Dataset Discovery

**Starting Point:** You have access to a model but don't know its structure.

**Conversation:**
```
User: "I'm new to this model. Give me an overview of what data is available."

AI via MCP:
- Queries INFO.TABLES() for all tables
- Gets row counts and column info
- Identifies fact vs dimension tables
- Returns structured overview

AI Response:
"This is a retail sales model with 8 tables:
- Sales (1.2M rows) - main fact table with transactions
- Product (5,420 products in 12 categories)
- Customer (89K customers)
- Date (10-year calendar)
- Geography (195 regions)
- Store (150 locations)
- Employee (2,800 records)
- Promotions (340 campaigns)

The primary analysis grain is daily sales by product, customer, and store."
```

### Workflow 2: Pattern Discovery

**Scenario:** Finding trends and anomalies in data.

**Prompt:**
```
"Analyze sales patterns and identify any unusual trends or anomalies 
in the last 6 months"
```

**AI Exploration Steps:**
1. Query monthly sales trend
2. Calculate month-over-month changes
3. Identify statistical outliers
4. Investigate anomalies by dimension

**Queries Executed:**
```dax
-- Monthly trend
EVALUATE
SUMMARIZECOLUMNS(
    'Date'[Year Month],
    "Sales", [Total Sales],
    "MoM Change", [Sales MoM %]
)
ORDER BY 'Date'[Year Month]

-- Outlier detection
EVALUATE
VAR AvgSales = AVERAGEX(VALUES('Date'[Year Month]), [Total Sales])
VAR StdDev = STDEVX.P(VALUES('Date'[Year Month]), [Total Sales])
RETURN
FILTER(
    ADDCOLUMNS(
        VALUES('Date'[Year Month]),
        "Sales", [Total Sales],
        "Z-Score", DIVIDE([Total Sales] - AvgSales, StdDev)
    ),
    ABS([Z-Score]) > 2
)
```

**AI Response:**
```
Anomalies Detected:
1. November 2024 - Sales 47% above average (Black Friday effect)
2. February 2024 - Sales 23% below average (inventory shortage)
3. August 2024 - Unusual spike in Electronics (+89%)

Recommendation: Investigate August Electronics surge - 
possible data quality issue or promotional event.
```

### Workflow 3: Segment Analysis

**Prompt:**
```
"Help me understand our customer segments. 
Who are our best customers and what do they buy?"
```

**AI Analysis:**
```dax
-- Customer value distribution
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        Sales,
        'Customer'[CustomerID],
        'Customer'[CustomerName],
        'Customer'[Segment]
    ),
    "Total Purchases", [Total Sales],
    "Order Count", [Order Count],
    "Avg Order Value", DIVIDE([Total Sales], [Order Count]),
    "First Purchase", MIN(Sales[OrderDate]),
    "Last Purchase", MAX(Sales[OrderDate])
)
ORDER BY [Total Purchases] DESC

-- Top customer product preferences
EVALUATE
VAR TopCustomers = 
    TOPN(100, VALUES('Customer'[CustomerID]), [Total Sales])
RETURN
SUMMARIZECOLUMNS(
    'Product'[Category],
    TREATAS(TopCustomers, 'Customer'[CustomerID]),
    "Sales", [Total Sales],
    "% of Total", DIVIDE([Total Sales], CALCULATE([Total Sales], ALL('Product')))
)
```

**AI Response:**
```markdown
## Customer Segment Analysis

### High-Value Customers (Top 10%)
- 8,923 customers generating 67% of revenue
- Average order value: $847 (vs $124 overall)
- Primary categories: Electronics (42%), Appliances (28%)
- 78% retention rate (purchased in last 90 days)

### Growth Opportunity: Mid-Tier Segment
- 23,456 customers with $500-$2000 lifetime value
- Potential for upgrade with targeted promotions
- Under-index in Electronics - opportunity for cross-sell
```

### Workflow 4: Root Cause Analysis

**Prompt:**
```
"Sales are down 15% this quarter. Help me understand why."
```

**AI Investigation:**
```dax
-- Compare quarters by dimension
EVALUATE
SUMMARIZECOLUMNS(
    'Product'[Category],
    "Current Qtr", [Sales This Quarter],
    "Prior Qtr", [Sales Last Quarter],
    "Change", [Sales This Quarter] - [Sales Last Quarter],
    "Change %", DIVIDE([Sales This Quarter] - [Sales Last Quarter], [Sales Last Quarter])
)
ORDER BY [Change]

-- Drill into worst performer
EVALUATE
SUMMARIZECOLUMNS(
    'Product'[SubCategory],
    'Date'[Month],
    "Sales", [Total Sales]
)
FILTER 'Product'[Category] = "Electronics"
```

**AI Response:**
```markdown
## Root Cause Analysis: Q4 Sales Decline

### Primary Driver (accounts for 80% of decline)
**Electronics category down 34%**
- Laptops: -45% (supply chain issues)
- Phones: -28% (competitor launch)
- Accessories: +12% (offset)

### Secondary Factors
- North region: -22% (store closures)
- Online channel: -8% (website migration)

### Recommendations
1. Address laptop supply chain with alternative vendors
2. Launch competitive phone promotion
3. Investigate North region store performance
```

### Workflow 5: Correlation Discovery

**Prompt:**
```
"Are there any interesting correlations between product categories?
What products are frequently bought together?"
```

**AI Analysis:**
```dax
-- Market basket analysis
EVALUATE
VAR OrderProducts = 
    SUMMARIZE(
        Sales,
        Sales[OrderID],
        'Product'[Category]
    )
RETURN
CROSSJOIN(
    DISTINCT('Product'[Category]),
    DISTINCT('Product'[Category])
)
-- Correlation calculation...
```

**AI Response:**
```markdown
## Product Correlation Analysis

### Strong Positive Correlations
| Product A | Product B | Correlation | Insight |
|-----------|-----------|-------------|---------|
| Laptop | Accessories | 0.82 | Bundle opportunity |
| Coffee Maker | Coffee | 0.78 | Consumables tie-in |
| Phone | Phone Case | 0.91 | Add-on recommendation |

### Recommendation
Create bundle offers:
- Laptop + Mouse + Bag (save 15%)
- Coffee Maker + 3-month coffee subscription
```

## Interactive Analysis Sessions

### Guided Exploration

**Prompt:**
```
"Let's explore this data together. Start by showing me 
the most important KPIs and I'll tell you what to drill into."
```

**AI shows summary, then:**
```
User: "That profit margin looks low. Break it down."
AI: [Queries profit by category]

User: "Why is Apparel margin so low?"
AI: [Drills into Apparel subcategories]

User: "Compare that to last year"
AI: [Adds YoY comparison]

User: "Which stores are struggling?"
AI: [Filters to Apparel, shows by store]
```

### Hypothesis Testing

**Prompt:**
```
"I think our promotions aren't working. Can you test this hypothesis?"
```

**AI generates test:**
```dax
-- Compare promotional vs non-promotional sales
EVALUATE
ROW(
    "Avg Sale (Promo)", 
    CALCULATE([Avg Order Value], 'Sales'[IsPromotion] = TRUE()),
    "Avg Sale (Non-Promo)", 
    CALCULATE([Avg Order Value], 'Sales'[IsPromotion] = FALSE()),
    "Margin (Promo)", 
    CALCULATE([Profit Margin %], 'Sales'[IsPromotion] = TRUE()),
    "Margin (Non-Promo)", 
    CALCULATE([Profit Margin %], 'Sales'[IsPromotion] = FALSE())
)
```

**AI Conclusion:**
```
Hypothesis: "Promotions aren't working"
Finding: PARTIALLY SUPPORTED

- Promotional orders: 23% higher volume
- But: 8% lower margin
- Net impact: +$2.3M revenue, -$180K profit

Recommendation: Review discount depth - 
current 25% average discount is too aggressive.
```

## Best Practices

### 1. Start Broad, Then Narrow
```
"Show me the big picture" → "Drill into region X" → "Why is store Y different?"
```

### 2. Ask for Comparisons
```
"How does this compare to last year/budget/benchmark?"
```

### 3. Request Visualizations
```
"What's the best way to visualize this trend?"
```

### 4. Save Interesting Queries
```
"Save this query for our weekly analysis"
```

## Related Resources

- [Querying Models](./QueryingModels.md)
- [Report Analysis](./ReportAnalysis.md)
- [Window Functions](../../../Queries/DAX/Measures/WindowFunctions.dax)
