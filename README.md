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
- **Backup System** - Automatic database backups with timestamped files and ZIP compression

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
.\install.ps1
```

#### Manual Installation:
```powershell
# Clone or download the module
# Navigate to the module directory
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
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
- **Cross-version emoji compatibility** (PowerShell 5.1+ and 7+)

### 🔍 Security & IoC Analysis
- **`Get-UserThreatAnalysis.ps1`** - Individual user threat analysis with interactive HTML reports
- **`Get-SecurityReport.ps1`** - Enterprise security reports with enhanced IoC detection
- **`Queries.ps1`** - Individual security queries for focused analysis
- **Professional HTML reports** with clickable IoC items and collapsible categories
- **Color-coded severity levels** and actionable recommendations
- **Individual user reports** stored in `Data/Reports/` directory

### 🧹 Database Management
- **`Cleanup-Backups.ps1`** - Comprehensive backup management with age-based deletion
- **`Manage-Backups.ps1`** - Console menu for enhanced database management to create backups, list backups, cleanup backups, etc.
- **Automatic backup system** with timestamped files and ZIP compression
- **Disk space management** with safety features and confirmation prompts

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
.\install.ps1

# Option 2: Create users manually
.\Functions\Private\Create-Users.ps1

# Option 3: Create users with custom settings
.\Functions\Private\Create-Users.ps1 -UserCount 200 -RiskPercentage 25
```

**Why is this necessary?**
- The repository comes with an empty database for security
- User creation populates the database with realistic test data
- Includes cybersecurity risk scenarios for security analysis
- Enables all module functionality (IoC detection, security reports, etc.)

## 📁 Project Structure

```
CSVActiveDirectory/
├── 📄 Core Files
│   ├── CSVActiveDirectory.psd1          # Module manifest
│   ├── CSVActiveDirectory.psm1          # Module script
│   ├── install.ps1                      # One-click installer
│   ├── README.md                        # This file
│   ├── CHANGELOG.md                     # Version history
│   └── LICENSE                          # License information
│
├── 📁 Scripts/                          # Main script directory
│   ├── Create-Users-Menu.ps1           # Interactive user creation menu
│   ├── Create-Users.ps1                 # User generation with security scenarios (Private)
│   ├── Get-UserThreatAnalysis.ps1                     # Individual user IoC analysis
│   ├── Get-SecurityReport.ps1                 # Enterprise security reports
│   ├── Queries.ps1                      # Security query examples
│   ├── Cleanup-Backups.ps1              # Backup management utility
│   └── Test-ModuleFunctions.ps1         # Module function testing
│
├── 📁 Functions/                        # Module functions
│   ├── Public/                          # Public cmdlets
│   │   ├── Get-ADUser.ps1
│   │   ├── New-ADUser.ps1
│   │   ├── Remove-ADUser.ps1
│   │   ├── Enable-ADAccount.ps1
│   │   ├── Disable-ADAccount.ps1
│   │   ├── Search-ADAccount.ps1
│   │   ├── Get-ADConfig.ps1
│   │   ├── Show-ADProgress.ps1
│   │   ├── Show-ADStatus.ps1
│   │   └── Set-ADAccountPassword.ps1
│   └── Private/                         # Internal functions
│       ├── ConvertTo-ADPasswordHash.ps1
│       ├── Get-ADPasswordPolicy.ps1
│       ├── Test-ADPassword.ps1
│       └── Test-ADPasswordComplexity.ps1
│
├── 📁 Data/                             # Data storage
│   │   ├── Database/                        # Database files
│   │   ├── Backups/
│   │   │   └──  DatabaseBackups.zip
│   │   ├── Database.csv                 # Current database
│   │   └── example-database.csv
│   ├── Config/                          # Configuration
│   │   └── Settings.json
│   └── Formats/                         # Display formats
│       └── ADUser.format.ps1xml
│
├── 📁 Examples/                         # Usage examples
│   ├── Basic/
│   │   └── Demo-BasicFeatures.ps1
│   └── Advanced/
│       ├── Demo-EnhancedFeatures.ps1
│       ├── Demo-AccountScenarios.ps1
│       └── Demo-DetectionQueries.ps1
│
├── 📁 Tests/                            # Test scripts
│   ├── Integration/
│   │   ├── Module.Tests.ps1
│   │   └── User-Lifecycle.Tests.ps1
│   └── Functions/
│       ├── Configuration-Management.Tests.ps1
│       ├── Enable-Disable-ADAccount.Tests.ps1
│       ├── Get-ADUser.Tests.ps1
│       ├── New-ADUser.Tests.ps1
│       ├── Remove-ADUser.Tests.ps1
│       ├── Search-ADAccount.Tests.ps1
│       └── Test-ADPasswordComplexity.Tests.ps1
│
└── 📁 Docs/                             # Documentation
    ├── Functions/                       # Function documentation
    ├── Active-Directory-Cybersecurity-Guide.md
    ├── CSV-Export-Guide.md
    ├── Cybersecurity-Scenarios.md
    ├── Enhanced-IoC-Detection.md
    ├── IoC-Analysis-Guide.md
    └── SETUP.md
```

## 📊 Available Scripts

### Public Scripts (User-Friendly)
Located in `Scripts/Public/` - Interactive scripts with menus for end users:

- **`Create-Users-Menu.ps1`** - Interactive menu for user database creation
- **`Get-UserThreatAnalysis.ps1`** - Individual user IoC analysis with interactive HTML reports
- **`Get-SecurityReport.ps1`** - Enterprise security reports with enhanced IoC detection
- **`Manage-Backups.ps1`** - Interactive backup management with menu options

### Private Scripts (Advanced)
Located in `Scripts/Private/` - Internal scripts for system administration:

- **`Create-Users.ps1`** - Generate test database with cybersecurity scenarios (Advanced)
- **`Test-ModuleFunctions.ps1`** - Test all module functions for compatibility
- **`Test-PasswordComplexity.ps1`** - Password complexity testing utility
- **`Cleanup-Backups.ps1`** - Advanced backup cleanup with direct parameter control

### Installation
- **`install.ps1`** - One-click installation with module setup and database creation

## 🎯 Quick Start

### Step 1: Create Users (Required)
```powershell
# Create users with default settings (150 users, 30% risk)
.\Functions\Private\Create-Users.ps1

# Or use the one-click installer
.\install.ps1
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
.\Scripts\Public\Get-UserThreatAnalysis.ps1 -Username "username"

# Generate professional HTML report
.\Scripts\Public\Get-UserThreatAnalysis.ps1 -Username "username" -ExportReport /path/to/export/to

# Enterprise security report with enhanced IoC detection
.\Scripts\Public\Get-SecurityReport.ps1
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

### Database Management
```powershell
# Interactive backup management (recommended for end users)
.\Scripts\Public\Manage-Backups.ps1



# Advanced backup cleanup (for administrators)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7

# Preview what would be deleted
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7 -WhatIf

# Delete all backup files (with confirmation)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAll

# Delete all backup files (no confirmation)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAll -Force
```

## 📊 Available Properties

### Core Properties (Default)
- `FirstName`, `LastName`, `DisplayName`, `SamAccountName`

### Extended Properties (with `-Properties *`)
- `DistinguishedName`, `EmailAddress`, `EmpID`, `Title`, `Department`
- `Guid`, `Created`, `Modified`, `Enabled`, `UserPrincipalName`
- `SID`, `PrimaryGroupID`, `PasswordLastSet`, `LastLogon`

## 🔧 Compatibility

### PowerShell Versions
- **PowerShell 5.1**: Full compatibility with ASCII emoji alternatives
- **PowerShell 7+**: Full compatibility with Unicode emoji support
- **Automatic Detection**: Scripts automatically detect PowerShell version
- **Cross-Platform**: Works on Windows, Linux, and macOS

### Features by Version
| Feature | PowerShell 5.1 | PowerShell 7+ |
|---------|----------------|---------------|
| Unicode Emojis | ASCII alternatives | Full Unicode support |
| Null Coalescing | Explicit if/else | `??` operator |
| HTML Reports | ✅ | ✅ |
| IoC Detection | ✅ | ✅ |
| Database Operations | ✅ | ✅ |

## 📈 Testing Results

**Comprehensive testing completed with 100% compatibility:**
- **35 scripts tested** across both PowerShell versions
- **PowerShell 5.1**: 35/35 scripts pass ✅
- **PowerShell 7+**: 35/35 scripts pass ✅
- **Performance**: < 30 seconds for IoC analysis of 1000+ users
- **HTML Reports**: Interactive with clickable IoC items and collapsible sections

See the test files in the `Tests/`
