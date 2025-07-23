# Function Documentation

This directory contains comprehensive documentation for each function in the CSVActiveDirectory module.

## Purpose

The `Docs/Functions` directory provides detailed, developer-friendly documentation for all public functions in the module. Each function has its own markdown file with complete information about:

- **Syntax and Parameters** - Complete parameter descriptions with types and validation
- **Return Values** - What the function returns and in what format
- **Examples** - Practical usage examples from basic to advanced
- **Error Handling** - How the function handles errors and edge cases
- **Performance Considerations** - When to use which approach
- **Related Functions** - Links to other related functions
- **Notes and Best Practices** - Important implementation details

## File Naming Convention

Each documentation file follows the pattern: `{FunctionName}.md`

Examples:
- `Get-ADUser.md` - Documentation for Get-ADUser function
- `New-ADUser.md` - Documentation for New-ADUser function
- `Enable-ADAccount.md` - Documentation for Enable-ADAccount function

## Documentation Structure

Each function documentation file includes:

### 1. Overview
Brief description of what the function does and its purpose.

### 2. Syntax
Complete syntax with all parameter sets and common parameters.

### 3. Parameters
Detailed parameter descriptions including:
- Type information
- Required/Optional status
- Validation rules
- Examples
- Default values

### 4. Return Values
What the function returns, including:
- Object types
- Property descriptions
- Data formats
- Examples of return values

### 5. Examples
Practical examples showing:
- Basic usage
- Advanced scenarios
- Error handling
- Best practices

### 6. Performance Considerations
Guidance on when and how to use the function efficiently.

### 7. Error Handling
How the function handles various error conditions.

### 8. Related Functions
Links to other functions that work with or complement this function.

### 9. Notes
Important implementation details, limitations, and best practices.

## Available Documentation

### Core AD Functions
- [Get-ADUser.md](Get-ADUser.md) - Query users with Identity or Filter parameters
- [New-ADUser.md](New-ADUser.md) - Create new user accounts with validation
- [Remove-ADUser.md](Remove-ADUser.md) - Delete user accounts
- [Enable-ADAccount.md](Enable-ADAccount.md) - Enable user accounts
- [Disable-ADAccount.md](Disable-ADAccount.md) - Disable user accounts
- [Set-ADAccountPassword.md](Set-ADAccountPassword.md) - Set user passwords

### Configuration Management
- [Get-ADConfig.md](Get-ADConfig.md) - Read configuration settings
- [Set-ADConfig.md](Set-ADConfig.md) - Update configuration settings

### Progress & Status
- [Show-ADProgress.md](Show-ADProgress.md) - Display progress indicators
- [Show-ADStatus.md](Show-ADStatus.md) - Color-coded status messages

## Contributing

When adding new functions to the module:

1. **Create Documentation** - Add a corresponding `.md` file in this directory
2. **Follow Structure** - Use the standard documentation structure
3. **Include Examples** - Provide practical, working examples
4. **Update This README** - Add the new function to the list above
5. **Cross-Reference** - Link to related functions in the documentation

## Benefits

This documentation provides:

- **Developer Onboarding** - New developers can quickly understand function capabilities
- **API Reference** - Complete parameter and return value information
- **Best Practices** - Guidance on efficient and correct usage
- **Troubleshooting** - Error handling and common issues
- **Integration** - How functions work together

## Usage

These documentation files are designed to be:

- **Readable** - Clear, concise explanations
- **Searchable** - Well-structured for quick reference
- **Comprehensive** - Complete information for each function
- **Practical** - Real-world examples and scenarios

## See Also

- [Module README](../README.md) - Overall module documentation
- [Examples](../Examples/) - Working example scripts
- [Tests](../Tests/) - Unit and integration tests 