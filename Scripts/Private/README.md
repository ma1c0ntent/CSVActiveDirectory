# Private Scripts

This directory contains internal and advanced scripts for system administration and testing purposes.

## Available Scripts

### Create-Users.ps1
Advanced user creation script with comprehensive parameterization:
- Supports custom user counts, risk percentages, and output paths
- Includes backup options and security testing
- Designed for automated or batch operations
- Complex parameter handling for advanced use cases

### Test-ModuleFunctions.ps1
Internal module testing script:
- Tests all exported functions from the CSVActiveDirectory module
- Validates configuration, password, and user management functions
- Used for development and troubleshooting
- Comprehensive function validation

### Test-PasswordComplexity.ps1
Simple password complexity testing utility:
- Tests various password scenarios against policy
- Demonstrates password validation functionality
- Useful for testing password policies
- Basic utility for validation purposes

### Cleanup-Backups.ps1
Advanced backup cleanup script with direct parameter control:
- Age-based cleanup with configurable thresholds
- Size-based cleanup for disk space management
- Manual cleanup with safety confirmations
- Designed for automated or batch operations

## Usage

These scripts are intended for:
- System administrators
- Developers working on the module
- Advanced users who need direct parameter control
- Testing and validation purposes

Example:
```powershell
.\Create-Users.ps1 -UserCount 100 -RiskPercentage 25 -OutputPath "CustomDatabase.csv"
```

## Requirements

- PowerShell 5.1 or higher
- CSVActiveDirectory module loaded
- Administrative permissions for certain operations
- Understanding of PowerShell parameters and advanced usage

## Note

These scripts are not designed for general end-user consumption. They provide direct parameter control and may require advanced PowerShell knowledge to use effectively. 