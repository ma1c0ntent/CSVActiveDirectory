# Show-ADProgress

## Overview

The `Show-ADProgress` function displays progress indicators for long-running operations in the CSV Active Directory module. It provides visual feedback to users during bulk operations, data processing, and other time-consuming tasks.

## Syntax

```powershell
Show-ADProgress [-Activity] <String> [-Status] <String> [-PercentComplete] <Int32> [-Style <String>] [<CommonParameters>]
```

## Parameters

### Activity
- **Type**: `String`
- **Required**: Yes
- **Description**: The name or description of the current activity
- **Examples**: `"Processing Users"`, `"Updating Database"`, `"Validating Passwords"`

### Status
- **Type**: `String`
- **Required**: Yes
- **Description**: The current status or step description
- **Examples**: `"Processing user 5 of 100"`, `"Validating password complexity"`, `"Completed"`

### PercentComplete
- **Type**: `Int32`
- **Required**: Yes
- **Description**: The percentage of completion (0-100)
- **Validation**: Must be between 0 and 100
- **Examples**: `25`, `50`, `100`

### Style
- **Type**: `String`
- **Required**: No
- **Default**: "Simple"
- **ValidateSet**: "Simple", "Detailed", "Minimal"
- **Description**: The visual style of the progress indicator

## Return Values

Returns a `PSCustomObject` with the following properties:
- `Activity` (String) - The activity name
- `Status` (String) - The current status
- `PercentComplete` (Int32) - The completion percentage
- `Style` (String) - The display style used
- `Timestamp` (DateTime) - When the progress was shown

## Examples

### Basic Progress Display

```powershell
# Simple progress indicator
Show-ADProgress -Activity "Processing Users" -Status "Starting..." -PercentComplete 0

# Update progress
Show-ADProgress -Activity "Processing Users" -Status "Processing user 5 of 10" -PercentComplete 50

# Complete progress
Show-ADProgress -Activity "Processing Users" -Status "Completed" -PercentComplete 100
```

### Different Progress Styles

```powershell
# Simple style (default)
Show-ADProgress -Activity "Data Import" -Status "Importing records" -PercentComplete 25 -Style "Simple"

# Detailed style
Show-ADProgress -Activity "Data Import" -Status "Processing record 150 of 600" -PercentComplete 25 -Style "Detailed"

# Minimal style
Show-ADProgress -Activity "Data Import" -Status "Working..." -PercentComplete 25 -Style "Minimal"
```

### Progress in Loops

```powershell
# Progress through user processing
$Users = Get-ADUser -Identity "*"
$TotalUsers = $Users.Count
$CurrentUser = 0

foreach ($User in $Users) {
    $CurrentUser++
    $PercentComplete = [math]::Round(($CurrentUser / $TotalUsers) * 100)
    
    Show-ADProgress -Activity "Processing Users" -Status "Processing $CurrentUser of $TotalUsers" -PercentComplete $PercentComplete
    
    # Process the user
    Start-Sleep -Milliseconds 100
}

Show-ADProgress -Activity "Processing Users" -Status "Completed" -PercentComplete 100
```

### Bulk Operations with Progress

```powershell
# Bulk user creation with progress
$NewUsers = @(
    @{FirstName="John"; LastName="Doe"; EmailAddress="john@company.com"},
    @{FirstName="Jane"; LastName="Smith"; EmailAddress="jane@company.com"},
    @{FirstName="Bob"; LastName="Johnson"; EmailAddress="bob@company.com"}
)

$TotalUsers = $NewUsers.Count
$CurrentUser = 0

foreach ($UserData in $NewUsers) {
    $CurrentUser++
    $PercentComplete = [math]::Round(($CurrentUser / $TotalUsers) * 100)
    
    Show-ADProgress -Activity "Creating Users" -Status "Creating user $CurrentUser of $TotalUsers" -PercentComplete $PercentComplete
    
    # Create the user
    New-ADUser @UserData
}

Show-ADProgress -Activity "Creating Users" -Status "All users created successfully" -PercentComplete 100
```

### Integration with Other Functions

```powershell
# Use with Start-ADOperation and Update-ADOperation
$Operation = Start-ADOperation -Activity "Bulk Account Management" -TotalItems 50

for ($i = 1; $i -le 50; $i++) {
    Update-ADOperation -Operation $Operation -CurrentItem "User$i" -Status "Processing user $i"
    Start-Sleep -Milliseconds 200
}

Complete-ADOperation -Operation $Operation -Message "All accounts processed successfully"
```

## Progress Styles

### Simple Style
- **Description**: Basic progress bar with percentage
- **Format**: `[████████░░░░] 80% Processing Users: Current step`
- **Use Case**: General purpose, most common

### Detailed Style
- **Description**: Comprehensive progress with additional information
- **Format**: `[████████░░░░] 80% (40/50) Processing Users: Current step`
- **Use Case**: When you need item counts and detailed status

### Minimal Style
- **Description**: Compact progress indicator
- **Format**: `80% Processing Users`
- **Use Case**: When space is limited or for quick feedback

## Error Handling

### Invalid Percentage
```powershell
# Handles out-of-range percentages gracefully
Show-ADProgress -Activity "Test" -Status "Working" -PercentComplete 150
# Clamps to 100%

Show-ADProgress -Activity "Test" -Status "Working" -PercentComplete -10
# Clamps to 0%
```

### Missing Parameters
```powershell
# Throws ParameterBindingException for missing required parameters
Show-ADProgress -Activity "Test"
# Throws error for missing Status and PercentComplete
```

## Performance Considerations

### Display Frequency
- Progress updates should not be too frequent
- Consider updating every 5-10% for long operations
- For very fast operations, update less frequently

### Memory Usage
- Progress objects are lightweight
- Minimal memory impact
- Safe for long-running operations

## Related Functions

- **Start-ADOperation** - Initialize complex operations
- **Update-ADOperation** - Update operation progress
- **Complete-ADOperation** - Finalize operations
- **Show-ADBulkProgress** - Bulk operations with error tracking
- **Show-ADStatus** - Display status messages

## Notes

- Progress indicators are displayed immediately
- Previous progress is overwritten by new progress
- The function respects console width and formatting
- Progress styles can be configured via Get-ADConfig
- All progress operations are logged for audit purposes

## See Also

- [PowerShell Progress Indicators](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines#support-progress-indicators)
- [Write-Progress Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-progress) 