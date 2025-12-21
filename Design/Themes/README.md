# Power BI Themes

JSON theme files for consistent report styling.

## Available Themes

| Theme | Description | Best For |
|-------|-------------|----------|
| `Theme_Corporate_Light.json` | Clean professional light theme | Standard business reports |
| `Theme_Corporate_Dark.json` | Modern dark theme | Executive dashboards, presentations |

## How to Apply

1. Open Power BI Desktop
2. View > Themes > Browse for themes
3. Select the `.json` file
4. Theme is applied immediately

## Theme Contents

Each theme defines:
- **Data colors**: 10 coordinated chart colors
- **Sentiment colors**: Good (green), Neutral (yellow), Bad (red)
- **Background/Foreground**: Page and text colors
- **Visual styles**: Formatting for all visual types
- **Text classes**: Font settings for titles, labels, callouts

## Customization

Edit the JSON to customize:
```json
{
    "name": "Your Custom Theme",
    "dataColors": ["#color1", "#color2", ...],
    "background": "#FFFFFF",
    "foreground": "#333333",
    ...
}
```

## Resources

- [Microsoft Theme Documentation](https://docs.microsoft.com/power-bi/create-reports/desktop-report-themes)
- [Theme Generator Tools](https://powerbi.tips/tools/report-theme-generator-v3/)
