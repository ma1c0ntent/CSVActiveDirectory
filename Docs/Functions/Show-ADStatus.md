# Show-ADStatus

## Overview

The `Show-ADStatus` function displays color-coded status messages for various operations in the CSV Active Directory module. It provides standardized feedback for success, warnings, errors, and informational messages with consistent formatting and colors.

## Syntax

```powershell
Show-ADStatus [-Message] <String> [-Type] <String> [-NoNewline] [-Timestamp] [<CommonParameters>]
```

## Parameters

### Message
- **Type**: `String`
- **Required**: Yes
- **Description**: The status message to display
- **Examples**: `"User created successfully"`, `"Warning: Password too weak"`, `"Error: User not found"`

### Type
- **Type**: `String`
- **Required**: Yes
- **ValidateSet**: "Success", "Warning", "Error", "Info"
- **Description**: The type of status message
- **Examples**: `"Success"`, `"Warning"`, `"Error"`, `"Info"`

### NoNewline
- **Type**: `SwitchParameter`
- **Required**: No
- **Description**: Suppresses the newline character at the end of the message

### Timestamp
- **Type**: `SwitchParameter`
- **Required**: No
- **Description**: Includes a timestamp with the status message

## Return Values

Returns a `PSCustomObject` with the following properties:
- `Message` (String) - The status message
- `Type` (String) - The message type
- `Timestamp` (DateTime) - When the message was displayed
- `Color` (String) - The color used for the message

## Examples

### Basic Status Messages

```powershell
# Success message
Show-ADStatus -Message "User 'jdoe' created successfully" -Type "Success"

# Warning message
Show-ADStatus -Message "Password complexity requirements not met" -Type "Warning"

# Error message
Show-ADStatus -Message "User 'nonexistent' not found" -Type "Error"

# Information message
Show-ADStatus -Message "Processing 50 users..." -Type "Info"
```

### Status Messages with Timestamps

```powershell
# Success with timestamp
Show-ADStatus -Message "Database backup completed" -Type "Success" -Timestamp

# Error with timestamp
Show-ADStatus -Message "Failed to connect to database" -Type "Error" -Timestamp
```

### Inline Status Messages

```powershell
# Status without newline for inline display
Show-ADStatus -Message "Processing..." -Type "Info" -NoNewline
Start-Sleep -Seconds 2
Show-ADStatus -Message "Complete!" -Type "Success"
```

### Conditional Status Messages

```powershell
# User creation with status feedback
$User = New-ADUser -SamAccountName "jdoe" -FirstName "John" -LastName "Doe" -EmailAddress "john@company.com"

if ($User) {
    Show-ADStatus -Message "User 'jdoe' created successfully" -Type "Success"
} else {
    Show-ADStatus -Message "Failed to create user 'jdoe'" -Type "Error"
}
```

### Bulk Operations with Status

```powershell
# Bulk user creation with status feedback
$UsersToCreate = @("user1", "user2", "user3")
$SuccessCount = 0
$ErrorCount = 0

foreach ($Username in $UsersToCreate) {
    try {
        $User = New-ADUser -SamAccountName $Username -FirstName "Test" -LastName "User" -EmailAddress "$Username@company.com"
        if ($User) {
            $SuccessCount++
            Show-ADStatus -Message "Created user: $Username" -Type "Success"
        } else {
            $ErrorCount++
            Show-ADStatus -Message "Failed to create user: $Username" -Type "Error"
        }
    }
    catch {
        $ErrorCount++
        Show-ADStatus -Message "Error creating user $Username`: $($_.Exception.Message)" -Type "Error"
    }
}

# Summary
Show-ADStatus -Message "Bulk operation completed. Success: $SuccessCount, Errors: $ErrorCount" -Type "Info" -Timestamp
```

### Integration with Other Functions

```powershell
# Use with progress indicators
Show-ADStatus -Message "Starting bulk user import..." -Type "Info"

$Users = Get-ADUser -Identity "*"
$TotalUsers = $Users.Count

foreach ($User in $Users) {
    Show-ADProgress -Activity "Processing Users" -Status "Processing $($User.SamAccountName)" -PercentComplete 50
    
    if ($User.Enabled -eq "FALSE") {
        Show-ADStatus -Message "Found disabled user: $($User.SamAccountName)" -Type "Warning"
    }
}

Show-ADStatus -Message "User processing completed" -Type "Success" -Timestamp
```

## Status Types and Colors

### Success
- **Color**: Green
- **Use Case**: Successful operations, completions, positive results
- **Example**: `"User created successfully"`

### Warning
- **Color**: Yellow
- **Use Case**: Non-critical issues, recommendations, potential problems
- **Example**: `"Password will expire soon"`

### Error
- **Color**: Red
- **Use Case**: Failed operations, critical issues, exceptions
- **Example**: `"User not found"`

### Info
- **Color**: Cyan
- **Use Case**: Informational messages, progress updates, general information
- **Example**: `"Processing 100 users..."`

## Error Handling

### Invalid Status Type
```powershell
# Handles invalid status types gracefully
Show-ADStatus -Message "Test message" -Type "InvalidType"
# Uses default Info type
```

### Empty Message
```powershell
# Handles empty messages
Show-ADStatus -Message "" -Type "Success"
# Displays empty message with color
```

### Missing Parameters
```powershell
# Throws ParameterBindingException for missing required parameters
Show-ADStatus -Message "Test"
# Throws error for missing Type parameter
```

## Performance Considerations

### Message Frequency
- Status messages are lightweight
- Safe for high-frequency updates
- Consider using progress indicators for long operations

### Console Output
- Messages are written to console immediately
- No buffering or queuing
- Respects console width and formatting

## Related Functions

- **Show-ADProgress** - Display progress indicators
- **Start-ADOperation** - Initialize complex operations
- **Update-ADOperation** - Update operation progress
- **Complete-ADOperation** - Finalize operations
- **Get-ADConfig** - Configure display preferences

## Notes

- Status messages are displayed immediately
- Colors are consistent across the module
- Messages can be logged for audit purposes
- The function respects console color settings
- Status types can be configured via Get-ADConfig

## See Also

- [PowerShell Write-Host](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host)
- [PowerShell Error Handling](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines#support-error-handling) 