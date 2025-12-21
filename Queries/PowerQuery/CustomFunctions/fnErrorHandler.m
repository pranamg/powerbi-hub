// ═══════════════════════════════════════════════════════════════════════════════
// ERROR HANDLER - Power Query Function
// Wraps a function call with try/otherwise error handling
// Returns error details instead of failing the query
//
// Usage: fnErrorHandler(() => SomeFunctionThatMightFail(), "Default Value")
// ═══════════════════════════════════════════════════════════════════════════════

let
    fnErrorHandler = (functionToTry as function, optional defaultValue as any) as any =>
    let
        Result = try functionToTry()
    in
        if Result[HasError] then
            if defaultValue <> null then 
                defaultValue 
            else 
                [
                    HasError = true,
                    ErrorReason = Result[Error][Reason],
                    ErrorMessage = Result[Error][Message],
                    ErrorDetail = Result[Error][Detail]
                ]
        else
            Result[Value],
            
    // Function documentation
    fnType = type function (
        functionToTry as (type function meta [Documentation.FieldCaption = "Function to Execute"]),
        optional defaultValue as (type any meta [Documentation.FieldCaption = "Default Value on Error"])
    ) as any meta [
        Documentation.Name = "fnErrorHandler",
        Documentation.Description = "Executes a function with error handling, returning default value or error details on failure",
        Documentation.Category = "Error Handling",
        Documentation.Author = "PowerBI-Hub"
    ]
in
    Value.ReplaceType(fnErrorHandler, fnType)
