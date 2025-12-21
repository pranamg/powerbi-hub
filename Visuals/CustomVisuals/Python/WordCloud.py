# ============================================================================
# WORD CLOUD VISUALIZATION
# ============================================================================
# Purpose: Create word cloud from text data
# Requirements: pandas, matplotlib, wordcloud
# Power BI Fields: Text column (words/phrases)
# ============================================================================

import pandas as pd
import matplotlib.pyplot as plt
from wordcloud import WordCloud, STOPWORDS

# dataset is automatically created by Power BI
# Assumes first column contains text data

# Configuration
FIGSIZE = (12, 8)
BACKGROUND_COLOR = 'white'
MAX_WORDS = 200
WIDTH = 1600
HEIGHT = 800
COLORMAP = 'viridis'  # Options: viridis, plasma, Blues, Greens, Reds
REMOVE_STOPWORDS = True

# Get text column (first text column in dataset)
text_col = dataset.select_dtypes(include=['object']).columns[0]

# Combine all text
text = ' '.join(dataset[text_col].dropna().astype(str))

# Configure stopwords
stopwords = set(STOPWORDS) if REMOVE_STOPWORDS else set()

# Add custom stopwords if needed
custom_stopwords = {'said', 'will', 'also', 'one', 'two', 'make', 'made'}
stopwords.update(custom_stopwords)

# Create word cloud
wordcloud = WordCloud(
    width=WIDTH,
    height=HEIGHT,
    background_color=BACKGROUND_COLOR,
    max_words=MAX_WORDS,
    stopwords=stopwords,
    colormap=COLORMAP,
    collocations=False,  # Avoid repeated phrases
    random_state=42
).generate(text)

# Create figure
fig, ax = plt.subplots(figsize=FIGSIZE)

# Display word cloud
ax.imshow(wordcloud, interpolation='bilinear')
ax.axis('off')

# Tight layout
plt.tight_layout(pad=0)

# Show plot
plt.show()
