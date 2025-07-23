# Get-ADConfig

## Overview

The `Get-ADConfig` function retrieves configuration settings from the JSON-based configuration system used by the CSV Active Directory module. It provides access to domain settings, password policies, display preferences, and other module configuration options.

## Syntax

```powershell
Get-ADConfig [[-Section] <String>] [[-Key] <String>] [-ShowAll] [<CommonParameters>]
```

## Parameters

### Section
- **Type**: `String`
- **Required**: No
- **Description**: The configuration section to retrieve (e.g., "PasswordPolicy", "DomainSettings", "Display")
- **Examples**: `"PasswordPolicy"`, `"DomainSettings"`, `"Display"`

### Key
- **Type**: `String`
- **Required**: No
- **Description**: The specific configuration key within a section
- **Examples**: `"MinimumLength"`, `"DomainName"`, `"ProgressBarStyle"`

### ShowAll
- **Type**: `SwitchParameter`
- **Required**: No
- **Description**: Shows all configuration sections and their values

## Return Values

Returns different object types based on usage:

### Single Key Value
- **Type**: `String`, `Int32`, `Boolean`, etc.
- **Description**: The value of the specified configuration key

### Section Object
- **Type**: `PSCustomObject`
- **Description**: All key-value pairs within the specified section

### All Configuration
- **Type**: `PSCustomObject`
- **Description**: Complete configuration object with all sections

## Examples

### View All Configuration

```powershell
# Show all configuration sections
Get-ADConfig -ShowAll

# Get complete configuration object
$Config = Get-ADConfig
$Config | Format-List
```

### Get Specific Sections

```powershell
# Get password policy configuration
$PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
$PasswordPolicy | Format-List

# Get domain settings
$DomainSettings = Get-ADConfig -Section "DomainSettings"
$DomainSettings | Format-List

# Get display preferences
$DisplaySettings = Get-ADConfig -Section "Display"
$DisplaySettings | Format-List
```

### Get Specific Values

```powershell
# Get minimum password length
$MinLength = Get-ADConfig -Section "PasswordPolicy" -Key "MinimumLength"
Write-Host "Minimum password length: $MinLength"

# Get domain name
$DomainName = Get-ADConfig -Section "DomainSettings" -Key "DomainName"
Write-Host "Domain name: $DomainName"

# Get progress bar style
$ProgressStyle = Get-ADConfig -Section "Display" -Key "ProgressBarStyle"
Write-Host "Progress bar style: $ProgressStyle"
```

### Configuration Validation

```powershell
# Check if password policy is configured
$PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
if ($PasswordPolicy.MinimumLength -ge 8) {
    Write-Host "Password policy is secure" -ForegroundColor Green
} else {
    Write-Host "Password policy needs improvement" -ForegroundColor Yellow
}

# Validate domain settings
$DomainSettings = Get-ADConfig -Section "DomainSettings"
if ($DomainSettings.DomainName -and $DomainSettings.Departments) {
    Write-Host "Domain settings are complete" -ForegroundColor Green
} else {
    Write-Host "Domain settings are incomplete" -ForegroundColor Red
}
```

### Integration with Other Functions

```powershell
# Use configuration in password validation
$PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
$TestPassword = "TestPass123!"

$Validation = Test-ADPasswordComplexity -Password $TestPassword -Config $PasswordPolicy
if ($Validation.IsValid) {
    Write-Host "Password meets policy requirements" -ForegroundColor Green
} else {
    Write-Host "Password validation failed:" -ForegroundColor Red
    foreach ($Issue in $Validation.Issues) {
        Write-Host "  - $Issue" -ForegroundColor Red
    }
}
```

## Configuration Sections

### PasswordPolicy
Contains password complexity and security settings:
- `MinimumLength` (Int32) - Minimum password length
- `MaximumLength` (Int32) - Maximum password length
- `RequireUppercase` (Boolean) - Require uppercase letters
- `RequireLowercase` (Boolean) - Require lowercase letters
- `RequireNumbers` (Boolean) - Require numeric characters
- `RequireSpecialCharacters` (Boolean) - Require special characters

### DomainSettings
Contains domain and organizational information:
- `DomainName` (String) - Primary domain name
- `Departments` (Array) - List of valid departments
- `DefaultDepartment` (String) - Default department for new users

### Display
Contains user interface preferences:
- `ProgressBarStyle` (String) - Progress bar display style
- `StatusMessageStyle` (String) - Status message formatting
- `ColorScheme` (String) - Color scheme for output

## Error Handling

### Invalid Section
```powershell
# Returns null for invalid sections
$InvalidSection = Get-ADConfig -Section "InvalidSection"
# Returns $null
```

### Invalid Key
```powershell
# Returns null for invalid keys
$InvalidKey = Get-ADConfig -Section "PasswordPolicy" -Key "InvalidKey"
# Returns $null
```

### Missing Configuration File
```powershell
# Handles missing configuration gracefully
# Creates default configuration if file doesn't exist
Get-ADConfig -ShowAll
```

## Performance Considerations

### Caching
- Configuration is cached after first read
- Subsequent calls are fast
- Cache is refreshed when configuration changes

### Memory Usage
- Configuration objects are lightweight
- Minimal memory impact
- Efficient for repeated access

## Related Functions

- **Set-ADConfig** - Update configuration settings
- **Test-ADConfig** - Validate configuration integrity
- **Test-ADPasswordComplexity** - Validate passwords against policy
- **Show-ADProgress** - Use display configuration

## Notes

- Configuration is stored in JSON format
- Default configuration is created if none exists
- Configuration is validated on load
- Changes require module reload to take effect
- Configuration supports nested objects and arrays

## See Also

- [PowerShell Configuration Management](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines#support-configuration)
- [JSON Configuration Files](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines#support-configuration) 