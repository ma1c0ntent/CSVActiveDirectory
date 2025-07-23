# Search-ADAccount

## Overview

The `Search-ADAccount` cmdlet searches for accounts in the Active Directory database using advanced search capabilities, including account-specific filters and LDAP filters. This function simulates the real Active Directory `Search-ADAccount` cmdlet with comprehensive account search functionality.

## Syntax

```powershell
Search-ADAccount [-Filter <String>] [-SearchScope <String>] [-SearchBase <String>] 
    [-Properties <String[]>] [-ResultPageSize <Int32>] [-ResultSetSize <Int32>] 
    [-IncludeDeletedObjects] [-Tombstone] [-ShowDeleted] [-Server <String>] 
    [-Credential <PSCredential>] [-AuthType] [-UseSSL] [-LockedOut] 
    [-AccountExpired] [-AccountInactive] [-PasswordExpired] [-PasswordNeverExpires]
    [-AllowReversiblePasswordEncryption] [-CannotChangePassword] [-DoesNotRequirePreAuth]
    [-TrustedForDelegation] [-TrustedToAuthForDelegation] [-UseDESKeyOnly]
    [-SmartCardRequired] [-NotDelegated] [-Enabled] [-Disabled]

Search-ADAccount [-Identity <String>] [-SearchScope <String>] [-SearchBase <String>] 
    [-Properties <String[]>] [-ResultPageSize <Int32>] [-ResultSetSize <Int32>] 
    [-IncludeDeletedObjects] [-Tombstone] [-ShowDeleted] [-Server <String>] 
    [-Credential <PSCredential>] [-AuthType] [-UseSSL] [-LockedOut] 
    [-AccountExpired] [-AccountInactive] [-PasswordExpired] [-PasswordNeverExpires]
    [-AllowReversiblePasswordEncryption] [-CannotChangePassword] [-DoesNotRequirePreAuth]
    [-TrustedForDelegation] [-TrustedToAuthForDelegation] [-UseDESKeyOnly]
    [-SmartCardRequired] [-NotDelegated] [-Enabled] [-Disabled]
```

## Parameters

### -Filter
Specifies an LDAP filter string to search for accounts. Default value is "*" (all accounts).

```powershell
# Search all accounts
Search-ADAccount -Filter "*"

# Search by SamAccountName
Search-ADAccount -Filter "(sAMAccountName=jdoe)"

# Search by DisplayName
Search-ADAccount -Filter "(displayName=*John*)"

# Search by Department
Search-ADAccount -Filter "(department=IT)"

# Search enabled accounts
Search-ADAccount -Filter "(enabled=TRUE)"

# Search accounts with bad password attempts
Search-ADAccount -Filter "(badPwdCount>=3)"
```

### -Identity
Specifies the identity of the account to search for. Can be SamAccountName, DisplayName, FirstName, LastName, or Email.

```powershell
# Search by SamAccountName
Search-ADAccount -Identity "jdoe"

# Search by DisplayName (partial match)
Search-ADAccount -Identity "John"

# Search by FirstName or LastName
Search-ADAccount -Identity "Smith"

# Search by Email
Search-ADAccount -Identity "john.doe@company.com"
```

### Account Status Filters

#### -LockedOut
Filters results to show only locked out accounts.

```powershell
# Find all locked out accounts
Search-ADAccount -LockedOut

# Find locked out accounts in IT department
Search-ADAccount -Filter "(department=IT)" -LockedOut

# Find locked out accounts with specific properties
Search-ADAccount -LockedOut -Properties "SamAccountName", "DisplayName", "Department", "BadPasswordCount"
```

#### -AccountExpired
Filters results to show only expired accounts.

```powershell
# Find all expired accounts
Search-ADAccount -AccountExpired

# Find expired accounts with details
Search-ADAccount -AccountExpired -Properties "SamAccountName", "DisplayName", "AccountExpires"
```

#### -AccountInactive
Filters results to show only inactive accounts (no logon in 30 days).

```powershell
# Find all inactive accounts
Search-ADAccount -AccountInactive

# Find inactive accounts with details
Search-ADAccount -AccountInactive -Properties "SamAccountName", "DisplayName", "LastLogon"
```

#### -PasswordExpired
Filters results to show only accounts with expired passwords (90+ days old).

```powershell
# Find all accounts with expired passwords
Search-ADAccount -PasswordExpired

# Find accounts with expired passwords and details
Search-ADAccount -PasswordExpired -Properties "SamAccountName", "DisplayName", "PasswordLastSet"
```

#### -PasswordNeverExpires
Filters results to show only accounts with passwords that never expire.

```powershell
# Find all accounts with passwords that never expire
Search-ADAccount -PasswordNeverExpires

# Find accounts with non-expiring passwords and details
Search-ADAccount -PasswordNeverExpires -Properties "SamAccountName", "DisplayName", "PasswordNeverExpires"
```

#### -Enabled
Filters results to show only enabled accounts.

```powershell
# Find all enabled accounts
Search-ADAccount -Enabled

# Find enabled accounts in IT department
Search-ADAccount -Filter "(department=IT)" -Enabled
```

#### -Disabled
Filters results to show only disabled accounts.

```powershell
# Find all disabled accounts
Search-ADAccount -Disabled

# Find disabled accounts with details
Search-ADAccount -Disabled -Properties "SamAccountName", "DisplayName", "Department"
```

#### -SmartCardRequired
Filters results to show only accounts requiring smart cards.

```powershell
# Find all accounts requiring smart cards
Search-ADAccount -SmartCardRequired

# Find smart card required accounts with details
Search-ADAccount -SmartCardRequired -Properties "SamAccountName", "DisplayName", "SmartCardRequired"
```

#### -CannotChangePassword
Filters results to show only accounts that cannot change passwords.

```powershell
# Find all accounts that cannot change passwords
Search-ADAccount -CannotChangePassword

# Find accounts that cannot change passwords with details
Search-ADAccount -CannotChangePassword -Properties "SamAccountName", "DisplayName", "CannotChangePassword"
```

### -SearchScope
Specifies the scope of the search. Valid values are:
- **Base**: Searches only the current object
- **OneLevel**: Searches the immediate children of the current object
- **Subtree**: Searches the current object and all its children (default)

```powershell
# Search only the first result
Search-ADAccount -SearchScope "Base"

# Search limited results
Search-ADAccount -SearchScope "OneLevel" -ResultPageSize 10

# Search all results (default)
Search-ADAccount -SearchScope "Subtree"
```

### -SearchBase
Specifies the search base. Valid values are:
- **All**: All object types
- **Users**: User accounts only (default)
- **Computers**: Computer accounts only
- **Groups**: Group accounts only

```powershell
Search-ADAccount -SearchBase "Users"
```

### -Properties
Specifies the properties to return for each account.

```powershell
# Return specific properties
Search-ADAccount -Properties "SamAccountName", "DisplayName", "Department"

# Return all properties
Search-ADAccount -Properties "*"
```

### -ResultPageSize
Specifies the number of results to return per page. Valid range is 1-1000. Default is 100.

```powershell
Search-ADAccount -ResultPageSize 50
```

### -ResultSetSize
Specifies the maximum number of results to return. Valid range is 1-10000. Default is 1000.

```powershell
Search-ADAccount -ResultSetSize 500
```

## Examples

### Basic Search Examples

```powershell
# Search all accounts
Search-ADAccount

# Search with wildcard filter
Search-ADAccount -Filter "*"

# Search by identity
Search-ADAccount -Identity "jdoe"
```

### Account Status Search Examples

```powershell
# Find locked out accounts
Search-ADAccount -LockedOut

# Find expired accounts
Search-ADAccount -AccountExpired

# Find inactive accounts
Search-ADAccount -AccountInactive

# Find accounts with expired passwords
Search-ADAccount -PasswordExpired

# Find enabled accounts
Search-ADAccount -Enabled

# Find disabled accounts
Search-ADAccount -Disabled
```

### Advanced Search Examples

```powershell
# Find locked out accounts in IT department
Search-ADAccount -Filter "(department=IT)" -LockedOut

# Find enabled accounts with specific properties
Search-ADAccount -Enabled -Properties "SamAccountName", "DisplayName", "Department"

# Find accounts with bad password attempts
Search-ADAccount -Filter "(badPwdCount>=5)"

# Find accounts requiring smart cards
Search-ADAccount -SmartCardRequired

# Find accounts that cannot change passwords
Search-ADAccount -CannotChangePassword
```

### Combined Filter Examples

```powershell
# Find locked out accounts in IT department
Search-ADAccount -Filter "(department=IT)" -LockedOut

# Find enabled accounts with expired passwords
Search-ADAccount -Enabled -PasswordExpired

# Find inactive accounts that are enabled
Search-ADAccount -Enabled -AccountInactive

# Find accounts with passwords that never expire
Search-ADAccount -PasswordNeverExpires
```

### LDAP Filter Examples

```powershell
# Complex LDAP filters
Search-ADAccount -Filter "(&(department=IT)(enabled=TRUE))"

# Search by multiple criteria
Search-ADAccount -Filter "(|(department=IT)(department=Security))"

# Search with wildcards
Search-ADAccount -Filter "(displayName=*Admin*)"
```

### Result Limiting Examples

```powershell
# Limit results to first 10
Search-ADAccount -ResultSetSize 10

# Use base scope for single result
Search-ADAccount -SearchScope "Base"

# Use one level scope with page size
Search-ADAccount -SearchScope "OneLevel" -ResultPageSize 5
```

### Property Selection Examples

```powershell
# Return specific properties
Search-ADAccount -Properties "SamAccountName", "DisplayName", "Department", "Title"

# Return all properties
Search-ADAccount -Properties "*"

# Return security-related properties
Search-ADAccount -Properties "SamAccountName", "Enabled", "BadPasswordCount", "LockoutTime", "PasswordLastSet"
```

## Output

The cmdlet returns `ADAccount` or `ADAccountExtended` objects depending on whether properties are specified:

- **ADAccount**: Basic account information (SamAccountName, DisplayName, FirstName, LastName)
- **ADAccountExtended**: Extended account information with all specified properties

### Object Properties

When no properties are specified, the following properties are returned:
- **SamAccountName**: Account's logon name
- **DisplayName**: Account's display name
- **FirstName**: Account's first name
- **LastName**: Account's last name

When properties are specified, all requested properties are returned.

## Error Handling

The cmdlet handles various error conditions:

- **Database not found**: Returns null and writes error message
- **Invalid LDAP filters**: Falls back to text search
- **Invalid parameters**: Throws parameter validation errors
- **No results found**: Returns empty array

## Performance Considerations

- **Large result sets**: Use `-ResultSetSize` to limit results
- **Complex filters**: LDAP filters are processed efficiently
- **Property selection**: Only return needed properties for better performance
- **Search scopes**: Use appropriate scope to limit search area

## Integration

The `Search-ADAccount` cmdlet integrates with other module functions:

```powershell
# Combine with Get-ADUser for comparison
$searchResults = Search-ADAccount -Filter "(department=IT)"
$getResults = Get-ADUser -Filter "Department -eq 'IT'"

# Use with other AD functions
Search-ADAccount -LockedOut | ForEach-Object {
    Enable-ADAccount -Identity $_.SamAccountName
}

# Export locked out accounts to CSV
Search-ADAccount -LockedOut -Properties "SamAccountName", "DisplayName", "Department", "BadPasswordCount" |
    Export-Csv -Path "LockedOutAccounts.csv" -NoTypeInformation
```

## Differences from Real AD

This simulation provides the core functionality of the real `Search-ADAccount` cmdlet:

- **Account Status Filters**: Supports all major account status filters
- **LDAP Filters**: Supports common LDAP filter patterns
- **Search Scopes**: Implements Base, OneLevel, and Subtree scopes
- **Result Limiting**: Supports page size and result set size limits
- **Property Selection**: Allows custom property selection
- **Error Handling**: Graceful error handling for various scenarios

The simulation focuses on the most commonly used features while maintaining compatibility with real AD scripts.

 