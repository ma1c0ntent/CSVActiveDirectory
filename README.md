# CSVActiveDirectory PowerShell Module

A comprehensive PowerShell module that simulates Active Directory functionality using CSV files as a backend database. This module provides a realistic AD experience for learning, testing, and development purposes.

## 🚀 Features

### Core AD Functions
- **Get-ADUser** - Retrieve user information with filtering and property selection
- **New-ADUser** - Create new user accounts with comprehensive data
- **Remove-ADUser** - Delete user accounts with confirmation
- **Enable-ADAccount** - Enable disabled user accounts
- **Disable-ADAccount** - Disable active user accounts

- **Learn AD concepts** without setting up a domain controller
- **Test AD scripts** in a safe, isolated environment
- **Practice PowerShell** with realistic AD cmdlets
- **Develop AD automation** with full feature support
- **Train teams** on AD management without production risks

### Database Features
- **CSV Backend** - Simple, portable data storage
- **Realistic Data** - Authentic user information and scenarios
- **Data Integrity** - Consistent data across all operations
- **Backup System** - Automatic database backups

### 🔧 Core AD Functions
- **`Get-ADUser`** - Query users with Identity or Filter parameters
- **`New-ADUser`** - Create new user accounts with validation
- **`Remove-ADUser`** - Delete user accounts
- **`Enable-ADAccount`** - Enable user accounts
- **`Disable-ADAccount`** - Disable user accounts
- **`Set-ADAccountPassword`** - Set user passwords with complexity validation

### 🛠️ Configuration Management
- **`Get-ADConfig`** - Read configuration settings
- **`Set-ADConfig`** - Update configuration settings
- **`Test-ADConfig`** - Validate configuration integrity

### 🚀 Quick Install (5 Minutes)

#### From GitLab:
```powershell
# Clone the repository
git clone https://gitlab.com/ma1c0ntent/CSVActiveDirectory.git
cd CSVActiveDirectory

# One-click installation
.\INSTALL.ps1
```

#### Manual Installation:
```powershell
# Clone or download the module
# Navigate to the module directory
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Scripts\Install-Module.ps1
```

### 📊 Progress & Status
- **`Show-ADProgress`** - Display progress indicators
- **`Start-ADOperation`** - Initialize operations
- **`Update-ADOperation`** - Update operation progress
- **`Complete-ADOperation`** - Finalize operations
- **`Show-ADBulkProgress`** - Bulk operations with error tracking
- **`Show-ADStatus`** - Color-coded status messages

### 🎨 Enhanced Display
- **Custom format files** for better output
- **Professional table views** with proper formatting
- **Detailed list views** with complete information
- **Color-coded status** indicators

### 🔍 Security & IoC Analysis
- **`Get-IOCs.ps1`** - Individual user threat analysis
- **Professional HTML reports** with detailed IoC detection
- **Enhanced IoC detection** for enterprise security reports
- **Color-coded severity levels** and actionable recommendations

## 🚀 Getting Started

### Installation

```powershell
# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

# Verify installation
Get-Command -Module CSVActiveDirectory
```

### ⚠️ Important: Create Users After Cloning

**After cloning the repository, you must create users to populate the database:**

```powershell
# Option 1: Use the one-click installer (recommended)
.\INSTALL.ps1

# Option 2: Create users manually
.\Scripts\Create-Users.ps1

# Option 3: Create users with custom settings
.\Scripts\Create-Users.ps1 -UserCount 200 -RiskPercentage 25
```

**Why is this necessary?**
- The repository comes with an empty database for security
- User creation populates the database with realistic test data
- Includes cybersecurity risk scenarios for security analysis
- Enables all module functionality (IoC detection, security reports, etc.)

## 🎯 Quick Start

### Step 1: Create Users (Required)
```powershell
# Create users with default settings (150 users, 30% risk)
.\Scripts\Create-Users.ps1

# Or use the one-click installer
.\INSTALL.ps1
```

### Step 2: Basic Usage
```powershell
# Get all users
Get-ADUser -Identity "*"

# Get specific user
Get-ADUser -Identity "mbryan"

# Get users with specific properties
Get-ADUser -Identity "mbryan" -Properties "Department", "Title", "Enabled"

# Filter users
Get-ADUser -Filter "Department -eq 'Security'"
```

### Security Analysis
```powershell
# Individual user IoC analysis
.\Scripts\Get-IOCs.ps1 -Username "username"

# Generate professional HTML report
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport /path/to/export/to

# Enterprise security report with enhanced IoC detection
.\Scripts\Get-ADSecurityReport-Enterprise.ps1
```

### Creating Users
```powershell
# Create a new user
New-ADUser -SamAccountName "jdoe" -FirstName "John" -LastName "Doe" -EmailAddress "jdoe@company.com" -Department "IT" -Title "Developer"

# Create user with password
New-ADUser -SamAccountName "asmith" -FirstName "Alice" -LastName "Smith" -EmailAddress "asmith@company.com" -Department "HR" -Title "Manager" -Password "SecurePass123!"
```

### Account Management
```powershell
# Disable an account
Disable-ADAccount -Identity "jdoe"

# Enable an account
Enable-ADAccount -Identity "jdoe"

# Remove a user
Remove-ADUser -Identity "jdoe" -Confirm:$false
```

## 📊 Available Properties

### Core Properties (Default)
- `FirstName`, `LastName`, `DisplayName`, `SamAccountName`

### Extended Properties (with `-Properties *`)
- `DistinguishedName`, `EmailAddress`, `EmpID`, `Title`, `Department`
- `Guid`, `Created`, `Modified`, `Enabled`, `UserPrincipalName`
- `SID`, `PrimaryGroupID`, `PasswordLastSet`, `LastLogon`
- `AccountExpires`, `LockoutTime`, `LogonCount`, `BadPasswordCount`
- `PasswordNeverExpires`, `CannotChangePassword`, `SmartCardRequired`
- `Manager`, `Office`, `PhoneNumber`, `Mobile`, `Company`

## 🎨 Format Views

### Default Table View
Shows: `DisplayName`, `SamAccountName`, `FirstName`, `LastName`

### Extended Table View (with `-Properties *`)
Shows: `Name`, `SamAccountName`, `EmailAddress`, `Department`, `Title`, `Enabled`

### List Views
- **Normal**: Core properties in list format
- **Extended**: All properties in detailed list format

## 🔧 Configuration

### Settings.json
```json
{
  "Database": {
    "Path": "Data/Database/Database.csv",
    "BackupPath": "Data/Database/Database.backup.csv"
  },
  "DefaultValues": {
    "DefaultDepartment": "Security",
    "DefaultTitle": "Employee",
    "DefaultCompany": "AdNauseum Gaming"
  },
  "PasswordPolicy": {
    "MinimumLength": 8,
    "RequireUppercase": true,
    "RequireLowercase": true,
    "RequireNumbers": true,
    "RequireSpecialChars": true
  }
}
```

## 🧪 Testing

### Run All Tests
```powershell
Invoke-Pester -Path "Tests" -Output Detailed
```

### Run Specific Test Categories
```powershell
# Function tests
Invoke-Pester -Path "Tests/Functions" -Output Detailed

# Integration tests
Invoke-Pester -Path "Tests/Integration" -Output Detailed
```

### Test Individual Functions
```powershell
# Test Get-ADUser
Invoke-Pester -Path "Tests/Functions/Get-ADUser.Tests.ps1"

# Test New-ADUser
Invoke-Pester -Path "Tests/Functions/New-ADUser.Tests.ps1"
```

## 📁 Module Structure

```
CSVActiveDirectory/
├── CSVActiveDirectory.psd1          # Module manifest
├── CSVActiveDirectory.psm1          # Root module
├── Functions/
│   ├── Public/                     # Exported functions
│   │   ├── Get-ADUser.ps1
│   │   ├── New-ADUser.ps1
│   │   ├── Remove-ADUser.ps1
│   │   ├── Enable-ADAccount.ps1
│   │   └── Disable-ADAccount.ps1
│   └── Private/                    # Internal functions
│       ├── Test-ADPasswordComplexity.ps1
│       ├── Test-ADPassword.ps1
│       ├── Get-ADPasswordPolicy.ps1
│       └── ConvertTo-ADPasswordHash.ps1
├── Data/
│   ├── Database/
│   │   ├── Database.csv            # Main database
│   │   └── Database.backup.csv     # Backup database
│   ├── Config/
│   │   └── Settings.json           # Configuration
│   └── Formats/
│       └── ADUser.format.ps1xml    # Custom formats
├── Tests/
│   ├── Functions/                  # Unit tests
│   └── Integration/                # Integration tests
├── Scripts/                        # Utility scripts
├── Examples/                       # Example scripts
└── Docs/                          # Documentation
    ├── SETUP.md                   # Setup guide
    ├── IoC-Analysis-Guide.md      # IoC analysis documentation
    ├── CSV-Export-Guide.md        # Export functionality guide
    ├── Enhanced-IoC-Detection.md  # Enhanced IoC detection
    ├── Cybersecurity-Scenarios.md # Security scenarios
    ├── Active-Directory-Cybersecurity-Guide.md # Main security guide
    └── Functions/                 # Function documentation
```

## 🔍 Examples

### Advanced Filtering
```powershell
# Find all users in Security department
Get-ADUser -Filter "Department -eq 'Security'" -Properties *

# Find disabled accounts
Get-ADUser -Filter "Enabled -eq 'FALSE'" -Properties *

# Find users with specific title
Get-ADUser -Filter "Title -eq 'Manager'" -Properties *
```

### Bulk Operations
```powershell
# Get all users and format as table
Get-ADUser -Identity "*" -Properties * | Format-Table

# Get all users and format as list
Get-ADUser -Identity "*" -Properties * | Format-List

# Export users to CSV
Get-ADUser -Identity "*" -Properties * | Export-Csv -Path "users.csv" -NoTypeInformation
```

### Account Scenarios
```powershell
# Run account scenario simulation
.\Scripts\Simulate-AccountScenarios.ps1

# Randomize database data
.\Scripts\Randomize-Database.ps1

# Enhance database with additional data
.\Scripts\Enhance-Database.ps1
```

## 📚 Documentation

### 🎯 Comprehensive Guides
- **[Setup Guide](Docs/SETUP.md)** - Complete setup instructions with user creation requirements
- **[Active Directory Cybersecurity Guide](Docs/Active-Directory-Cybersecurity-Guide.md)** - Complete guide combining cybersecurity scenarios and IoC detection patterns

### Function Documentation
- [Get-ADUser](Docs/Functions/Get-ADUser.md)
- [New-ADUser](Docs/Functions/New-ADUser.md)
- [Remove-ADUser](Docs/Functions/Remove-ADUser.md)
- [Enable-ADAccount](Docs/Functions/Enable-ADAccount.md)
- [Disable-ADAccount](Docs/Functions/Disable-ADAccount.md)

### Configuration
- [Settings Reference](Docs/Configuration/Settings.md)
- [Database Schema](Docs/Database/Schema.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues, questions, or contributions:
- Check the [documentation](Docs/)
- Review the [examples](Examples/)
- Run the test suite to verify functionality
- Submit an issue with detailed information

---

**Note**: This module simulates Active Directory functionality for educational and testing purposes. It is not intended for production use or as a replacement for actual Active Directory services.
