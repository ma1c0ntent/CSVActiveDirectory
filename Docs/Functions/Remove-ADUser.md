# Remove-ADUser

Removes user accounts from the simulated Active Directory environment.

## Syntax

```powershell
Remove-ADUser [-Identity] <String> [-Confirm] [-WhatIf] [<CommonParameters>]
```

## Description

The `Remove-ADUser` cmdlet removes user accounts from the CSV-based Active Directory simulation. This function mimics the behavior of the real Active Directory `Remove-ADUser` cmdlet, providing a realistic experience for learning and testing purposes.

## Parameters

### Identity
**Type**: String  
**Required**: True  
**Position**: 0  
**Default value**: None  
**Accept pipeline input**: True  
**Accept wildcard characters**: False

Specifies the identity of the user account to remove. Can be:
- A specific SAM account name (e.g., "mbryan")
- The user's display name
- The user's email address

### Confirm
**Type**: SwitchParameter  
**Required**: False  
**Position**: Named  
**Default value**: False  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Prompts for confirmation before removing the user account.

### WhatIf
**Type**: SwitchParameter  
**Required**: False  
**Position**: Named  
**Default value**: False  
**Accept pipeline input**: False  
**Accept wildcard characters**: False

Shows what would happen if the cmdlet runs without actually executing the operation.

## Inputs

**String**

The Identity parameter accepts pipeline input.

## Outputs

**None**

This cmdlet does not return any output.

## Examples

### Example 1: Remove a user with confirmation
```powershell
Remove-ADUser -Identity "jdoe" -Confirm
```

### Example 2: Remove a user without confirmation
```powershell
Remove-ADUser -Identity "jdoe" -Confirm:$false
```

### Example 3: See what would be removed
```powershell
Remove-ADUser -Identity "jdoe" -WhatIf
```

### Example 4: Pipeline input
```powershell
"jdoe", "asmith" | Remove-ADUser -Confirm:$false
```

### Example 5: Remove user by display name
```powershell
Remove-ADUser -Identity "John Doe" -Confirm:$false
```

## Notes

- The function permanently removes the user account from the database
- No backup is automatically created (use database backup if needed)
- The function validates that the user exists before removal
- If the user doesn't exist, a warning is displayed
- The operation cannot be undone once completed
- The function simulates real Active Directory behavior

## Error Handling

### User Not Found
```powershell
Remove-ADUser -Identity "nonexistentuser"
# Displays warning: "User not found"
```

### Confirmation Cancelled
```powershell
Remove-ADUser -Identity "jdoe" -Confirm
# Prompts for confirmation, operation cancelled if user declines
```

## Data Removed

When a user is removed, the following data is permanently deleted:

- **Basic Information**: FirstName, LastName, DisplayName, SamAccountName
- **Contact**: EmailAddress, PhoneNumber, Mobile
- **Organization**: Department, Title, Company, Manager
- **Account Details**: DistinguishedName, UserPrincipalName, SID, GUID
- **Timestamps**: Created, Modified, PasswordLastSet, LastLogon
- **Status**: Enabled, AccountExpires, LockoutTime
- **Security**: LogonCount, BadPasswordCount, PasswordNeverExpires, CannotChangePassword, SmartCardRequired

## Related Links

- [Get-ADUser](Get-ADUser.md)
- [New-ADUser](New-ADUser.md)
- [Enable-ADAccount](Enable-ADAccount.md)
- [Disable-ADAccount](Disable-ADAccount.md)