# Public Scripts

This directory contains user-friendly scripts with interactive menus designed for end users.

## Available Scripts

### Create-Users-Menu.ps1
Interactive menu-driven user creation with various database size options:
- Quick Test Database (30 users)
- Standard Database (100 users) 
- Large Database (250 users)
- Enterprise Database (500 users)
- Custom Configuration

### Get-SecurityReport.ps1
Interactive security reporting with menu options:
- Quick Security Scan (Basic report)
- Enhanced Security Scan (With IoC detection)
- Detailed Security Report (Full analysis)
- Export Security Report (CSV format)
- Custom Security Scan (Configure options)

### Get-UserThreatAnalysis.ps1
Interactive threat analysis with menu-driven options:
- Quick Threat Scan
- Enhanced Threat Analysis
- Detailed Threat Report
- Export Threat Analysis
- Custom Threat Analysis

### Manage-Backups.ps1
Interactive backup management with menu options:
- List Backups
- Create Backup
- Restore Backup
- Cleanup Configuration
- System Information



## Usage

All scripts in this directory are designed to be run directly by end users. They provide interactive menus and user-friendly prompts to guide you through the available options.

Example:
```powershell
.\Create-Users-Menu.ps1
```

## Requirements

- PowerShell 5.1 or higher
- CSVActiveDirectory module loaded
- Appropriate permissions for the operations being performed 