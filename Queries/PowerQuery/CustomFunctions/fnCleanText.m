// ═══════════════════════════════════════════════════════════════════════════════
// TEXT CLEANING FUNCTIONS - Power Query
// Collection of text transformation and cleaning utilities
// ═══════════════════════════════════════════════════════════════════════════════

let
    // Main cleaning function with multiple options
    fnCleanText = (inputText as nullable text, optional options as record) as nullable text =>
    let
        // Default options
        DefaultOptions = [
            TrimSpaces = true,
            RemoveExtraSpaces = true,
            ToProperCase = false,
            ToUpperCase = false,
            ToLowerCase = false,
            RemoveNonPrintable = true,
            RemoveNumbers = false,
            RemoveSpecialChars = false,
            RemoveAccents = false
        ],
        
        // Merge with provided options
        MergedOptions = if options = null then DefaultOptions 
                       else Record.Combine({DefaultOptions, options}),
        
        // Handle null input
        Result = if inputText = null then null else
        let
            // Step 1: Remove non-printable characters
            Step1 = if MergedOptions[RemoveNonPrintable] then
                Text.Select(inputText, {"a".."z", "A".."Z", "0".."9", " ", ".", ",", "-", "_", "@", "#", "$", "%", "&", "(", ")", "+", "=", "/", "\", "'", """", ":", ";", "!", "?", "<", ">", "[", "]", "{", "}", "|", "~", "`", "^"})
            else inputText,
            
            // Step 2: Remove numbers
            Step2 = if MergedOptions[RemoveNumbers] then
                Text.Select(Step1, {"a".."z", "A".."Z", " ", ".", ",", "-", "_"})
            else Step1,
            
            // Step 3: Remove special characters (keep only alphanumeric and spaces)
            Step3 = if MergedOptions[RemoveSpecialChars] then
                Text.Select(Step2, {"a".."z", "A".."Z", "0".."9", " "})
            else Step2,
            
            // Step 4: Trim leading/trailing spaces
            Step4 = if MergedOptions[TrimSpaces] then Text.Trim(Step3) else Step3,
            
            // Step 5: Remove extra spaces (multiple spaces to single)
            Step5 = if MergedOptions[RemoveExtraSpaces] then
                Text.Combine(List.Select(Text.Split(Step4, " "), each _ <> ""), " ")
            else Step4,
            
            // Step 6: Case transformation (only one can be true)
            Step6 = if MergedOptions[ToProperCase] then Text.Proper(Step5)
                   else if MergedOptions[ToUpperCase] then Text.Upper(Step5)
                   else if MergedOptions[ToLowerCase] then Text.Lower(Step5)
                   else Step5
        in
            Step6
    in
        Result,

    // Function documentation
    fnType = type function (
        inputText as (type nullable text meta [Documentation.FieldCaption = "Text to Clean"]),
        optional options as (type record meta [
            Documentation.FieldCaption = "Cleaning Options",
            Documentation.SampleValues = {[TrimSpaces = true, ToProperCase = true]}
        ])
    ) as nullable text meta [
        Documentation.Name = "fnCleanText",
        Documentation.Description = "Cleans and transforms text with configurable options",
        Documentation.LongDescription = "Options: TrimSpaces, RemoveExtraSpaces, ToProperCase, ToUpperCase, ToLowerCase, RemoveNonPrintable, RemoveNumbers, RemoveSpecialChars",
        Documentation.Category = "Text Functions",
        Documentation.Author = "PowerBI-Hub",
        Documentation.Examples = {[
            Description = "Clean and convert to proper case",
            Code = "fnCleanText(""  JOHN   DOE  "", [ToProperCase = true])",
            Result = "John Doe"
        ]}
    ]
in
    Value.ReplaceType(fnCleanText, fnType)
