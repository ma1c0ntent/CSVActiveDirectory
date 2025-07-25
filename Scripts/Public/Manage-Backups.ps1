# Manage-Backups.ps1
# Enhanced backup management script for CSVActiveDirectory
# Uses single archive system instead of individual ZIP files
# Provides comprehensive backup management with analysis and cleanup capabilities

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupFolder = "Data\Database\Backups",
    
    [Parameter(Mandatory = $false)]
    [string]$BackupArchiveName = "DatabaseBackups.zip",
    
    [Parameter(Mandatory = $false)]
    [switch]$List = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Detailed = $false,
    
    [Parameter(Mandatory = $false)]
    [int]$KeepDays = 7,
    
    [Parameter(Mandatory = $false)]
    [int]$KeepCount = 10,
    
    [Parameter(Mandatory = $false)]
    [switch]$Cleanup = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateBackup = $false,
    
    [Parameter(Mandatory = $false)]
    [string]$DatabasePath = "Data\Database\Database.csv",
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Interactive = $false
)

# Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $ErrorEmoji = Get-Emoji -Type "Error"
    $WarningEmoji = Get-Emoji -Type "Warning"
    $InfoEmoji = Get-Emoji -Type "Info"
    $ArchiveEmoji = Get-Emoji -Type "Info"
    $TrashEmoji = Get-Emoji -Type "Error"
    $FolderEmoji = Get-Emoji -Type "Search"
    $ChartEmoji = Get-Emoji -Type "Target"
    $ClockEmoji = Get-Emoji -Type "Clock"
    $ShieldEmoji = Get-Emoji -Type "Shield"
    $RocketEmoji = Get-Emoji -Type "Rocket"
} catch {
    # Fallback to text if emoji function not available
    $SuccessEmoji = "[OK]"
    $ErrorEmoji = "[ERROR]"
    $WarningEmoji = "[WARN]"
    $InfoEmoji = "[INFO]"
    $ArchiveEmoji = "[ARCHIVE]"
    $TrashEmoji = "[DELETE]"
    $FolderEmoji = "[FOLDER]"
    $ChartEmoji = "[CHART]"
    $ClockEmoji = "[CLOCK]"
    $ShieldEmoji = "[SHIELD]"
    $RocketEmoji = "[ROCKET]"
}

# Function to display the main backup management menu
function Show-BackupManagementMenu {
    Write-Host ""
    Write-Host "=== CSV ACTIVE DIRECTORY - BACKUP MANAGEMENT MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose a backup management option:" -ForegroundColor White
    Write-Host "1. Create New Backup" -ForegroundColor Green
    Write-Host "2. List All Backups" -ForegroundColor Blue
    Write-Host "3. Detailed Backup Analysis" -ForegroundColor Yellow
    Write-Host "4. Cleanup Old Backups" -ForegroundColor Red
    Write-Host "5. Backup System Information" -ForegroundColor Cyan
    Write-Host "6. Help & Documentation" -ForegroundColor Gray
    Write-Host "7. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to display cleanup configuration menu
function Show-CleanupConfigMenu {
    Write-Host ""
    Write-Host "=== BACKUP CLEANUP CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure cleanup parameters:" -ForegroundColor White
    Write-Host "1. Keep backups newer than 7 days" -ForegroundColor Green
    Write-Host "2. Keep backups newer than 14 days" -ForegroundColor Yellow
    Write-Host "3. Keep backups newer than 30 days" -ForegroundColor Magenta
    Write-Host "4. Keep newest 5 backups" -ForegroundColor Blue
    Write-Host "5. Keep newest 10 backups" -ForegroundColor Cyan
    Write-Host "6. Custom retention policy" -ForegroundColor Gray
    Write-Host "7. Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
}

# Function to get user input with validation
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$DefaultValue = "",
        [string]$ValidationType = "text"
    )
    
    do {
        $input = Read-Host $Prompt
        if ($input -eq "" -and $DefaultValue -ne "") {
            $input = $DefaultValue
        }
        
        switch ($ValidationType) {
            "yesno" {
                if ($input -match '^[YyNn]$') {
                    return $input -eq "Y" -or $input -eq "y"
                } else {
                    Write-Host "Please enter Y or N." -ForegroundColor Red
                }
            }
            "number" {
                if ($input -match '^\d+$') {
                    return [int]$input
                } else {
                    Write-Host "Please enter a valid number." -ForegroundColor Red
                }
            }
            default {
                return $input
            }
        }
    } while ($true)
}

# Function to show system information
function Show-SystemInfo {
    Write-Host "=== BACKUP SYSTEM INFORMATION ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Check backup folder
    if (Test-Path $BackupFolder) {
        Write-Host "$($SuccessEmoji) Backup folder exists: $BackupFolder" -ForegroundColor Green
        $BackupSize = (Get-ChildItem -Path $BackupFolder -Recurse | Measure-Object -Property Length -Sum).Sum
        $SizeText = if ($BackupSize -gt 1MB) { "$([math]::Round($BackupSize / 1MB, 2)) MB" } elseif ($BackupSize -gt 1KB) { "$([math]::Round($BackupSize / 1KB, 2)) KB" } else { "$BackupSize bytes" }
        Write-Host "$($InfoEmoji) Total backup size: $SizeText" -ForegroundColor Cyan
    } else {
        Write-Host "$($WarningEmoji) Backup folder does not exist: $BackupFolder" -ForegroundColor Yellow
        Write-Host "$($InfoEmoji) It will be created when needed" -ForegroundColor Cyan
    }
    
    # Check backup archive
    $BackupArchivePath = Join-Path $BackupFolder $BackupArchiveName
    if (Test-Path $BackupArchivePath) {
        Write-Host "$($SuccessEmoji) Backup archive exists: $BackupArchiveName" -ForegroundColor Green
        $ArchiveSize = (Get-Item $BackupArchivePath).Length
        $ArchiveSizeText = if ($ArchiveSize -gt 1MB) { "$([math]::Round($ArchiveSize / 1MB, 2)) MB" } elseif ($ArchiveSize -gt 1KB) { "$([math]::Round($ArchiveSize / 1KB, 2)) KB" } else { "$ArchiveSize bytes" }
        Write-Host "$($InfoEmoji) Archive size: $ArchiveSizeText" -ForegroundColor Cyan
    } else {
        Write-Host "$($InfoEmoji) Backup archive will be created: $BackupArchiveName" -ForegroundColor Yellow
    }
    
    # Check database file
    if (Test-Path $DatabasePath) {
        Write-Host "$($SuccessEmoji) Database file exists: $DatabasePath" -ForegroundColor Green
        $DatabaseSize = (Get-Item $DatabasePath).Length
        $DatabaseSizeText = if ($DatabaseSize -gt 1MB) { "$([math]::Round($DatabaseSize / 1MB, 2)) MB" } elseif ($DatabaseSize -gt 1KB) { "$([math]::Round($DatabaseSize / 1KB, 2)) KB" } else { "$DatabaseSize bytes" }
        Write-Host "$($InfoEmoji) Database size: $DatabaseSizeText" -ForegroundColor Cyan
    } else {
        Write-Host "$($WarningEmoji) Database file not found: $DatabasePath" -ForegroundColor Yellow
    }
    
    # Check for backup functions
    $BackupScript = "Functions\Private\Backup-Database.ps1"
    $BackupInfoScript = "Functions\Private\Get-BackupInfo.ps1"
    $RemoveBackupsScript = "Functions\Private\Remove-OldBackups.ps1"
    
    if (Test-Path $BackupScript) {
        Write-Host "$($SuccessEmoji) Backup functions available" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Backup functions not found" -ForegroundColor Yellow
    }
    
    # Check available disk space
    $Drive = Resolve-Path -path $BackupFolder | Select-Object -ExpandProperty Path | Split-Path -Qualifier
    $DriveInfo = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$Drive'"
    if ($DriveInfo) {
        $FreeSpace = $DriveInfo.FreeSpace
        $FreeSpaceText = if ($FreeSpace -gt 1GB) { "$([math]::Round($FreeSpace / 1GB, 2)) GB" } elseif ($FreeSpace -gt 1MB) { "$([math]::Round($FreeSpace / 1MB, 2)) MB" } else { "$([math]::Round($FreeSpace / 1KB, 2)) KB" }
        Write-Host "$($InfoEmoji) Available disk space: $FreeSpaceText" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to show help and documentation
function Show-Help {
    Clear-Host
    Write-Host "=== BACKUP MANAGEMENT HELP ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Backup Management Features:" -ForegroundColor White
    Write-Host "1. Create New Backup - Create a new backup of the database" -ForegroundColor Green
    Write-Host "2. List All Backups - View all backups in the archive" -ForegroundColor Blue
    Write-Host "3. Detailed Backup Analysis - Comprehensive backup information" -ForegroundColor Yellow
    Write-Host "4. Cleanup Old Backups - Remove old backups to save space" -ForegroundColor Red
    Write-Host ""
    Write-Host "Backup System:" -ForegroundColor White
    Write-Host "- Uses single archive system (DatabaseBackups.zip)" -ForegroundColor Cyan
    Write-Host "- Compresses backups to save disk space" -ForegroundColor Cyan
    Write-Host "- Maintains backup history with timestamps" -ForegroundColor Cyan
    Write-Host "- Supports retention policies" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Retention Policies:" -ForegroundColor White
    Write-Host "- Keep by age (days)" -ForegroundColor Yellow
    Write-Host "- Keep by count (number of backups)" -ForegroundColor Yellow
    Write-Host "- Combination of both" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Safety Features:" -ForegroundColor White
    Write-Host "- What-if mode to preview operations" -ForegroundColor Green
    Write-Host "- Confirmation prompts (unless -Force is used)" -ForegroundColor Green
    Write-Host "- Detailed backup information" -ForegroundColor Green
    Write-Host ""
    Write-Host "Best Practices:" -ForegroundColor White
    Write-Host "- Create backups regularly" -ForegroundColor Yellow
    Write-Host "- Use retention policies to manage disk space" -ForegroundColor Yellow
    Write-Host "- Test backup restoration periodically" -ForegroundColor Yellow
    Write-Host "- Monitor backup system health" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to create backup
function Invoke-CreateBackup {
    Write-Host "=== CREATING BACKUP ===" -ForegroundColor Green
    
    if (-not (Test-Path $DatabasePath)) {
        Write-Error "$($ErrorEmoji) Database file not found: $DatabasePath"
        return $false
    }
    
    try {
        # Import required functions
        . "Functions\Private\Backup-Database.ps1"
        
        $BackupResult = Backup-Database -DatabasePath $DatabasePath -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -WhatIf:$WhatIf
        
        if ($BackupResult) {
            Write-Host "$($SuccessEmoji) Backup created successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "$($ErrorEmoji) Backup creation failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Error "$($ErrorEmoji) Failed to create backup: $($_.Exception.Message)"
        return $false
    }
}

# Function to list backups
function Invoke-ListBackups {
    param([bool]$Detailed = $false)
    
    Write-Host "=== LISTING BACKUPS ===" -ForegroundColor Cyan
    
    try {
        # Import required functions
        . "Functions\Private\Get-BackupInfo.ps1"
        
        $BackupFiles = Get-BackupInfo -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -Detailed:$Detailed -WhatIf:$WhatIf
        
        if ($BackupFiles.Count -eq 0) {
            Write-Host "$($InfoEmoji) No backups found in archive" -ForegroundColor Yellow
        } else {
            Write-Host "$($SuccessEmoji) Found $($BackupFiles.Count) backup(s)" -ForegroundColor Green
        }
        
        return $true
    }
    catch {
        Write-Error "$($ErrorEmoji) Failed to list backups: $($_.Exception.Message)"
        return $false
    }
}

# Function to cleanup backups
function Invoke-CleanupBackups {
    param([int]$KeepDays = 7, [int]$KeepCount = 10)
    
    Write-Host "=== CLEANING UP OLD BACKUPS ===" -ForegroundColor Yellow
    Write-Host "Keep days: $KeepDays, Keep count: $KeepCount" -ForegroundColor Cyan
    
    try {
        # Import required functions
        . "Functions\Private\Remove-OldBackups.ps1"
        
        $CleanupResult = Remove-OldBackups -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -KeepDays $KeepDays -KeepCount $KeepCount -WhatIf:$WhatIf -Force:$Force
        
        if ($CleanupResult) {
            Write-Host "$($SuccessEmoji) Cleanup completed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "$($ErrorEmoji) Cleanup failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Error "$($ErrorEmoji) Failed to cleanup backups: $($_.Exception.Message)"
        return $false
    }
}

# Main script logic
if ($Interactive -or $PSBoundParameters.Count -eq 0) {
    # Interactive menu mode
    do {
        Show-BackupManagementMenu
        $choice = Read-Host "Enter your choice (1-7)"
        
        switch ($choice) {
            "1" {
                # Create New Backup
                $confirm = Get-UserInput "Create new backup? (Y/N): " "Y" "yesno"
                if ($confirm) {
                    Invoke-CreateBackup
                } else {
                    Write-Host "Operation cancelled." -ForegroundColor Yellow
                }
                Read-Host "Press Enter to continue"
            }
            "2" {
                # List All Backups
                Invoke-ListBackups -Detailed $false
                Read-Host "Press Enter to continue"
            }
            "3" {
                # Detailed Backup Analysis
                Invoke-ListBackups -Detailed $true
                Read-Host "Press Enter to continue"
            }
            "4" {
                # Cleanup Old Backups
                do {
                    Show-CleanupConfigMenu
                    $cleanupChoice = Read-Host "Enter your choice (1-7)"
                    
                    switch ($cleanupChoice) {
                        "1" { $keepDays = 7; $keepCount = 10 }
                        "2" { $keepDays = 14; $keepCount = 10 }
                        "3" { $keepDays = 30; $keepCount = 10 }
                        "4" { $keepDays = 0; $keepCount = 5 }
                        "5" { $keepDays = 0; $keepCount = 10 }
                        "6" {
                            $keepDays = Get-UserInput "Keep backups newer than (days): " "7" "number"
                            $keepCount = Get-UserInput "Keep newest (count): " "10" "number"
                        }
                        "7" { break }
                        default {
                            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                            Start-Sleep -Seconds 2
                            continue
                        }
                    }
                    
                    if ($cleanupChoice -ne "7") {
                        $confirm = Get-UserInput "Cleanup backups with retention policy (KeepDays: $keepDays, KeepCount: $keepCount)? (Y/N): " "N" "yesno"
                        if ($confirm) {
                            Invoke-CleanupBackups -KeepDays $keepDays -KeepCount $keepCount
                        } else {
                            Write-Host "Operation cancelled." -ForegroundColor Yellow
                        }
                        break
                    }
                } while ($cleanupChoice -ne "7")
            }
            "5" {
                # Backup System Information
                Show-SystemInfo
            }
            "6" {
                # Help & Documentation
                Show-Help
            }
            "7" {
                # Exit
                Write-Host "Goodbye!" -ForegroundColor Green
                exit 0
            }
            default {
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
} else {
    # Non-interactive mode (original functionality)
    Write-Host "=== CSVActiveDirectory Enhanced Backup Management ===" -ForegroundColor Cyan
    Write-Host "Using single archive system: $BackupArchiveName" -ForegroundColor Green
    Write-Host ""

    # Import required functions
    try {
        . "Functions\Private\Backup-Database.ps1"
        . "Functions\Private\Get-BackupInfo.ps1"
        . "Functions\Private\Remove-OldBackups.ps1"
    }
    catch {
        Write-Error "$($ErrorEmoji) Failed to import backup functions: $($_.Exception.Message)"
        exit 1
    }

    # Validate backup folder
    if (-not (Test-Path $BackupFolder)) {
        Write-Host "$($InfoEmoji) Backup folder does not exist: $BackupFolder" -ForegroundColor Yellow
        Write-Host "$($InfoEmoji) It will be created when needed" -ForegroundColor Cyan
    }

    # Determine action based on parameters
    $Action = "list"  # Default action

    if ($CreateBackup) {
        $Action = "create"
    } elseif ($Cleanup) {
        $Action = "cleanup"
    } elseif ($List) {
        $Action = "list"
    }

    # Perform the requested action
    switch ($Action) {
        "create" {
            Write-Host "=== CREATING BACKUP ===" -ForegroundColor Green
            
            if (-not (Test-Path $DatabasePath)) {
                Write-Error "$($ErrorEmoji) Database file not found: $DatabasePath"
                exit 1
            }
            
            $BackupResult = Backup-Database -DatabasePath $DatabasePath -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -WhatIf:$WhatIf
            
            if ($BackupResult) {
                Write-Host "$($SuccessEmoji) Backup created successfully" -ForegroundColor Green
            } else {
                Write-Host "$($ErrorEmoji) Backup creation failed" -ForegroundColor Red
                exit 1
            }
        }
        
        "cleanup" {
            Write-Host "=== CLEANING UP OLD BACKUPS ===" -ForegroundColor Yellow
            
            $CleanupResult = Remove-OldBackups -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -KeepDays $KeepDays -KeepCount $KeepCount -WhatIf:$WhatIf -Force:$Force
            
            if ($CleanupResult) {
                Write-Host "$($SuccessEmoji) Cleanup completed successfully" -ForegroundColor Green
            } else {
                Write-Host "$($ErrorEmoji) Cleanup failed" -ForegroundColor Red
                exit 1
            }
        }
        
        "list" {
            Write-Host "=== LISTING BACKUPS ===" -ForegroundColor Cyan
            
            $BackupFiles = Get-BackupInfo -BackupFolder $BackupFolder -BackupArchiveName $BackupArchiveName -Detailed:$Detailed -WhatIf:$WhatIf
            
            if ($BackupFiles.Count -eq 0) {
                Write-Host "$($InfoEmoji) No backups found in archive" -ForegroundColor Yellow
            }
        }
    }

    # Show usage information if no specific action was performed
    if (-not ($CreateBackup -or $Cleanup -or $List)) {
        Write-Host "$($InfoEmoji) No specific action requested. Available options:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -CreateBackup                    # Create a new backup" -ForegroundColor White
        Write-Host "  -List                            # List all backups in archive" -ForegroundColor White
        Write-Host "  -Detailed                        # Show detailed backup information" -ForegroundColor White
        Write-Host "  -Cleanup                         # Remove old backups" -ForegroundColor White
        Write-Host "  -KeepDays 7                      # Keep backups newer than 7 days" -ForegroundColor White
        Write-Host "  -KeepCount 10                    # Keep newest 10 backups" -ForegroundColor White
        Write-Host "  -WhatIf                          # Show what would be done without doing it" -ForegroundColor White
        Write-Host "  -Force                           # Skip confirmation prompts" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\Scripts\Public\Manage-Backups.ps1 -CreateBackup" -ForegroundColor Gray
Write-Host "  Scripts\Public\Manage-Backups.ps1 -List -Detailed" -ForegroundColor Gray
Write-Host "  Scripts\Public\Manage-Backups.ps1 -Cleanup -KeepDays 7 -KeepCount 10" -ForegroundColor Gray
Write-Host "  Scripts\Public\Manage-Backups.ps1 -Cleanup -WhatIf" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "$($ArchiveEmoji) Backup Management Complete" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "$($SuccessEmoji) Manage-Backups script completed successfully!" -ForegroundColor Green
} 
