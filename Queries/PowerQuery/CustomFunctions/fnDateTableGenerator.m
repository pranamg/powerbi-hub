// ═══════════════════════════════════════════════════════════════════════════════
// DATE TABLE GENERATOR - Power Query Function
// Creates a comprehensive date dimension table
// 
// Usage: fnDateTableGenerator(#date(2020,1,1), #date(2025,12,31), 7)
// Parameters:
//   StartDate - First date in the table
//   EndDate - Last date in the table  
//   FiscalYearStartMonth - Month when fiscal year begins (1-12)
// ═══════════════════════════════════════════════════════════════════════════════

let
    fnDateTableGenerator = (StartDate as date, EndDate as date, optional FiscalYearStartMonth as number) as table =>
    let
        // Default fiscal year start to July if not specified
        FYStartMonth = if FiscalYearStartMonth = null then 7 else FiscalYearStartMonth,
        
        // Generate list of dates
        DayCount = Duration.Days(EndDate - StartDate) + 1,
        DateList = List.Dates(StartDate, DayCount, #duration(1,0,0,0)),
        
        // Convert to table
        DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
        ChangedType = Table.TransformColumnTypes(DateTable,{{"Date", type date}}),
        
        // Add Calendar Year columns
        AddYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
        AddQuarter = Table.AddColumn(AddYear, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
        AddMonth = Table.AddColumn(AddQuarter, "Month", each Date.Month([Date]), Int64.Type),
        AddDay = Table.AddColumn(AddMonth, "Day", each Date.Day([Date]), Int64.Type),
        
        // Add Month Names
        AddMonthName = Table.AddColumn(AddDay, "MonthName", each Date.MonthName([Date]), type text),
        AddMonthShort = Table.AddColumn(AddMonthName, "MonthShort", each Text.Start(Date.MonthName([Date]), 3), type text),
        
        // Add Day Names
        AddDayOfWeek = Table.AddColumn(AddMonthShort, "DayOfWeek", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
        AddDayName = Table.AddColumn(AddDayOfWeek, "DayName", each Date.DayOfWeekName([Date]), type text),
        AddDayShort = Table.AddColumn(AddDayName, "DayShort", each Text.Start(Date.DayOfWeekName([Date]), 3), type text),
        
        // Add Week Numbers
        AddWeekOfYear = Table.AddColumn(AddDayShort, "WeekOfYear", each Date.WeekOfYear([Date]), Int64.Type),
        AddISOWeek = Table.AddColumn(AddWeekOfYear, "ISOWeek", each Date.WeekOfYear([Date], Day.Monday), Int64.Type),
        
        // Add Quarter Name
        AddQuarterName = Table.AddColumn(AddISOWeek, "QuarterName", each "Q" & Text.From([Quarter]), type text),
        AddYearQuarter = Table.AddColumn(AddQuarterName, "YearQuarter", each Text.From([Year]) & "-Q" & Text.From([Quarter]), type text),
        
        // Add Month-Year combinations
        AddMonthYear = Table.AddColumn(AddYearQuarter, "MonthYear", each [MonthShort] & " " & Text.From([Year]), type text),
        AddYearMonth = Table.AddColumn(AddMonthYear, "YearMonth", each [Year] * 100 + [Month], Int64.Type),
        
        // Add Fiscal Year columns
        AddFiscalYear = Table.AddColumn(AddYearMonth, "FiscalYear", 
            each if [Month] >= FYStartMonth then [Year] + 1 else [Year], Int64.Type),
        AddFiscalYearLabel = Table.AddColumn(AddFiscalYear, "FiscalYearLabel", 
            each "FY" & Text.From([FiscalYear]), type text),
        AddFiscalQuarter = Table.AddColumn(AddFiscalYearLabel, "FiscalQuarter", 
            each Number.RoundUp(Number.Mod([Month] - FYStartMonth + 12, 12) / 3 + 0.01), Int64.Type),
        AddFiscalMonth = Table.AddColumn(AddFiscalQuarter, "FiscalMonth", 
            each Number.Mod([Month] - FYStartMonth + 12, 12) + 1, Int64.Type),
        
        // Add Relative Date Flags
        Today = Date.From(DateTime.LocalNow()),
        AddIsToday = Table.AddColumn(AddFiscalMonth, "IsToday", each [Date] = Today, type logical),
        AddIsCurrentWeek = Table.AddColumn(AddIsToday, "IsCurrentWeek", 
            each Date.WeekOfYear([Date]) = Date.WeekOfYear(Today) and [Year] = Date.Year(Today), type logical),
        AddIsCurrentMonth = Table.AddColumn(AddIsCurrentWeek, "IsCurrentMonth", 
            each [Month] = Date.Month(Today) and [Year] = Date.Year(Today), type logical),
        AddIsCurrentYear = Table.AddColumn(AddIsCurrentMonth, "IsCurrentYear", 
            each [Year] = Date.Year(Today), type logical),
        AddIsPastDate = Table.AddColumn(AddIsCurrentYear, "IsPastDate", each [Date] < Today, type logical),
        
        // Add Weekend Flag
        AddIsWeekend = Table.AddColumn(AddIsPastDate, "IsWeekend", 
            each [DayOfWeek] >= 6, type logical),
        
        // Add Sort Keys
        AddDateKey = Table.AddColumn(AddIsWeekend, "DateKey", 
            each [Year] * 10000 + [Month] * 100 + [Day], Int64.Type),
        AddMonthSort = Table.AddColumn(AddDateKey, "MonthSort", each [Month], Int64.Type),
        
        // Add Display Formats
        AddDateDisplay = Table.AddColumn(AddMonthSort, "DateDisplay", 
            each Text.PadStart(Text.From([Day]), 2, "0") & " " & [MonthShort] & " " & Text.From([Year]), type text)
        
    in
        AddDateDisplay,
        
    // Function documentation
    fnType = type function (
        StartDate as (type date meta [Documentation.FieldCaption = "Start Date", Documentation.SampleValues = {#date(2020,1,1)}]),
        EndDate as (type date meta [Documentation.FieldCaption = "End Date", Documentation.SampleValues = {#date(2025,12,31)}]),
        optional FiscalYearStartMonth as (type number meta [Documentation.FieldCaption = "Fiscal Year Start Month", Documentation.SampleValues = {7}])
    ) as table meta [
        Documentation.Name = "fnDateTableGenerator",
        Documentation.Description = "Generates a comprehensive date dimension table with calendar and fiscal year attributes",
        Documentation.LongDescription = "Creates a date table with standard calendar columns, fiscal year support, relative date flags, and sorting keys. Ideal for time intelligence analysis in Power BI.",
        Documentation.Category = "Date Functions",
        Documentation.Author = "PowerBI-Hub"
    ]
in
    Value.ReplaceType(fnDateTableGenerator, fnType)
