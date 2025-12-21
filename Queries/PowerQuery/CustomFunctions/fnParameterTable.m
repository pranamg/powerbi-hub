// ═══════════════════════════════════════════════════════════════════════════════
// PARAMETER TABLE GENERATOR - Power Query Function
// Creates parameter tables for use in What-If analysis and dynamic filtering
//
// Usage Examples:
//   fnParameterTable(1, 100, 5, "Top N Selection")     -> 1, 6, 11, 16, ... 96
//   fnParameterTable(0.1, 2.0, 0.1, "Growth Rate")     -> 0.1, 0.2, 0.3, ... 2.0
//   fnParameterTable(2020, 2030, 1, "Year Selection")  -> 2020, 2021, ... 2030
// ═══════════════════════════════════════════════════════════════════════════════

let
    fnParameterTable = (MinValue as number, MaxValue as number, Increment as number, ParameterName as text) as table =>
    let
        // Calculate number of steps
        Steps = Number.RoundUp((MaxValue - MinValue) / Increment) + 1,
        
        // Generate list of values
        ValueList = List.Generate(
            () => MinValue,
            each _ <= MaxValue,
            each _ + Increment
        ),
        
        // Convert to table
        ToTable = Table.FromList(ValueList, Splitter.SplitByNothing(), {ParameterName & " Value"}, null, ExtraValues.Error),
        
        // Change type to number
        ChangedType = Table.TransformColumnTypes(ToTable, {{ParameterName & " Value", type number}}),
        
        // Add display column
        AddDisplay = Table.AddColumn(ChangedType, ParameterName, 
            each Text.From(Record.Field(_, ParameterName & " Value")), type text)
        
    in
        AddDisplay,
        
    // Function documentation  
    fnType = type function (
        MinValue as (type number meta [Documentation.FieldCaption = "Minimum Value", Documentation.SampleValues = {1}]),
        MaxValue as (type number meta [Documentation.FieldCaption = "Maximum Value", Documentation.SampleValues = {100}]),
        Increment as (type number meta [Documentation.FieldCaption = "Step Increment", Documentation.SampleValues = {5}]),
        ParameterName as (type text meta [Documentation.FieldCaption = "Parameter Name", Documentation.SampleValues = {"Top N"}])
    ) as table meta [
        Documentation.Name = "fnParameterTable",
        Documentation.Description = "Generates a parameter table for What-If analysis with specified range and increments",
        Documentation.LongDescription = "Creates a two-column table with numeric values and display text. Use with slicers for dynamic parameter selection in DAX measures.",
        Documentation.Category = "Parameter Functions",
        Documentation.Author = "PowerBI-Hub"
    ]
in
    Value.ReplaceType(fnParameterTable, fnType)
