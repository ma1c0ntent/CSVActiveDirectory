# Disable-ADAccount

Disables user accounts in the simulated Active Directory environment.

## Syntax

```powershell
Disable-ADAccount [-Identity] <String> [-Confirm] [-WhatIf] [<CommonParameters>]
```

## Description

The `Disable-ADAccount` cmdlet disables user accounts in the CSV-based Active Directory simulation. This function mimics the behavior of the real Active Directory `Disable-ADAccount` cmdlet, providing a realistic experience for learning and testing purposes.

## Parameters

### Identity
**Type**: String  
**Required**: True  
**Position**: 0  
**Default value**: None  
**Accept pipeline input**: True  
**Accept wildcard characters**: False

Specifies the identity of the user account to disable. Can be:
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

Prompts for confirmation before disabling the user account.

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

**PSCustomObject**

Returns a custom object representing the disabled user account with updated properties.

## Examples

### Example 1: Disable a user account
```powershell
Disable-ADAccount -Identity "jdoe"
```

### Example 2: Disable with confirmation
```powershell
Disable-ADAccount -Identity "jdoe" -Confirm
```

### Example 3: See what would happen
```powershell
Disable-ADAccount -Identity "jdoe" -WhatIf
```

### Example 4: Pipeline input
```powershell
"jdoe", "asmith" | Disable-ADAccount
```

### Example 5: Disable and verify
```powershell
Disable-ADAccount -Identity "jdoe"
Get-ADUser -Identity "jdoe" -Properties "Enabled"
```

## Notes

- The function changes the `Enabled` property from "TRUE" to "FALSE"
- The `Modified` timestamp is updated to the current date and time
- If the account is already disabled, no changes are made
- The function validates that the user exists before disabling
- If the user doesn't exist, a warning is displayed
- The function simulates real Active Directory behavior

## Error Handling

### User Not Found
```powershell
Disable-ADAccount -Identity "nonexistentuser"
# Displays warning: "User not found"
```

### Account Already Disabled
```powershell
Disable-ADAccount -Identity "alreadydisableduser"
# No changes made, account remains disabled
```

## Related Links

- [Get-ADUser](Get-ADUser.md)
- [New-ADUser](New-ADUser.md)
- [Remove-ADUser](Remove-ADUser.md)
- [Enable-ADAccount](Enable-ADAccount.md) 