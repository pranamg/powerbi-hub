# ============================================================================
# GGPLOT2 VIOLIN PLOT
# ============================================================================
# Purpose: Show distribution of numeric values by category
# Requirements: ggplot2, dplyr
# Power BI Fields: Category (text), Value (numeric)
# ============================================================================

library(ggplot2)
library(dplyr)

# dataset is automatically created by Power BI
# Assumes: First column = category, Second column = numeric value

# Configuration
FILL_COLOR <- "#118DFF"
LINE_COLOR <- "#333333"
ALPHA <- 0.7
SHOW_BOXPLOT <- TRUE
SHOW_POINTS <- FALSE
TITLE <- "Distribution by Category"

# Get column names
cat_col <- names(dataset)[1]
val_col <- names(dataset)[2]

# Rename for easier use in ggplot
df <- dataset %>%
  rename(category = 1, value = 2)

# Create plot
p <- ggplot(df, aes(x = category, y = value)) +
  
  # Violin layer
  geom_violin(
    fill = FILL_COLOR,
    color = LINE_COLOR,
    alpha = ALPHA,
    trim = FALSE
  )

# Add boxplot inside violin (optional)
if (SHOW_BOXPLOT) {
  p <- p + geom_boxplot(
    width = 0.1,
    fill = "white",
    color = LINE_COLOR,
    outlier.shape = NA
  )
}

# Add jittered points (optional)
if (SHOW_POINTS) {
  p <- p + geom_jitter(
    width = 0.1,
    alpha = 0.3,
    size = 1
  )
}

# Styling
p <- p +
  labs(
    title = TITLE,
    x = cat_col,
    y = val_col
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# Print plot (required for Power BI)
print(p)
