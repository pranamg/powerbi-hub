# Row-Level Security (RLS) Patterns

> Common patterns and best practices for implementing RLS in Power BI

## Overview

Row-Level Security restricts data access at the row level based on user identity. This guide covers common patterns and implementation strategies.

## Basic Patterns

### 1. Direct User Filter

Filter based on user's email matching a column:

```dax
// Role: Regional Manager
// Table: Sales

[RegionalManagerEmail] = USERPRINCIPALNAME()
```

**Use Case:** Each manager sees only their assigned data.

### 2. Username-Based Filter

```dax
// Role: Employee Data Access
// Table: Employee

[Username] = USERNAME()
```

**Note:** `USERNAME()` returns `DOMAIN\user`, `USERPRINCIPALNAME()` returns `user@domain.com`.

### 3. Department/Region Filter

```dax
// Role: Sales Team
// Table: Geography

[Region] IN {"North", "South"}
```

**Use Case:** Static role for specific regions.

## Dynamic RLS Patterns

### 4. Security Table Pattern

Create a security mapping table:

```
UserSecurity Table:
| UserEmail              | Region    |
|------------------------|-----------|
| john@company.com       | North     |
| john@company.com       | South     |
| sarah@company.com      | East      |
```

DAX Filter (on Geography):
```dax
[Region] IN 
CALCULATETABLE(
    VALUES(UserSecurity[Region]),
    UserSecurity[UserEmail] = USERPRINCIPALNAME()
)
```

### 5. Manager Hierarchy Pattern

Managers see their team and all subordinates:

```
EmployeeHierarchy Table:
| EmployeeID | ManagerID | ManagerEmail         |
|------------|-----------|---------------------|
| 1001       | 1000      | boss@company.com    |
| 1002       | 1000      | boss@company.com    |
| 1003       | 1001      | mid@company.com     |
```

DAX Filter (on Employee):
```dax
VAR CurrentUser = USERPRINCIPALNAME()
VAR UserEmployeeID = 
    LOOKUPVALUE(
        Employee[EmployeeID],
        Employee[Email],
        CurrentUser
    )
RETURN
PATHCONTAINS(Employee[ManagerPath], UserEmployeeID)
```

**Note:** `ManagerPath` is a PATH column built using `PATH(EmployeeID, ManagerID)`.

### 6. Multi-Tenant Pattern

For SaaS or multi-company scenarios:

```dax
// Role: Tenant User
// Table: Company

[CompanyID] = 
LOOKUPVALUE(
    UserTenant[CompanyID],
    UserTenant[UserEmail],
    USERPRINCIPALNAME()
)
```

### 7. Date-Based Access

Limit access to recent data:

```dax
// Role: Limited History
// Table: Sales

[OrderDate] >= DATE(2023, 1, 1)
```

Or dynamically:
```dax
// Last 2 years only
[OrderDate] >= DATE(YEAR(TODAY()) - 2, 1, 1)
```

### 8. Combination Pattern

Multiple security dimensions:

```dax
// Role: Regional + Product Access
// Table: Sales

VAR CurrentUser = USERPRINCIPALNAME()
VAR AllowedRegions = 
    CALCULATETABLE(
        VALUES(UserAccess[Region]),
        UserAccess[UserEmail] = CurrentUser
    )
VAR AllowedProducts = 
    CALCULATETABLE(
        VALUES(UserAccess[ProductCategory]),
        UserAccess[UserEmail] = CurrentUser
    )
RETURN
[Region] IN AllowedRegions &&
[ProductCategory] IN AllowedProducts
```

## Advanced Patterns

### 9. Super User / Admin Role

Admin sees all data:

```dax
// Role: Admin
// Table: Sales

TRUE()
```

Or combined with regular users:
```dax
// Role: Combined
// Table: Sales

IF(
    USERPRINCIPALNAME() IN {"admin1@company.com", "admin2@company.com"},
    TRUE(),
    [OwnerEmail] = USERPRINCIPALNAME()
)
```

### 10. Custom Attribute Pattern (Azure AD)

Using Azure AD custom security attributes:

```dax
// Assuming custom attribute synced to UserProfile table
VAR UserRegion = 
    LOOKUPVALUE(
        UserProfile[AssignedRegion],
        UserProfile[Email],
        USERPRINCIPALNAME()
    )
RETURN
[Region] = UserRegion
```

### 11. Aggregation Protection

Prevent reverse-engineering through aggregations:

```dax
// Only show data if enough records exist
IF(
    COUNTROWS(Sales) >= 5,
    TRUE(),
    FALSE()
)
```

## Implementation Steps

### Step 1: Design Security Model

1. Identify data sensitivity levels
2. Define user groups/roles
3. Map users to data access
4. Document RLS requirements

### Step 2: Create Security Tables

```powerquery
// Example: User-Region mapping
let
    Source = Excel.Workbook(File.Contents("SecurityMapping.xlsx")),
    UserAccess = Source{[Name="UserAccess"]}[Data],
    Typed = Table.TransformColumnTypes(UserAccess, {
        {"UserEmail", type text},
        {"Region", type text},
        {"AccessLevel", type text}
    })
in
    Typed
```

### Step 3: Define Roles in Power BI

1. Open Power BI Desktop
2. Modeling → Manage Roles
3. Create role → Add DAX filter
4. Apply to appropriate tables

### Step 4: Test Thoroughly

**In Desktop:**
```
Modeling → View as Roles → Select role → Enter username
```

**Automated Testing:**
```dax
// Test query - run as different users
EVALUATE
CALCULATETABLE(
    SUMMARIZE(Sales, Sales[Region], "Count", COUNTROWS(Sales)),
    USERELATIONSHIP(...)
)
```

### Step 5: Publish and Assign

1. Publish to Power BI Service
2. Dataset Settings → Security
3. Add members to roles (users or groups)

## Best Practices

### Do's

| Practice | Reason |
|----------|--------|
| Use Azure AD groups | Easier maintenance |
| Test with actual users | Catch edge cases |
| Document all roles | Auditability |
| Use security tables | Dynamic, maintainable |
| Apply at lowest grain | Filter propagation works |

### Don'ts

| Anti-Pattern | Risk |
|--------------|------|
| Hardcoded emails in DAX | Maintenance nightmare |
| RLS on aggregated tables | May not filter correctly |
| Complex nested logic | Performance issues |
| Skipping testing | Security gaps |

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| User sees no data | Email mismatch | Check USERPRINCIPALNAME() vs stored email |
| Slow performance | Complex DAX filter | Simplify, use security table |
| Filter not applied | Wrong table | Apply to fact table, not dimension |
| Inconsistent results | Bidirectional relationships | Use single-direction filtering |

### Debugging

```dax
// Check what USERPRINCIPALNAME returns
EVALUATE ROW("User", USERPRINCIPALNAME())

// Check security table mapping
EVALUATE
FILTER(
    UserAccess,
    UserAccess[UserEmail] = USERPRINCIPALNAME()
)
```

## Object-Level Security (OLS)

For hiding entire tables/columns (Premium only):

1. Define in Tabular Editor
2. Restrict specific tables or columns
3. Users see error when accessing restricted objects

```json
// Tabular Editor script
{
  "Role": "Restricted",
  "ObjectPermissions": [
    {
      "Table": "EmployeeSalary",
      "Permission": "None"
    },
    {
      "Table": "Employee",
      "Column": "SSN",
      "Permission": "None"
    }
  ]
}
```

## Related Resources

- [Development Standards](./DevelopmentStandards.md)
- [Security Templates](../Templates/)
- [Microsoft RLS Documentation](https://learn.microsoft.com/power-bi/admin/service-admin-rls)
