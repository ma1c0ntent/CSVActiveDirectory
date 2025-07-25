# Cleanup-Backups.ps1
# Cleanup script for CSVActiveDirectory backup databases
# Removes old backup files to free up disk space

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupPath = "..\..\Data\Database",
    
    [Parameter(Mandatory = $false)]
    [int]$DeleteAfterDays = 0,
    
    [Parameter(Mandatory = $false)]
    [switch]$DeleteAll = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Interactive = $false
)

# Import the CSVActiveDirectory module
$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "CSVActiveDirectory.psm1"
if (Test-Path $ModulePath) {
    Import-Module $ModulePath -Force
} else {
    Write-Error "CSVActiveDirectory module not found at: $ModulePath"
    exit 1
}

# Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $ErrorEmoji = Get-Emoji -Type "Error"
    $WarningEmoji = Get-Emoji -Type "Warning"
    $InfoEmoji = Get-Emoji -Type "Info"
    $TrashEmoji = Get-Emoji -Type "Error"
    $BulbEmoji = Get-Emoji -Type "Bulb"
    $FolderEmoji = Get-Emoji -Type "Search"
    $ChartEmoji = Get-Emoji -Type "Target"
    $ClockEmoji = Get-Emoji -Type "Clock"
} catch {
    # Fallback to text symbols if emoji function fails
    $SuccessEmoji = "[OK]"
    $ErrorEmoji = "[ERROR]"
    $WarningEmoji = "[WARN]"
    $InfoEmoji = "[INFO]"
    $TrashEmoji = "[DELETE]"
    $BulbEmoji = "[TIP]"
    $FolderEmoji = "[FOLDER]"
    $ChartEmoji = "[CHART]"
    $ClockEmoji = "[TIME]"
}

# Function to display the main cleanup menu
function Show-CleanupMenu {
    Write-Host ""
    Write-Host "=== CSV ACTIVE DIRECTORY - BACKUP CLEANUP MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose a cleanup option:" -ForegroundColor White
    Write-Host "1. Quick Cleanup (Delete all backups)" -ForegroundColor Red
    Write-Host "2. Age-based Cleanup (Delete old backups)" -ForegroundColor Yellow
    Write-Host "3. Preview Cleanup (What-if mode)" -ForegroundColor Green
    Write-Host "4. View Current Backups" -ForegroundColor Blue
    Write-Host "5. System Information" -ForegroundColor Cyan
    Write-Host "6. Help & Documentation" -ForegroundColor Gray
    Write-Host "7. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to display age-based cleanup configuration menu
function Show-AgeCleanupMenu {
    Write-Host ""
    Write-Host "=== AGE-BASED CLEANUP CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure cleanup parameters:" -ForegroundColor White
    Write-Host "1. Delete backups older than 7 days" -ForegroundColor Green
    Write-Host "2. Delete backups older than 14 days" -ForegroundColor Yellow
    Write-Host "3. Delete backups older than 30 days" -ForegroundColor Magenta
    Write-Host "4. Custom number of days" -ForegroundColor Blue
    Write-Host "5. Back to Main Menu" -ForegroundColor Gray
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
    Write-Host "=== SYSTEM INFORMATION ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Check backup path
    if (Test-Path $BackupPath) {
        Write-Host "$($SuccessEmoji) Backup path exists: $BackupPath" -ForegroundColor Green
        $BackupSize = (Get-ChildItem -Path $BackupPath -Recurse | Measure-Object -Property Length -Sum).Sum
        $SizeText = if ($BackupSize -gt 1MB) { "$([math]::Round($BackupSize / 1MB, 2)) MB" } elseif ($BackupSize -gt 1KB) { "$([math]::Round($BackupSize / 1KB, 2)) KB" } else { "$BackupSize bytes" }
        Write-Host "$($InfoEmoji) Total backup size: $SizeText" -ForegroundColor Cyan
    } else {
        Write-Host "$($ErrorEmoji) Backup path not found: $BackupPath" -ForegroundColor Red
    }
    
    # Check for new archive system
    $BackupFolder = Join-Path $BackupPath "Backups"
    $BackupArchivePath = Join-Path $BackupFolder "DatabaseBackups.zip"
    if (Test-Path $BackupArchivePath) {
        Write-Host "$($SuccessEmoji) New archive system found: $BackupArchivePath" -ForegroundColor Green
    } else {
        Write-Host "$($InfoEmoji) Using legacy backup system" -ForegroundColor Yellow
    }
    
    # Check available disk space
    $Drive = Split-Path $BackupPath -Qualifier
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
    Write-Host "=== BACKUP CLEANUP HELP ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Backup Cleanup Options:" -ForegroundColor White
    Write-Host "1. Quick Cleanup - Deletes all backup files immediately" -ForegroundColor Red
    Write-Host "2. Age-based Cleanup - Deletes backups older than specified days" -ForegroundColor Yellow
    Write-Host "3. Preview Cleanup - Shows what would be deleted without actually deleting" -ForegroundColor Green
    Write-Host "4. View Current Backups - Lists all existing backup files" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Supported Backup Systems:" -ForegroundColor White
    Write-Host "- Legacy individual files (Database.backup.*.csv/.zip)" -ForegroundColor Cyan
    Write-Host "- New single archive system (DatabaseBackups.zip)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Safety Features:" -ForegroundColor White
    Write-Host "- What-if mode to preview deletions" -ForegroundColor Green
    Write-Host "- Confirmation prompts (unless -Force is used)" -ForegroundColor Green
    Write-Host "- Detailed file information before deletion" -ForegroundColor Green
    Write-Host ""
    Write-Host "Best Practices:" -ForegroundColor White
    Write-Host "- Use preview mode first to see what will be deleted" -ForegroundColor Yellow
    Write-Host "- Keep recent backups for disaster recovery" -ForegroundColor Yellow
    Write-Host "- Run cleanup regularly to prevent disk space issues" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to view current backups
function Show-CurrentBackups {
    Write-Host "=== CURRENT BACKUP FILES ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Get all backup files (both CSV and ZIP) - legacy individual files
    $BackupPatternCSV = "Database.backup.*.csv"
    $BackupPatternZIP = "Database.backup.*.zip"
    $BackupFilesCSV = Get-ChildItem -Path $BackupPath -Filter $BackupPatternCSV | Sort-Object LastWriteTime
    $BackupFilesZIP = Get-ChildItem -Path $BackupPath -Filter $BackupPatternZIP | Sort-Object LastWriteTime
    $BackupFiles = @($BackupFilesCSV) + @($BackupFilesZIP)
    
    # Check for new single archive system
    $BackupFolder = Join-Path $BackupPath "Backups"
    $BackupArchivePath = Join-Path $BackupFolder "DatabaseBackups.zip"
    $HasNewSystem = $false
    
    if (Test-Path $BackupArchivePath) {
        $HasNewSystem = $true
        Write-Host "$($InfoEmoji) Found new single archive system: $BackupArchivePath" -ForegroundColor Green
        
        # Import new backup functions
        try {
            . $PSScriptRoot/../Functions/Private/Get-BackupInfo.ps1
            
            # Get backup info from archive
            $ArchiveBackups = Get-BackupInfo -BackupFolder $BackupFolder -BackupArchiveName "DatabaseBackups.zip" -WhatIf:$WhatIf
            
            if ($ArchiveBackups.Count -gt 0) {
                Write-Host "$($InfoEmoji) Archive contains $($ArchiveBackups.Count) backup files" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Archive Contents:" -ForegroundColor White
                foreach ($Backup in $ArchiveBackups) {
                    $Age = (Get-Date) - $Backup.Date
                    $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
                    Write-Host "  $($Backup.Name) ($AgeText, $($Backup.Size) bytes)" -ForegroundColor White
                }
            }
        }
        catch {
            Write-Host "$($WarningEmoji) Could not analyze new backup system: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    if ($BackupFiles.Count -eq 0) {
        Write-Host "$($InfoEmoji) No legacy backup files found in $BackupPath" -ForegroundColor Yellow
    } else {
        Write-Host "$($InfoEmoji) Found $($BackupFiles.Count) legacy backup files" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Legacy Backup Files:" -ForegroundColor White
        $BackupFiles | ForEach-Object {
            $Age = (Get-Date) - $_.LastWriteTime
            $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
            Write-Host "  $($_.Name) ($AgeText, $($_.Length) bytes)" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to perform cleanup operations
function Invoke-CleanupOperation {
    param(
        [string]$Operation,
        [int]$Days = 0,
        [bool]$WhatIfMode = $false
    )
    
    Write-Host "=== PERFORMING CLEANUP OPERATION ===" -ForegroundColor Cyan
    Write-Host "Operation: $Operation" -ForegroundColor White
    if ($Days -gt 0) {
        Write-Host "Age threshold: $Days days" -ForegroundColor White
    }
    if ($WhatIfMode) {
        Write-Host "Mode: Preview only (no files will be deleted)" -ForegroundColor Green
    }
    Write-Host ""
    
    # Validate backup path
    if (-not (Test-Path $BackupPath)) {
        Write-Error "$($ErrorEmoji) Backup path not found: $BackupPath"
        Write-Host "Please ensure the backup directory exists" -ForegroundColor Red
        return $false
    }
    
    # Get all backup files (both CSV and ZIP) - legacy individual files
    $BackupPatternCSV = "Database.backup.*.csv"
    $BackupPatternZIP = "Database.backup.*.zip"
    $BackupFilesCSV = Get-ChildItem -Path $BackupPath -Filter $BackupPatternCSV | Sort-Object LastWriteTime
    $BackupFilesZIP = Get-ChildItem -Path $BackupPath -Filter $BackupPatternZIP | Sort-Object LastWriteTime
    $BackupFiles = @($BackupFilesCSV) + @($BackupFilesZIP)
    
    # Check for new single archive system
    $BackupFolder = Join-Path $BackupPath "Backups"
    $BackupArchivePath = Join-Path $BackupFolder "DatabaseBackups.zip"
    $HasNewSystem = $false
    
    if (Test-Path $BackupArchivePath) {
        $HasNewSystem = $true
        Write-Host "$($InfoEmoji) Found new single archive system: $BackupArchivePath" -ForegroundColor Green
    }
    
    if ($BackupFiles.Count -eq 0 -and -not $HasNewSystem) {
        Write-Host "$($InfoEmoji) No backup files found in $BackupPath" -ForegroundColor Yellow
        Write-Host "Backup patterns: $BackupPatternCSV, $BackupPatternZIP" -ForegroundColor Cyan
        return $true
    }
    
    Write-Host "$($InfoEmoji) Found $($BackupFiles.Count) legacy backup files" -ForegroundColor Cyan
    Write-Host ""
    
    # Determine files to delete based on operation
    $FilesToDelete = @()
    
    switch ($Operation) {
        "DeleteAll" {
            Write-Host "$($WarningEmoji) DELETE ALL MODE: All backup files will be deleted" -ForegroundColor Red
            $FilesToDelete = $BackupFiles
        }
        "AgeBased" {
            $CutoffDate = (Get-Date).AddDays(-$Days)
            $FilesToDelete = $BackupFiles | Where-Object { $_.LastWriteTime -lt $CutoffDate }
            Write-Host "$($InfoEmoji) AGE-BASED CLEANUP: Files older than $Days days will be deleted" -ForegroundColor Yellow
            Write-Host "Cutoff date: $($CutoffDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
        }
    }
    
    # Display files that will be deleted
    if ($FilesToDelete.Count -eq 0) {
        Write-Host "$($SuccessEmoji) No files meet the deletion criteria" -ForegroundColor Green
        return $true
    }
    
    Write-Host ""
    Write-Host "=== FILES TO BE DELETED ===" -ForegroundColor Red
    $TotalSize = 0
    $FilesToDelete | ForEach-Object {
        $Age = (Get-Date) - $_.LastWriteTime
        $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
        Write-Host "  $($_.Name) ($AgeText, $($_.Length) bytes)" -ForegroundColor Red
        $TotalSize += $_.Length
    }
    
    $SizeText = if ($TotalSize -gt 1MB) { "$([math]::Round($TotalSize / 1MB, 2)) MB" } elseif ($TotalSize -gt 1KB) { "$([math]::Round($TotalSize / 1KB, 2)) KB" } else { "$TotalSize bytes" }
    Write-Host ""
    Write-Host "Total files to delete: $($FilesToDelete.Count)" -ForegroundColor Yellow
    Write-Host "Total size to free: $SizeText" -ForegroundColor Yellow
    Write-Host ""
    
    # WhatIf mode
    if ($WhatIfMode) {
        Write-Host "$($InfoEmoji) WHAT-IF MODE: No files will actually be deleted" -ForegroundColor Cyan
        Write-Host "Run without -WhatIf to perform the actual deletion" -ForegroundColor Yellow
        return $true
    }
    
    # Confirmation prompt
    Write-Host "$($WarningEmoji) WARNING: This action cannot be undone!" -ForegroundColor Red
    $Confirmation = Read-Host "Are you sure you want to delete these files? (y/N)"
    if ($Confirmation -notmatch '^[Yy]$') {
        Write-Host "$($InfoEmoji) Operation cancelled by user" -ForegroundColor Yellow
        return $false
    }
    
    # Perform deletion
    Write-Host ""
    Write-Host "=== DELETING FILES ===" -ForegroundColor Red
    $DeletedCount = 0
    $DeletedSize = 0
    
    # Handle legacy individual files
    foreach ($File in $FilesToDelete) {
        try {
            Remove-Item -Path $File.FullName -Force
            Write-Host "$($TrashEmoji) Deleted: $($File.Name)" -ForegroundColor Red
            $DeletedCount++
            $DeletedSize += $File.Length
        }
        catch {
            Write-Error "$($ErrorEmoji) Failed to delete $($File.Name): $($_.Exception.Message)"
        }
    }
    
    # Handle new archive system
    if ($HasNewSystem) {
        Write-Host ""
        Write-Host "=== CLEANING UP NEW ARCHIVE SYSTEM ===" -ForegroundColor Cyan
        
        try {
            . $PSScriptRoot/../Functions/Private/Remove-OldBackups.ps1
            
            $KeepDays = if ($Operation -eq "AgeBased") { $Days } else { 0 }
            $KeepCount = if ($Operation -eq "DeleteAll") { 0 } else { 10 }
            
            $ArchiveCleanupResult = Remove-OldBackups -BackupFolder $BackupFolder -BackupArchiveName "DatabaseBackups.zip" -KeepDays $KeepDays -KeepCount $KeepCount -WhatIf:$WhatIfMode -Force:$true
            
            if ($ArchiveCleanupResult) {
                Write-Host "$($SuccessEmoji) Archive cleanup completed successfully" -ForegroundColor Green
            } else {
                Write-Host "$($WarningEmoji) Archive cleanup failed or was cancelled" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Error "$($ErrorEmoji) Failed to clean up archive system: $($_.Exception.Message)"
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "=== CLEANUP COMPLETE ===" -ForegroundColor Green
    Write-Host "$($SuccessEmoji) Successfully deleted $DeletedCount files" -ForegroundColor Green
    
    $SizeText = if ($DeletedSize -gt 1MB) { "$([math]::Round($DeletedSize / 1MB, 2)) MB" } elseif ($DeletedSize -gt 1KB) { "$([math]::Round($DeletedSize / 1KB, 2)) KB" } else { "$DeletedSize bytes" }
    Write-Host "$($SuccessEmoji) Freed up $SizeText of disk space" -ForegroundColor Green
    
    # Show remaining files
    $RemainingFilesCSV = Get-ChildItem -Path $BackupPath -Filter $BackupPatternCSV | Sort-Object LastWriteTime
    $RemainingFilesZIP = Get-ChildItem -Path $BackupPath -Filter $BackupPatternZIP | Sort-Object LastWriteTime
    $RemainingFiles = @($RemainingFilesCSV) + @($RemainingFilesZIP)
    if ($RemainingFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "$($InfoEmoji) Remaining backup files: $($RemainingFiles.Count)" -ForegroundColor Cyan
        $RemainingFiles | ForEach-Object {
            $Age = (Get-Date) - $_.LastWriteTime
            $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
            Write-Host "  $($_.Name) ($AgeText)" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "$($BulbEmoji) Pro Tips:" -ForegroundColor Yellow
    Write-Host "  - Run this script regularly to prevent disk space issues" -ForegroundColor White
    Write-Host "  - Use age-based cleanup for weekly maintenance" -ForegroundColor White
    Write-Host "  - Use preview mode to see what will be deleted" -ForegroundColor White
    Write-Host "  - Consider using Scripts\Public\Manage-Backups.ps1 for advanced backup management" -ForegroundColor White
    
    Read-Host "Press Enter to continue"
    return $true
}

# Main script logic
if ($Interactive -or $PSBoundParameters.Count -eq 0) {
    # Interactive menu mode
    do {
        Show-CleanupMenu
        $choice = Read-Host "Enter your choice (1-7)"
        
        switch ($choice) {
            "1" {
                # Quick Cleanup
                $confirm = Get-UserInput "Are you sure you want to delete ALL backups? (Y/N)" "N" "yesno"
                if ($confirm) {
                    Invoke-CleanupOperation -Operation "DeleteAll"
                } else {
                    Write-Host "Operation cancelled." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
            }
            "2" {
                # Age-based Cleanup
                do {
                    Show-AgeCleanupMenu
                    $ageChoice = Read-Host "Enter your choice (1-5)"
                    
                    switch ($ageChoice) {
                        "1" { $days = 7 }
                        "2" { $days = 14 }
                        "3" { $days = 30 }
                        "4" {
                            $days = Get-UserInput "Enter number of days: " "7" "number"
                        }
                        "5" { break }
                        default {
                            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                            Start-Sleep -Seconds 2
                            continue
                        }
                    }
                    
                    if ($ageChoice -ne "5") {
                        $confirm = Get-UserInput "Delete backups older than $days days? (Y/N): " "N" "yesno"
                        if ($confirm) {
                            Invoke-CleanupOperation -Operation "AgeBased" -Days $days
                        } else {
                            Write-Host "Operation cancelled." -ForegroundColor Yellow
                            Start-Sleep -Seconds 2
                        }
                        break
                    }
                } while ($ageChoice -ne "5")
            }
            "3" {
                # Preview Cleanup
                do {
                    Show-AgeCleanupMenu
                    $previewChoice = Read-Host "Enter your choice (1-5)"
                    
                    switch ($previewChoice) {
                        "1" { $days = 7 }
                        "2" { $days = 14 }
                        "3" { $days = 30 }
                        "4" {
                            $days = Get-UserInput "Enter number of days: " "7" "number"
                        }
                        "5" { break }
                        default {
                            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                            Start-Sleep -Seconds 2
                            continue
                        }
                    }
                    
                    if ($previewChoice -ne "5") {
                        Invoke-CleanupOperation -Operation "AgeBased" -Days $days -WhatIfMode $true
                        break
                    }
                } while ($previewChoice -ne "5")
            }
            "4" {
                # View Current Backups
                Show-CurrentBackups
            }
            "5" {
                # System Information
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
    Write-Host "=== CSVActiveDirectory Backup Cleanup ===" -ForegroundColor Cyan
    Write-Host "Cleaning up backup database files..." -ForegroundColor Green
    Write-Host ""

    # Validate backup path
    if (-not (Test-Path $BackupPath)) {
        Write-Error "$($ErrorEmoji) Backup path not found: $BackupPath"
        Write-Host "Please ensure the backup directory exists" -ForegroundColor Red
        exit 1
    }

    # Get all backup files (both CSV and ZIP) - legacy individual files
    $BackupPatternCSV = "Database.backup.*.csv"
    $BackupPatternZIP = "Database.backup.*.zip"
    $BackupFilesCSV = Get-ChildItem -Path $BackupPath -Filter $BackupPatternCSV | Sort-Object LastWriteTime
    $BackupFilesZIP = Get-ChildItem -Path $BackupPath -Filter $BackupPatternZIP | Sort-Object LastWriteTime
    $BackupFiles = @($BackupFilesCSV) + @($BackupFilesZIP)

    # Check for new single archive system
    $BackupFolder = Join-Path $BackupPath "Backups"
    $BackupArchivePath = Join-Path $BackupFolder "DatabaseBackups.zip"
    $HasNewSystem = $false

    if (Test-Path $BackupArchivePath) {
        $HasNewSystem = $true
        Write-Host "$($InfoEmoji) Found new single archive system: $BackupArchivePath" -ForegroundColor Green
        
        # Import new backup functions
        try {
            . $PSScriptRoot/../Functions/Private/Get-BackupInfo.ps1
            . $PSScriptRoot/../Functions/Private/Remove-OldBackups.ps1
            
            # Get backup info from archive
            $ArchiveBackups = Get-BackupInfo -BackupFolder $BackupFolder -BackupArchiveName "DatabaseBackups.zip" -WhatIf:$WhatIf
            
            if ($ArchiveBackups.Count -gt 0) {
                Write-Host "$($InfoEmoji) Archive contains $($ArchiveBackups.Count) backup files" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host "$($WarningEmoji) Could not analyze new backup system: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    if ($BackupFiles.Count -eq 0) {
        Write-Host "$($InfoEmoji) No backup files found in $BackupPath" -ForegroundColor Yellow
        Write-Host "Backup patterns: $BackupPatternCSV, $BackupPatternZIP" -ForegroundColor Cyan
        exit 0
    }

    Write-Host "$($InfoEmoji) Found $($BackupFiles.Count) backup files" -ForegroundColor Cyan
    Write-Host ""

    # Display current backup files
    Write-Host "=== CURRENT BACKUP FILES ===" -ForegroundColor Yellow
    $BackupFiles | ForEach-Object {
        $Age = (Get-Date) - $_.LastWriteTime
        $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
        Write-Host "  $($_.Name) ($AgeText, $($_.Length) bytes)" -ForegroundColor White
    }
    Write-Host ""

    # Determine files to delete based on parameters
    $FilesToDelete = @()

    if ($DeleteAll) {
        Write-Host "$($WarningEmoji) DELETE ALL MODE: All backup files will be deleted" -ForegroundColor Red
        $FilesToDelete = $BackupFiles
        
        # Also handle new archive system
        if ($HasNewSystem) {
            Write-Host "$($WarningEmoji) Will also clean up new archive system" -ForegroundColor Red
        }
    } elseif ($DeleteAfterDays -gt 0) {
        $CutoffDate = (Get-Date).AddDays(-$DeleteAfterDays)
        $FilesToDelete = $BackupFiles | Where-Object { $_.LastWriteTime -lt $CutoffDate }
        Write-Host "$($InfoEmoji) AGE-BASED CLEANUP: Files older than $DeleteAfterDays days will be deleted" -ForegroundColor Yellow
        Write-Host "Cutoff date: $($CutoffDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
        
        # Also handle new archive system
        if ($HasNewSystem) {
            Write-Host "$($InfoEmoji) Will also clean up new archive system using same retention policy" -ForegroundColor Yellow
        }
    } else {
        Write-Host "$($InfoEmoji) DRY RUN MODE: No files will be deleted (use -DeleteAll or -DeleteAfterDays)" -ForegroundColor Yellow
        Write-Host "Available options:" -ForegroundColor Cyan
        Write-Host "  -DeleteAll                    # Delete all backup files" -ForegroundColor White
        Write-Host "  -DeleteAfterDays 7           # Delete files older than 7 days" -ForegroundColor White
        Write-Host "  -WhatIf                       # Show what would be deleted without actually deleting" -ForegroundColor White
        Write-Host "  -Force                        # Skip confirmation prompts" -ForegroundColor White
        Write-Host ""
        Write-Host "Note: This script now supports both legacy individual files and new single archive system" -ForegroundColor Cyan
        Write-Host "For new archive system management, consider using: .\Scripts\Public\Manage-Backups.ps1" -ForegroundColor Yellow
        exit 0
    }

    # Display files that will be deleted
    if ($FilesToDelete.Count -eq 0) {
        Write-Host "$($SuccessEmoji) No files meet the deletion criteria" -ForegroundColor Green
        exit 0
    }

    Write-Host ""
    Write-Host "=== FILES TO BE DELETED ===" -ForegroundColor Red
    $TotalSize = 0
    $FilesToDelete | ForEach-Object {
        $Age = (Get-Date) - $_.LastWriteTime
        $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
        Write-Host "  $($_.Name) ($AgeText, $($_.Length) bytes)" -ForegroundColor Red
        $TotalSize += $_.Length
    }

    $SizeText = if ($TotalSize -gt 1MB) { "$([math]::Round($TotalSize / 1MB, 2)) MB" } elseif ($TotalSize -gt 1KB) { "$([math]::Round($TotalSize / 1KB, 2)) KB" } else { "$TotalSize bytes" }
    Write-Host ""
    Write-Host "Total files to delete: $($FilesToDelete.Count)" -ForegroundColor Yellow
    Write-Host "Total size to free: $SizeText" -ForegroundColor Yellow
    Write-Host ""

    # WhatIf mode
    if ($WhatIf) {
        Write-Host "$($InfoEmoji) WHAT-IF MODE: No files will actually be deleted" -ForegroundColor Cyan
        Write-Host "Run without -WhatIf to perform the actual deletion" -ForegroundColor Yellow
        exit 0
    }

    # Confirmation prompt (unless -Force is used)
    if (-not $Force) {
        Write-Host "$($WarningEmoji) WARNING: This action cannot be undone!" -ForegroundColor Red
        $Confirmation = Read-Host "Are you sure you want to delete these files? (y/N)"
        if ($Confirmation -notmatch '^[Yy]$') {
            Write-Host "$($InfoEmoji) Operation cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }

    # Perform deletion
    Write-Host ""
    Write-Host "=== DELETING FILES ===" -ForegroundColor Red
    $DeletedCount = 0
    $DeletedSize = 0

    # Handle legacy individual files
    foreach ($File in $FilesToDelete) {
        try {
            Remove-Item -Path $File.FullName -Force
            Write-Host "$($TrashEmoji) Deleted: $($File.Name)" -ForegroundColor Red
            $DeletedCount++
            $DeletedSize += $File.Length
        }
        catch {
            Write-Error "$($ErrorEmoji) Failed to delete $($File.Name): $($_.Exception.Message)"
        }
    }

    # Handle new archive system
    if ($HasNewSystem -and ($DeleteAll -or $DeleteAfterDays -gt 0)) {
        Write-Host ""
        Write-Host "=== CLEANING UP NEW ARCHIVE SYSTEM ===" -ForegroundColor Cyan
        
        try {
            $KeepDays = if ($DeleteAfterDays -gt 0) { $DeleteAfterDays } else { 0 }
            $KeepCount = if ($DeleteAll) { 0 } else { 10 }
            
            $ArchiveCleanupResult = Remove-OldBackups -BackupFolder $BackupFolder -BackupArchiveName "DatabaseBackups.zip" -KeepDays $KeepDays -KeepCount $KeepCount -WhatIf:$WhatIf -Force:$Force
            
            if ($ArchiveCleanupResult) {
                Write-Host "$($SuccessEmoji) Archive cleanup completed successfully" -ForegroundColor Green
            } else {
                Write-Host "$($WarningEmoji) Archive cleanup failed or was cancelled" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Error "$($ErrorEmoji) Failed to clean up archive system: $($_.Exception.Message)"
        }
    }

    # Summary
    Write-Host ""
    Write-Host "=== CLEANUP COMPLETE ===" -ForegroundColor Green
    Write-Host "$($SuccessEmoji) Successfully deleted $DeletedCount files" -ForegroundColor Green

    $SizeText = if ($DeletedSize -gt 1MB) { "$([math]::Round($DeletedSize / 1MB, 2)) MB" } elseif ($DeletedSize -gt 1KB) { "$([math]::Round($DeletedSize / 1KB, 2)) KB" } else { "$DeletedSize bytes" }
    Write-Host "$($SuccessEmoji) Freed up $SizeText of disk space" -ForegroundColor Green

    # Show remaining files
    $RemainingFilesCSV = Get-ChildItem -Path $BackupPath -Filter $BackupPatternCSV | Sort-Object LastWriteTime
    $RemainingFilesZIP = Get-ChildItem -Path $BackupPath -Filter $BackupPatternZIP | Sort-Object LastWriteTime
    $RemainingFiles = @($RemainingFilesCSV) + @($RemainingFilesZIP)
    if ($RemainingFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "$($InfoEmoji) Remaining backup files: $($RemainingFiles.Count)" -ForegroundColor Cyan
        $RemainingFiles | ForEach-Object {
            $Age = (Get-Date) - $_.LastWriteTime
            $AgeText = if ($Age.Days -gt 0) { "$($Age.Days) days ago" } elseif ($Age.Hours -gt 0) { "$($Age.Hours) hours ago" } else { "$($Age.Minutes) minutes ago" }
            Write-Host "  $($_.Name) ($AgeText)" -ForegroundColor White
        }
    }

    Write-Host ""
    Write-Host "$($BulbEmoji) Pro Tips:" -ForegroundColor Yellow
    Write-Host "  - Run this script regularly to prevent disk space issues" -ForegroundColor White
    Write-Host "  - Use -DeleteAfterDays 7 for weekly cleanup" -ForegroundColor White
    Write-Host "  - Use -WhatIf to preview what will be deleted" -ForegroundColor White
    Write-Host "  - Use -Force to skip confirmation prompts" -ForegroundColor White
    
    Write-Host ""
    Write-Host "$($SuccessEmoji) Cleanup-Backups script completed successfully!" -ForegroundColor Green
} 