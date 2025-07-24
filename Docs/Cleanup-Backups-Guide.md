# Cleanup-Backups Script Guide

## Overview

The `Cleanup-Backups.ps1` script is designed to manage backup database files created by the CSVActiveDirectory module. It helps prevent disk space issues by removing old backup files while providing safe, controlled deletion options.

## Features

### 🔍 **Smart Detection**
- Automatically finds all backup files matching the pattern `Database.backup.*.csv`
- Displays file age, size, and creation time for informed decisions
- Sorts files by creation date for easy review

### 🛡️ **Safety Features**
- **Dry Run Mode**: Default behavior shows what would be deleted without actually deleting
- **WhatIf Support**: Use `-WhatIf` to preview deletions without executing
- **Confirmation Prompts**: Interactive confirmation before deletion (unless `-Force` is used)
- **Error Handling**: Graceful error handling for file deletion failures

### 📊 **Detailed Reporting**
- Shows total files found and their details
- Displays files that will be deleted with age and size information
- Reports total disk space that will be freed
- Shows remaining files after cleanup

## Usage Examples

### Basic Usage (Dry Run)
```powershell
.\Scripts\Cleanup-Backups.ps1
```
Shows all backup files and available options without deleting anything.

### Age-Based Cleanup
```powershell
# Delete files older than 7 days
.\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 7

# Delete files older than 30 days
.\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 30
```

### Delete All Backups
```powershell
# Delete all backup files (with confirmation)
.\Scripts\Cleanup-Backups.ps1 -DeleteAll

# Delete all backup files (no confirmation)
.\Scripts\Cleanup-Backups.ps1 -DeleteAll -Force
```

### Preview Mode
```powershell
# Show what would be deleted without actually deleting
.\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 7 -WhatIf
```

### Custom Backup Path
```powershell
# Clean up backups in a custom location
.\Scripts\Cleanup-Backups.ps1 -BackupPath "C:\Custom\Backups" -DeleteAfterDays 7
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-BackupPath` | string | `"Data\Database"` | Path to backup directory |
| `-DeleteAfterDays` | int | `0` | Delete files older than specified days |
| `-DeleteAll` | switch | `$false` | Delete all backup files |
| `-WhatIf` | switch | `$false` | Show what would be deleted without deleting |
| `-Force` | switch | `$false` | Skip confirmation prompts |

## Safety Recommendations

### 🚨 **Best Practices**
1. **Always use `-WhatIf` first** to preview what will be deleted
2. **Start with age-based cleanup** rather than deleting all files
3. **Use reasonable time periods** (7-30 days) for age-based deletion
4. **Keep recent backups** for emergency recovery

### 📅 **Recommended Schedule**
- **Weekly**: `-DeleteAfterDays 7` to keep recent backups
- **Monthly**: `-DeleteAfterDays 30` for longer-term cleanup
- **Quarterly**: Review and manually clean up very old backups

### 🔧 **Automation Tips**
```powershell
# Add to scheduled task for weekly cleanup
.\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 7 -Force

# Add to PowerShell profile for manual cleanup
function Cleanup-Backups { .\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 7 }
```

## Output Examples

### Dry Run Mode
```
=== CSVActiveDirectory Backup Cleanup ===
Cleaning up backup database files...

ℹ Found 31 backup files

=== CURRENT BACKUP FILES ===
  Database.backup.20250723-121928.csv (1 hours ago, 76648 bytes)
  Database.backup.20250723-122516.csv (1 hours ago, 76555 bytes)
  ...

ℹ DRY RUN MODE: No files will be deleted (use -DeleteAll or -DeleteAfterDays)
Available options:
  -DeleteAll                    # Delete all backup files
  -DeleteAfterDays 7           # Delete files older than 7 days
  -WhatIf                       # Show what would be deleted without actually deleting
  -Force                        # Skip confirmation prompts
```

### Age-Based Cleanup
```
ℹ AGE-BASED CLEANUP: Files older than 7 days will be deleted
Cutoff date: 2025-07-16 14:06:18

=== FILES TO BE DELETED ===
  Database.backup.20250715-121928.csv (8 days ago, 76648 bytes)
  Database.backup.20250715-122516.csv (8 days ago, 76555 bytes)

Total files to delete: 2
Total size to free: 153.20 KB

WARNING: This action cannot be undone!
Are you sure you want to delete these files? (y/N): y

=== DELETING FILES ===
❌ Deleted: Database.backup.20250715-121928.csv
❌ Deleted: Database.backup.20250715-122516.csv

=== CLEANUP COMPLETE ===
✅ Successfully deleted 2 files
✅ Freed up 153.20 KB of disk space
```

## Troubleshooting

### Common Issues

**"Backup path not found"**
- Ensure the backup directory exists
- Check the `-BackupPath` parameter value

**"No backup files found"**
- Verify backup files match the pattern `Database.backup.*.csv`
- Check the backup directory path

**"Permission denied"**
- Run PowerShell as Administrator
- Check file permissions on backup directory

### File Pattern
The script looks for files matching: `Database.backup.*.csv`

This matches the backup files created by the `Create-Users.ps1` script when `-BackupExisting` is used.

## Integration

### With Scheduled Tasks
```powershell
# Create a scheduled task for weekly cleanup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -Command `"& 'C:\Path\To\Scripts\Cleanup-Backups.ps1' -DeleteAfterDays 7 -Force`""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2AM
Register-ScheduledTask -TaskName "CSVActiveDirectory Backup Cleanup" -Action $Action -Trigger $Trigger
```

### With PowerShell Profile
```powershell
# Add to PowerShell profile for quick access
function Cleanup-Backups { .\Scripts\Cleanup-Backups.ps1 -DeleteAfterDays 7 }
```

## Version Compatibility

- **PowerShell 5.1**: ✅ Fully supported
- **PowerShell 7+**: ✅ Fully supported
- **Emoji Support**: ✅ Compatible with both versions
- **Parameter Splatting**: ✅ Reliable parameter passing

## Related Scripts

- **`Create-Users.ps1`**: Creates backup files that this script cleans up
- **`install.ps1`**: Uses backup functionality during installation
- **`Get-SecurityReport.ps1`**: May create additional backup files 