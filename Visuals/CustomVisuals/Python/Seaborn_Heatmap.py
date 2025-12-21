# ============================================================================
# SEABORN CORRELATION HEATMAP
# ============================================================================
# Purpose: Create correlation heatmap for numeric columns
# Requirements: pandas, seaborn, matplotlib
# Power BI Fields: Add multiple numeric columns to the visual
# ============================================================================

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# dataset is automatically created by Power BI from the fields you add
# Each column added to the visual becomes a column in the dataset

# Configuration
FIGSIZE = (10, 8)
COLORMAP = 'RdBu_r'  # Red-Blue diverging palette
ANNOTATION = True     # Show correlation values
DECIMAL_PLACES = 2
TITLE = 'Correlation Heatmap'

# Calculate correlation matrix
# Only numeric columns will work
numeric_cols = dataset.select_dtypes(include=['float64', 'int64']).columns
corr_matrix = dataset[numeric_cols].corr()

# Create figure
fig, ax = plt.subplots(figsize=FIGSIZE)

# Create heatmap
sns.heatmap(
    corr_matrix,
    annot=ANNOTATION,
    fmt=f'.{DECIMAL_PLACES}f',
    cmap=COLORMAP,
    center=0,
    square=True,
    linewidths=0.5,
    cbar_kws={'shrink': 0.8, 'label': 'Correlation'},
    ax=ax
)

# Styling
ax.set_title(TITLE, fontsize=14, fontweight='bold', pad=20)
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)

# Tight layout
plt.tight_layout()

# Show plot (required for Power BI)
plt.show()
