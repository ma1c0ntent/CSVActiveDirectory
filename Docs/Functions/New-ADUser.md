# New-ADUser

Creates a new user account in the simulated Active Directory environment.

## Syntax

```powershell
New-ADUser [-SamAccountName] <String> [-FirstName] <String> [-LastName] <String> [-EmailAddress] <String> [[-Department] <String>] [[-Title] <String>] [[-Password] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Description

The `New-ADUser` cmdlet creates a new user account in the CSV-based Active Directory simulation. This function mimics the behavior of the real Active Directory `New-ADUser` cmdlet, providing a realistic experience for learning and testing purposes.

## Parameters

### SamAccountName
**Type**: String  
**Required**: True  
**Position**: 0  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The SAM account name (logon name) for the new user. This is the primary identifier used for authentication.

### FirstName
**Type**: String  
**Required**: True  
**Position**: 1  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The user's first name.

### LastName
**Type**: String  
**Required**: True  
**Position**: 2  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The user's last name.

### EmailAddress
**Type**: String  
**Required**: True  
**Position**: 3  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The user's email address. Used to generate the UserPrincipalName and DistinguishedName.

### Department
**Type**: String  
**Required**: False  
**Position**: Named  
**Default value**: "Security"  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The department the user belongs to. Valid values: HR, Security, Accounting, Marketing, Sales.

### Title
**Type**: String  
**Required**: False  
**Position**: Named  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The user's job title or position.

### Password
**Type**: String  
**Required**: False  
**Position**: Named  
**Default value**: None  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

The initial password for the user account. Must meet complexity requirements if specified.

### WhatIf
**Type**: SwitchParameter  
**Required**: False  
**Position**: Named  
**Default value**: False  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Shows what would happen if the cmdlet runs without actually executing the operation.

### Confirm
**Type**: SwitchParameter  
**Required**: False  
**Position**: Named  
**Default value**: False  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Prompts for confirmation before running the cmdlet.

## Inputs

None. This cmdlet does not accept pipeline input.

## Outputs

**PSCustomObject**

Returns a custom object representing the newly created user with the following properties:

- **Basic Information**: FirstName, LastName, DisplayName, SamAccountName
- **Contact**: EmailAddress, PhoneNumber, Mobile
- **Organization**: Department, Title, Company, Manager
- **Account Details**: DistinguishedName, UserPrincipalName, SID, GUID
- **Timestamps**: Created, Modified, PasswordLastSet, LastLogon
- **Status**: Enabled, AccountExpires, LockoutTime
- **Security**: LogonCount, BadPasswordCount, PasswordNeverExpires, CannotChangePassword, SmartCardRequired

## Examples

### Example 1: Create a basic user account
```powershell
New-ADUser -SamAccountName "jdoe" -FirstName "John" -LastName "Doe" -EmailAddress "john.doe@company.com"
```

### Example 2: Create a user with department and title
```powershell
New-ADUser -SamAccountName "asmith" -FirstName "Alice" -LastName "Smith" -EmailAddress "alice.smith@company.com" -Department "HR" -Title "Manager"
```

### Example 3: Create a user with password
```powershell
New-ADUser -SamAccountName "bwilson" -FirstName "Bob" -LastName "Wilson" -EmailAddress "bob.wilson@company.com" -Department "IT" -Title "Developer" -Password "SecurePass123!"
```

### Example 4: Create a user with confirmation
```powershell
New-ADUser -SamAccountName "mjones" -FirstName "Mary" -LastName "Jones" -EmailAddress "mary.jones@company.com" -Department "Marketing" -Title "Analyst" -Confirm
```

## Notes

- The function automatically generates a unique SAM account name if the specified name already exists
- Email addresses are automatically adjusted if the SAM account name is modified
- The DistinguishedName is automatically generated based on the user's name and department
- A unique GUID and SID are automatically assigned to each new user
- Office location is automatically assigned based on the department
- Phone numbers are automatically generated for the new user
- The user account is created as enabled by default
- All timestamps are set to the current date and time

## Related Links

- [Get-ADUser](Get-ADUser.md)
- [Remove-ADUser](Remove-ADUser.md)
- [Enable-ADAccount](Enable-ADAccount.md)
- [Disable-ADAccount](Disable-ADAccount.md) 