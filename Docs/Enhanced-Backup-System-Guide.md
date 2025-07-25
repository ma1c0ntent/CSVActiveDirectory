# Backup System Guide

## Overview

The CSVActiveDirectory module includes a comprehensive backup system that supports both modern archive-based backups and legacy individual file management. This guide covers all backup operations, from creation to cleanup.

## 🆕 Enhanced Single Archive System (Recommended)

### Key Features

- **Single Archive**: All backups stored in one `DatabaseBackups.zip` file
- **Automatic Organization**: Timestamped backups automatically added to archive
- **Space Efficient**: Better compression and no duplicate file overhead
- **Easy Management**: Simple commands to list, create, and clean up backups
- **Backward Compatible**: Still supports legacy individual ZIP files

### Archive Structure

```
Data\Database\Backups\
└── DatabaseBackups.zip
    ├── Database.backup.20250724-203127.csv
    ├── Database.backup.20250724-203056.csv
    ├── Database.backup.20250724-203027.csv
    └── ... (additional backups)
```

## 🚀 Quick Start

### Creating Your First Backup

```powershell
# Create a backup using the new system
.\Scripts\Public\Manage-Backups.ps1 -CreateBackup

# Or use the Create-Users script (automatically uses new system)
.\Scripts\Private\Create-Users.ps1 -BackupExisting
```

### Listing Backups

```powershell
# List all backups in the archive
.\Scripts\Public\Manage-Backups.ps1 -List

# Show detailed backup information
.\Scripts\Public\Manage-Backups.ps1 -List -Detailed
```

### Cleaning Up Old Backups

```powershell
# Remove backups older than 7 days, keep newest 10
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -KeepCount 10

# Preview what would be removed
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -WhatIf

# Remove all backups (with confirmation)
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 0 -KeepCount 0
```

## 📋 Enhanced System Commands

### Manage-Backups.ps1

The primary backup management script with comprehensive features:

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-CreateBackup` | switch | `$false` | Create a new backup |
| `-List` | switch | `$false` | List all backups in archive |
| `-Detailed` | switch | `$false` | Show detailed backup information |
| `-Cleanup` | switch | `$false` | Remove old backups |
| `-KeepDays` | int | `7` | Keep backups newer than specified days |
| `-KeepCount` | int | `10` | Keep newest N backups |
| `-WhatIf` | switch | `$false` | Show what would be done without doing it |
| `-Force` | switch | `$false` | Skip confirmation prompts |

#### Examples

```powershell
# Create a backup
.\Scripts\Public\Manage-Backups.ps1 -CreateBackup

# List backups with details
.\Scripts\Public\Manage-Backups.ps1 -List -Detailed

# Clean up old backups
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -KeepCount 10

# Preview cleanup
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -WhatIf

# Force cleanup without confirmation
.\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -Force
```

## 🔄 Legacy Individual File System

### Cleanup-Backups.ps1

For backward compatibility and individual file management:

#### Features

- **Smart Detection**: Automatically finds all backup files matching patterns
- **Safety Features**: Dry run mode, confirmation prompts, error handling
- **Detailed Reporting**: Shows file age, size, and creation time
- **Flexible Cleanup**: Age-based or complete deletion options

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-BackupPath` | string | `"Data\Database"` | Path to backup directory |
| `-DeleteAfterDays` | int | `0` | Delete files older than specified days |
| `-DeleteAll` | switch | `$false` | Delete all backup files |
| `-WhatIf` | switch | `$false` | Show what would be deleted without deleting |
| `-Force` | switch | `$false` | Skip confirmation prompts |

#### Legacy Usage Examples

```powershell
# Basic usage (dry run)
.\Scripts\Private\Cleanup-Backups.ps1

# Delete files older than 7 days
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7

# Delete all backup files (with confirmation)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAll

# Preview mode
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7 -WhatIf
```

## 🔄 Migration from Legacy to Enhanced System

### Step-by-Step Migration

```powershell
# 1. Create first backup with new system
.\Scripts\Public\Manage-Backups.ps1 -CreateBackup

# 2. Verify new system works
.\Scripts\Public\Manage-Backups.ps1 -List

# 3. Clean up old individual files (optional)
.\Scripts\Private\Cleanup-Backups.ps1 -DeleteAll
```

## 🔍 Troubleshooting

### Common Issues

**"Backup folder not found"**
- The system automatically creates the `Data\Database\Backups` folder
- No manual setup required

**"Archive operations failed"**
- System falls back to legacy individual file method
- Check PowerShell version compatibility
- Verify disk space availability

**"No backups found"**
- Archive may be empty or not yet created
- Run `-CreateBackup` to create first backup

**"Backup path not found" (Legacy)**
- Ensure the backup directory exists
- Check the `-BackupPath` parameter value

**"Permission denied"**
- Run PowerShell as Administrator
- Check file permissions on backup directory

### PowerShell Version Compatibility

- **PowerShell 5.1**: ✅ Full support with fallback
- **PowerShell 7+**: ✅ Full support with enhanced features
- **Compress-Archive**: Required for archive operations

### Error Recovery

If the archive becomes corrupted:

```powershell
# Remove corrupted archive
Remove-Item "Data\Database\Backups\DatabaseBackups.zip" -Force

# Create new backup (will create fresh archive)
.\Scripts\Manage-Backups.ps1 -CreateBackup
```

## 📈 Performance Benefits

### Storage Efficiency

- **Compression**: Better ZIP compression ratios
- **Deduplication**: No duplicate file overhead
- **Organization**: Single file vs many small files

### Management Efficiency

- **Single Command**: One command to manage all backups
- **Batch Operations**: Clean up multiple backups at once
- **Automated Retention**: Automatic cleanup based on policies

### Example Storage Comparison

| System | 10 Backups | 50 Backups | 100 Backups |
|--------|------------|------------|-------------|
| Legacy | ~300 KB | ~1.5 MB | ~3 MB |
| Enhanced | ~150 KB | ~750 KB | ~1.5 MB |

*Estimated storage savings of ~50%*

## 🔄 Integration with Existing Workflows

### Create-Users.ps1 Integration

The `Create-Users.ps1` script automatically uses the enhanced backup system:

```powershell
# Automatically uses enhanced single archive system
.\Scripts\Private\Create-Users.ps1 -BackupExisting

# Falls back to legacy if enhanced system fails
```

### Scheduled Tasks

```powershell
# Weekly backup creation
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -Command `"& 'C:\Path\To\Scripts\Public\Manage-Backups.ps1' -CreateBackup`""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2AM
Register-ScheduledTask -TaskName "CSVActiveDirectory Backup" -Action $Action -Trigger $Trigger

# Weekly cleanup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -Command `"& 'C:\Path\To\Scripts\Public\Manage-Backups.ps1' -Cleanup -KeepDays 7 -Force`""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3AM
Register-ScheduledTask -TaskName "CSVActiveDirectory Cleanup" -Action $Action -Trigger $Trigger
```

## 🎯 Best Practices

### Backup Frequency

- **Development**: Daily backups
- **Testing**: Weekly backups
- **Production**: Multiple daily backups

### Retention Policies

- **Short-term**: Keep 7 days of backups
- **Medium-term**: Keep 30 days of backups
- **Long-term**: Keep 90 days of backups

### Safety Recommendations

#### 🚨 **Best Practices**
1. **Always use `-WhatIf` first** to preview what will be deleted
2. **Start with age-based cleanup** rather than deleting all files
3. **Use reasonable time periods** (7-30 days) for age-based deletion
4. **Keep recent backups** for emergency recovery

#### 📅 **Recommended Schedule**
- **Weekly**: `-KeepDays 7` to keep recent backups
- **Monthly**: `-KeepDays 30` for longer-term cleanup
- **Quarterly**: Review and manually clean up very old backups

### Monitoring

```powershell
# Check backup status
.\Scripts\Public\Manage-Backups.ps1 -List

# Monitor archive size
Get-ChildItem "Data\Database\Backups\DatabaseBackups.zip" | Select-Object Name, Length, LastWriteTime
```

### Automation

```powershell
# Add to PowerShell profile
function Backup-Database { .\Scripts\Public\Manage-Backups.ps1 -CreateBackup }
function List-Backups { .\Scripts\Public\Manage-Backups.ps1 -List -Detailed }
function Cleanup-Backups { .\Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -Force }

# Legacy functions for backward compatibility
function Cleanup-LegacyBackups { .\Scripts\Private\Cleanup-Backups.ps1 -DeleteAfterDays 7 }
```

## 📊 Output Examples

### Enhanced System - List Backups
```
=== CSVActiveDirectory Backup Management ===
📦 Archive: Data\Database\Backups\DatabaseBackups.zip
📊 Total Backups: 5
💾 Archive Size: 245.3 KB

=== BACKUP LIST ===
  Database.backup.20250724-203127.csv (2 hours ago, 76.5 KB)
  Database.backup.20250724-203056.csv (3 hours ago, 76.5 KB)
  Database.backup.20250724-203027.csv (4 hours ago, 76.5 KB)
  Database.backup.20250724-202958.csv (5 hours ago, 76.5 KB)
  Database.backup.20250724-202929.csv (6 hours ago, 76.5 KB)
```

### Legacy System - Dry Run Mode
```
=== CSVActiveDirectory Backup Cleanup ===
Cleaning up backup database files...

ℹ Found 31 backup files

=== CURRENT BACKUP FILES ===
  Database.backup.20250723-121928.csv (1 hours ago, 76648 bytes)
  Database.backup.20250723-122516.zip (1 hours ago, 15420 bytes)
  Database.backup.20250723-123045.csv (45 minutes ago, 76555 bytes)
  ...

ℹ DRY RUN MODE: No files will be deleted (use -DeleteAll or -DeleteAfterDays)
Available options:
  -DeleteAll                    # Delete all backup files
  -DeleteAfterDays 7           # Delete files older than 7 days
  -WhatIf                       # Show what would be deleted without actually deleting
  -Force                        # Skip confirmation prompts
```

## 📚 Related Documentation

- [SETUP.md](SETUP.md) - Module setup and installation
- [README.md](../README.md) - Main module documentation

---

**Note**: The enhanced backup system provides better organization and efficiency while maintaining full backward compatibility with existing workflows. Use the enhanced system for new deployments and migrate existing systems when convenient. 