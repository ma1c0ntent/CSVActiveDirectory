# Get-ADUser

Retrieves user accounts from the simulated Active Directory environment.

## Syntax

```powershell
Get-ADUser [-Identity] <String[]> [-Properties <String[]>] [<CommonParameters>]

Get-ADUser [-Filter] <String> [-Properties <String[]>] [<CommonParameters>]
```

## Description

The `Get-ADUser` cmdlet retrieves user accounts from the CSV-based Active Directory simulation. This function mimics the behavior of the real Active Directory `Get-ADUser` cmdlet, providing a realistic experience for learning and testing purposes.

## Parameters

### Identity
**Type**: String[]  
**Required**: True (when using Identity parameter set)  
**Position**: 0  
**Default value**: None  
**Accept pipeline input**: True  
**Accept wildcard characters**: False

Specifies the identity of the user account to retrieve. Can be:
- A specific SAM account name (e.g., "mbryan")
- Wildcard "*" to retrieve all users
- Multiple users as an array

### Filter
**Type**: String  
**Required**: True (when using Filter parameter set)  
**Position**: 0  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Specifies a filter to search for users. Uses LDAP filter syntax:
- `"Department -eq 'Security'"` - Find users in Security department
- `"Enabled -eq 'TRUE'"` - Find enabled users
- `"Title -eq 'Manager'"` - Find users with Manager title

### Properties
**Type**: String[]  
**Required**: False  
**Position**: Named  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Specifies which properties to retrieve:
- `"*"` - All properties
- Specific properties: `"Department", "Title", "Enabled"`
- Default: Core properties only (FirstName, LastName, DisplayName, SamAccountName)

## Inputs

**String[]**

The Identity parameter accepts pipeline input.

## Outputs

**PSCustomObject**

Returns custom objects representing user accounts with the following property categories:

- **Basic Information**: FirstName, LastName, DisplayName, SamAccountName
- **Contact**: EmailAddress, PhoneNumber, Mobile
- **Organization**: Department, Title, Company, Manager
- **Account Details**: DistinguishedName, UserPrincipalName, SID, GUID
- **Timestamps**: Created, Modified, PasswordLastSet, LastLogon
- **Status**: Enabled, AccountExpires, LockoutTime
- **Security**: LogonCount, BadPasswordCount, PasswordNeverExpires, CannotChangePassword, SmartCardRequired

## Examples

### Example 1: Get a specific user
```powershell
Get-ADUser -Identity "mbryan"
```

### Example 2: Get all users
```powershell
Get-ADUser -Identity "*"
```

### Example 3: Get user with specific properties
```powershell
Get-ADUser -Identity "mbryan" -Properties "Department", "Title", "Enabled"
```

### Example 4: Get all properties for a user
```powershell
Get-ADUser -Identity "mbryan" -Properties "*"
```

### Example 5: Filter users by department
```powershell
Get-ADUser -Filter "Department -eq 'Security'"
```

### Example 6: Filter enabled users
```powershell
Get-ADUser -Filter "Enabled -eq 'TRUE'"
```

### Example 7: Filter users by title
```powershell
Get-ADUser -Filter "Title -eq 'Manager'"
```

### Example 8: Get all users with all properties
```powershell
Get-ADUser -Identity "*" -Properties "*"
```

### Example 9: Pipeline input
```powershell
"mbryan", "jdoe" | Get-ADUser
```

### Example 10: Format output
```powershell
# Table format (default)
Get-ADUser -Identity "*" | Format-Table

# List format
Get-ADUser -Identity "*" | Format-List

# Extended table format
Get-ADUser -Identity "*" -Properties "*" | Format-Table
```

## Format Views

The cmdlet supports custom format views that automatically select based on the properties requested:

### Default View (Core Properties)
Shows: `DisplayName`, `SamAccountName`, `FirstName`, `LastName`

### Extended View (with `-Properties *`)
Shows: `Name`, `SamAccountName`, `EmailAddress`, `Department`, `Title`, `Enabled`

## Notes

- By default, only core properties are returned for performance
- Use `-Properties "*"` to retrieve all available properties
- The function supports both Identity and Filter parameter sets
- Wildcard "*" can be used to retrieve all users
- Filter syntax follows LDAP filter patterns
- Output is automatically formatted based on the properties requested
- The function simulates real Active Directory behavior

## Related Links

- [New-ADUser](New-ADUser.md)
- [Remove-ADUser](Remove-ADUser.md)
- [Enable-ADAccount](Enable-ADAccount.md)
- [Disable-ADAccount](Disable-ADAccount.md) 