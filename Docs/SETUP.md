# CSVActiveDirectory Setup Guide

## 🚀 Quick Setup (After Cloning)

### Step 1: Clone the Repository
```bash
git clone https://gitlab.com/ma1c0ntent/CSVActiveDirectory.git
cd CSVActiveDirectory
```

### Step 2: Create Users (REQUIRED)
The repository comes with an empty database for security. You must create users to enable all functionality:

```powershell
# Option 1: One-click installer (RECOMMENDED)
.\install.ps1

# Option 2: Manual user creation
.\Functions\Private\Create-Users.ps1

# Option 3: Custom user creation
.\Functions\Private\Create-Users.ps1 -UserCount 200 -RiskPercentage 25

# Option 4: Create users with backup (recommended for production)
.\Functions\Private\Create-Users.ps1 -BackupExisting
```

### Step 3: Verify Installation
```powershell
# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

# Test basic functionality
Get-ADUser -Identity "*" | Select-Object -First 3
```

## ⚠️ Why User Creation is Required

1. **Security**: Repository contains empty database to prevent data exposure
2. **Functionality**: All features require populated database
3. **Testing**: Realistic data enables proper testing
4. **Analysis**: Security scenarios require user data

## 🔧 Installation Options

### Standard Installation
```powershell
.\install.ps1
```
- Creates 150 users with 30% risk scenarios
- Runs security assessment
- Tests all functionality

### Custom Installation
```powershell
# Skip user creation (advanced users only)
.\install.ps1 -SkipDatabase

# Skip security test
.\install.ps1 -SkipSecurityTest

# Manual user creation with custom settings
.\Functions\Private\Create-Users.ps1 -UserCount 100 -RiskPercentage 20
```

### Manual Setup
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Import module
Import-Module .\CSVActiveDirectory.psd1 -Force

# Create users
.\Functions\Private\Create-Users.ps1

# Test functionality
Get-ADUser -Identity "*" | Measure-Object
```

## 📊 What Gets Created

### User Database
- **Default**: 150 users with realistic data
- **Risk Scenarios**: 30% of users have security issues
- **Departments**: IT, Security, HR, Finance, Marketing, Sales, Engineering, Operations
- **Data**: Names, emails, titles, departments, login history, security flags

### Security Scenarios
- Failed password attempts
- Suspicious login patterns
- Privileged account issues
- Service account problems
- Lateral movement indicators

## 🎯 Post-Setup Verification

### Test Basic Functions
```powershell
# List all users
Get-ADUser -Identity "*" | Select-Object -First 5

# Test filtering
Get-ADUser -Filter "Department -eq 'Security'"

# Test individual user
Get-ADUser -Identity "bfoster" -Properties *
```

### Test Security Features
```powershell
# Individual IoC analysis
.\Scripts\Get-IOCs.ps1 -Username "jmorales"

# Enterprise security report
.\Scripts\Public\Get-SecurityReport.ps1 -EnhancedIoCDetection
```

### Test User Management
```powershell
# Create a test user
New-ADUser -FirstName "Test" -LastName "User" -EmailAddress "test@adnauseumgaming.com" -Department "IT"

# Disable/Enable account
Disable-ADAccount -Identity "testuser"
Enable-ADAccount -Identity "testuser"

# Remove test user
Remove-ADUser -Identity "testuser" -Confirm:$false
```

## 🔍 Troubleshooting

### Common Issues

**No users found after setup:**
```powershell
# Check if database exists
Test-Path "Data\Database\Database.csv"

# Recreate users if needed
.\Scripts\Private\Create-Users.ps1
```

**Module not found:**
```powershell
# Check current directory
Get-Location

# Import module manually
Import-Module .\CSVActiveDirectory.psd1 -Force
```

**Execution policy error:**
```powershell
# Set execution policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

## 📚 Next Steps

After successful setup:

1. **Read the README.md** for comprehensive usage guide
2. **Explore Examples/** for sample scripts
3. **Run Tests/** to verify functionality
4. **Check Docs/** for detailed documentation
5. **Try Security Analysis** with IoC detection

## 💾 Backup Management

The module includes automatic backup functionality:

### Creating Backups
```powershell
# Create users with automatic backup
.\Scripts\Private\Create-Users.ps1 -BackupExisting

# Backup files are automatically compressed to save space
# Files: Database.backup.YYYYMMDD-HHMMSS.zip
```

### Managing Backups
```powershell
# View all backup files
.\Scripts\Private\Cleanup-Backups.ps1

# Delete backups older than 7 days
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7

# Delete all backups (with confirmation)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAll
```