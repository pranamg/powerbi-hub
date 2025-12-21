// ═══════════════════════════════════════════════════════════════════════════════
// DYNAMIC DATA SOURCE SWITCHER - Power Query Function
// Switches between different data source environments (Dev/Test/Prod)
// 
// Usage: Create a parameter "Environment" with values Dev/Test/Prod
//        Then use: fnDynamicDataSource("MyDatabase", Environment)
// ═══════════════════════════════════════════════════════════════════════════════

let
    // Define your environment configurations here
    EnvironmentConfig = [
        Dev = [
            SQLServer = "dev-server.database.windows.net",
            SQLDatabase = "DevDB",
            SharePointSite = "https://yourcompany.sharepoint.com/sites/dev",
            DataLakePath = "https://devdatalake.dfs.core.windows.net/raw",
            APIBaseUrl = "https://dev-api.yourcompany.com/v1"
        ],
        Test = [
            SQLServer = "test-server.database.windows.net",
            SQLDatabase = "TestDB",
            SharePointSite = "https://yourcompany.sharepoint.com/sites/test",
            DataLakePath = "https://testdatalake.dfs.core.windows.net/raw",
            APIBaseUrl = "https://test-api.yourcompany.com/v1"
        ],
        Prod = [
            SQLServer = "prod-server.database.windows.net",
            SQLDatabase = "ProdDB",
            SharePointSite = "https://yourcompany.sharepoint.com/sites/prod",
            DataLakePath = "https://proddatalake.dfs.core.windows.net/raw",
            APIBaseUrl = "https://api.yourcompany.com/v1"
        ]
    ],
    
    fnDynamicDataSource = (ResourceType as text, Environment as text) as text =>
    let
        // Get the environment record
        EnvRecord = Record.Field(EnvironmentConfig, Environment),
        
        // Get the specific resource
        ResourceValue = Record.Field(EnvRecord, ResourceType)
    in
        ResourceValue,
        
    // Function documentation
    fnType = type function (
        ResourceType as (type text meta [
            Documentation.FieldCaption = "Resource Type",
            Documentation.AllowedValues = {"SQLServer", "SQLDatabase", "SharePointSite", "DataLakePath", "APIBaseUrl"}
        ]),
        Environment as (type text meta [
            Documentation.FieldCaption = "Environment",
            Documentation.AllowedValues = {"Dev", "Test", "Prod"}
        ])
    ) as text meta [
        Documentation.Name = "fnDynamicDataSource",
        Documentation.Description = "Returns the appropriate data source connection string based on environment",
        Documentation.LongDescription = "Use this function to dynamically switch between Dev/Test/Prod environments without changing query code. Configure your connection strings in the EnvironmentConfig record.",
        Documentation.Category = "Configuration",
        Documentation.Author = "PowerBI-Hub",
        Documentation.Examples = {[
            Description = "Get production SQL Server name",
            Code = "fnDynamicDataSource(""SQLServer"", ""Prod"")",
            Result = "prod-server.database.windows.net"
        ]}
    ]
in
    Value.ReplaceType(fnDynamicDataSource, fnType)
