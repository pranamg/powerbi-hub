# Object-Level Security (OLS) Configuration

> **Purpose:** Templates and patterns for implementing Object-Level Security in Power BI

---

## Overview

Object-Level Security (OLS) restricts access to specific tables or columns within a semantic model. Unlike RLS which filters rows, OLS completely hides objects from users.

### When to Use OLS

| Use Case | Example | OLS Appropriate |
|----------|---------|-----------------|
| Hide sensitive columns | SSN, Salary | ✓ Yes |
| Hide entire tables | HR_Confidential | ✓ Yes |
| Filter data by user | Sales by region | ✗ Use RLS |
| Hide measures | N/A | ✗ Not supported |

### OLS vs RLS

| Feature | RLS | OLS |
|---------|-----|-----|
| Filters rows | ✓ | ✗ |
| Hides columns | ✗ | ✓ |
| Hides tables | ✗ | ✓ |
| Hides measures | ✗ | ✗ |
| Can be combined | ✓ | ✓ |

---

## Implementation Methods

### Method 1: Tabular Editor (Recommended)

```csharp
// In Tabular Editor, select column then set TablePermission

// For a column
Model.Tables["Employee"].Columns["Salary"].ObjectLevelSecurity["RestrictedRole"] = OLSPermission.None;

// For entire table
Model.Tables["HR_Confidential"].ObjectLevelSecurity["StandardUser"] = OLSPermission.None;
```

### Method 2: TMDL Definition

```tmdl
role RestrictedAccess
    modelPermission: read
    
    tablePermission Employee
        columnPermission Salary = none
        columnPermission SSN = none
        
    tablePermission HR_Confidential = none
```

### Method 3: XMLA/TOM

```csharp
using Microsoft.AnalysisServices.Tabular;

// Connect to model
var server = new Server();
server.Connect("powerbi://api.powerbi.com/v1.0/myorg/WorkspaceName");
var model = server.Databases["DatasetName"].Model;

// Get or create role
var role = model.Roles.FirstOrDefault(r => r.Name == "RestrictedAccess")
    ?? new ModelRole { Name = "RestrictedAccess" };

// Set table permission with OLS
var tablePermission = new TablePermission
{
    Table = model.Tables["Employee"]
};

// Add column permissions
var salaryColumn = model.Tables["Employee"].Columns["Salary"];
tablePermission.ColumnPermissions.Add(new ColumnPermission
{
    Column = salaryColumn,
    MetadataPermission = MetadataPermission.None
});

role.TablePermissions.Add(tablePermission);
model.SaveChanges();
```

---

## Common OLS Patterns

### Pattern 1: PII Protection

Hide personally identifiable information from general users.

**Scenario:** Customer table has SSN, DateOfBirth, PhoneNumber

```tmdl
role GeneralUser
    modelPermission: read
    
    tablePermission Customer
        columnPermission SSN = none
        columnPermission DateOfBirth = none
        columnPermission PhoneNumber = none

role PIIAccess
    modelPermission: read
    // No restrictions - can see all columns
```

**Role Assignment:**
| Role | Users | Access |
|------|-------|--------|
| GeneralUser | Most users | No PII |
| PIIAccess | Compliance team | Full access |

### Pattern 2: Salary Data Protection

```tmdl
role StandardEmployee
    modelPermission: read
    
    tablePermission Employee
        columnPermission Salary = none
        columnPermission Bonus = none
        columnPermission StockOptions = none
        columnPermission TotalCompensation = none

role HRManager
    modelPermission: read
    
    tablePermission Employee
        // HR sees their team's salary only (combine with RLS)

role ExecutiveCompAccess
    modelPermission: read
    // Full access to all compensation data
```

### Pattern 3: Hide Entire Tables

```tmdl
role ExternalUser
    modelPermission: read
    
    // Hide internal-only tables entirely
    tablePermission InternalMetrics = none
    tablePermission CostData = none
    tablePermission Margins = none

role InternalUser
    modelPermission: read
    // Full access to all tables
```

### Pattern 4: Financial Data Tiering

```tmdl
role Tier1_PublicData
    modelPermission: read
    
    tablePermission Financials
        columnPermission Revenue = none
        columnPermission COGS = none
        columnPermission Margin = none
        columnPermission Forecast = none
    
    tablePermission BudgetDetails = none

role Tier2_InternalFinance
    modelPermission: read
    
    tablePermission Financials
        columnPermission Forecast = none
    
    tablePermission BudgetDetails
        columnPermission DepartmentBudget = none

role Tier3_FinanceTeam
    modelPermission: read
    // Full access
```

### Pattern 5: Combined RLS + OLS

```tmdl
// RLS: Filter by region
role RegionalSales
    modelPermission: read
    
    tablePermission Sales = 'Sales'[Region] = USERPRINCIPALNAME()
    
    // OLS: Hide margin columns from sales users
    tablePermission Sales
        columnPermission CostPrice = none
        columnPermission Margin = none
        columnPermission SupplierCost = none

// RLS + OLS: Region filter + no sensitive columns
```

---

## Configuration Templates

### Template: Healthcare (HIPAA)

```tmdl
// HIPAA-compliant OLS configuration

role ClinicalStaff
    modelPermission: read
    
    tablePermission Patient
        columnPermission SSN = none
        columnPermission InsuranceId = none
        columnPermission BillingAddress = none
    
    tablePermission Billing = none

role BillingStaff
    modelPermission: read
    
    tablePermission Patient
        columnPermission SSN = none
        columnPermission MedicalRecordNumber = none
        columnPermission DiagnosisCodes = none
    
    tablePermission ClinicalNotes = none

role HIPAACompliance
    modelPermission: read
    // Full PHI access for compliance reviews
```

### Template: Financial Services

```tmdl
// Financial data protection

role PublicReporting
    modelPermission: read
    
    tablePermission TradeData = none
    tablePermission ClientPositions = none
    tablePermission InternalValuations = none

role FrontOffice
    modelPermission: read
    
    tablePermission TradeData
        columnPermission Commission = none
        columnPermission InternalCost = none
    
    tablePermission InternalValuations = none

role RiskManagement
    modelPermission: read
    
    tablePermission ClientPositions
        columnPermission TradingStrategy = none

role ComplianceOfficer
    modelPermission: read
    // Full access for regulatory requirements
```

### Template: HR Data

```tmdl
// HR data protection

role AllEmployees
    modelPermission: read
    
    tablePermission Employee
        columnPermission Salary = none
        columnPermission Bonus = none
        columnPermission PerformanceRating = none
        columnPermission TerminationReason = none
        columnPermission SSN = none
        columnPermission BankAccount = none
    
    tablePermission Payroll = none
    tablePermission Performance = none
    tablePermission Disciplinary = none

role PeopleManager
    modelPermission: read
    
    tablePermission Employee
        columnPermission SSN = none
        columnPermission BankAccount = none
    
    tablePermission Performance
        // Combine with RLS to show only direct reports
    
    tablePermission Payroll = none
    tablePermission Disciplinary = none

role HRBusinessPartner
    modelPermission: read
    
    tablePermission Employee
        columnPermission BankAccount = none
    
    // Access to Performance and Disciplinary via RLS

role PayrollAdmin
    modelPermission: read
    // Full payroll access, limited performance data
    
    tablePermission Performance = none
    tablePermission Disciplinary = none
```

---

## Testing OLS

### Test Procedure

1. **Identify test users** for each role
2. **Test in Power BI Desktop** using "View as Role"
3. **Test in Service** with actual user accounts
4. **Verify hidden columns** don't appear in field list
5. **Verify error messages** don't reveal column names

### Test Script (DAX Query View)

```dax
// Test OLS by attempting to query restricted column
// Should return error for restricted users

EVALUATE
SUMMARIZECOLUMNS(
    Employee[Name],
    Employee[Salary]  // This should error for restricted users
)
```

### Validation Checklist

```markdown
## OLS Validation Checklist

**Dataset:** ________________
**Role:** ________________
**Tester:** ________________
**Date:** ________________

### Column Visibility Tests
| Table | Column | Expected | Actual | Pass |
|-------|--------|----------|--------|------|
| Employee | Salary | Hidden | | ✓/✗ |
| Employee | SSN | Hidden | | ✓/✗ |
| Customer | Name | Visible | | ✓/✗ |

### Table Visibility Tests
| Table | Expected | Actual | Pass |
|-------|----------|--------|------|
| HR_Confidential | Hidden | | ✓/✗ |
| Sales | Visible | | ✓/✗ |

### Error Message Tests
- [ ] Error doesn't reveal column name
- [ ] Error doesn't reveal table name
- [ ] Generic "access denied" message shown

### Report Behavior
- [ ] Reports render without errors
- [ ] Visuals using hidden columns show appropriate error
- [ ] Tooltips don't reveal hidden data
```

---

## Best Practices

### Do's

1. **Document all OLS configurations** in data catalog
2. **Test thoroughly** before production deployment
3. **Combine with RLS** for comprehensive security
4. **Use meaningful role names** that indicate access level
5. **Review regularly** during security audits

### Don'ts

1. **Don't rely solely on OLS** - it's metadata security only
2. **Don't use for row-level filtering** - use RLS instead
3. **Don't forget to test** error messages
4. **Don't assume OLS encrypts data** - it only hides visibility

### Security Considerations

| Risk | Mitigation |
|------|------------|
| Users with model edit rights can see OLS config | Restrict model editing permissions |
| DAX queries might infer hidden data | Test query patterns |
| Error messages might reveal column existence | Verify generic error messages |
| Calculated columns might expose hidden data | Review all DAX expressions |

---

## Troubleshooting

### Common Issues

**"Column not found" errors in reports**
- Expected behavior when OLS hides columns
- Update reports to handle missing columns gracefully

**OLS not applying**
- Verify user is in correct security role
- Check role is assigned in Power BI service
- Ensure dataset is refreshed after changes

**Can still see hidden columns in Desktop**
- Use "View as Role" feature
- Or test with actual restricted user account

---

## Related Documents

- [RLS Patterns](./RLSPatterns.md)
- [Data Classification](./DataClassification.md)
- [Audit Procedures](./AuditProcedures.md)

---

*Last Updated: December 2024*
