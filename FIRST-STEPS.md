# 🚀 Welcome to CSVActiveDirectory!

## ⚠️ IMPORTANT: Create Users After Cloning

This repository comes with an **empty database** for security reasons. You **must create users** to enable all functionality.

### Quick Start (Choose One):

```powershell
# Option 1: One-click installer (RECOMMENDED)
.\INSTALL.ps1

# Option 2: Manual user creation
.\Scripts\Create-Users.ps1

# Option 3: Custom settings
.\Scripts\Create-Users.ps1 -UserCount 200 -RiskPercentage 25
```

### Why is this required?
- **Security**: Empty database prevents data exposure
- **Functionality**: All features need populated database
- **Testing**: Realistic data enables proper testing
- **Analysis**: Security scenarios require user data

### What gets created?
- 150 realistic users with comprehensive data
- 30% of users have cybersecurity risk scenarios
- Departments: IT, Security, HR, Finance, Marketing, Sales, Engineering, Operations
- Security scenarios for IoC detection and analysis

### After creating users:
```powershell
# Import module
Import-Module .\CSVActiveDirectory.psd1 -Force

# Test functionality
Get-ADUser -Identity "*" | Select-Object -First 3

# Try security analysis
.\Scripts\Get-IOCs.ps1 -Username "jmorales"
```

### Need help?
- Read `README.md` for comprehensive guide
- Check `Docs/SETUP.md` for detailed setup instructions
- Review `Docs/` for function documentation

---

**Ready to start?** Run `.\INSTALL.ps1` now! 