# Cleanup-Backups.ps1
# Cleanup script for CSVActiveDirectory backup databases
# Removes old backup files to free up disk space

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BackupPath = "Data\Database",
    
    [Parameter(Mandatory = $false)]
    [int]$DeleteAfterDays = 0,
    
    [Parameter(Mandatory = $false)]
    [switch]$DeleteAll = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false
)

# Initialize emoji variables for compatibility
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"
$InfoEmoji = Get-Emoji -Type "Info"
$TrashEmoji = Get-Emoji -Type "Error"
$BulbEmoji = Get-Emoji -Type "Bulb"

Write-Host "=== CSVActiveDirectory Backup Cleanup ===" -ForegroundColor Cyan
Write-Host "Cleaning up backup database files..." -ForegroundColor Green
Write-Host ""

# Validate backup path
if (-not (Test-Path $BackupPath)) {
    Write-Error "$($ErrorEmoji) Backup path not found: $BackupPath"
    Write-Host "Please ensure the backup directory exists" -ForegroundColor Red
    exit 1
}

# Get all backup files
$BackupPattern = "Database.backup.*.csv"
$BackupFiles = Get-ChildItem -Path $BackupPath -Filter $BackupPattern | Sort-Object LastWriteTime

if ($BackupFiles.Count -eq 0) {
    Write-Host "$($InfoEmoji) No backup files found in $BackupPath" -ForegroundColor Yellow
    Write-Host "Backup pattern: $BackupPattern" -ForegroundColor Cyan
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
} elseif ($DeleteAfterDays -gt 0) {
    $CutoffDate = (Get-Date).AddDays(-$DeleteAfterDays)
    $FilesToDelete = $BackupFiles | Where-Object { $_.LastWriteTime -lt $CutoffDate }
    Write-Host "$($InfoEmoji) AGE-BASED CLEANUP: Files older than $DeleteAfterDays days will be deleted" -ForegroundColor Yellow
    Write-Host "Cutoff date: $($CutoffDate.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
} else {
    Write-Host "$($InfoEmoji) DRY RUN MODE: No files will be deleted (use -DeleteAll or -DeleteAfterDays)" -ForegroundColor Yellow
    Write-Host "Available options:" -ForegroundColor Cyan
    Write-Host "  -DeleteAll                    # Delete all backup files" -ForegroundColor White
    Write-Host "  -DeleteAfterDays 7           # Delete files older than 7 days" -ForegroundColor White
    Write-Host "  -WhatIf                       # Show what would be deleted without actually deleting" -ForegroundColor White
    Write-Host "  -Force                        # Skip confirmation prompts" -ForegroundColor White
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

# Summary
Write-Host ""
Write-Host "=== CLEANUP COMPLETE ===" -ForegroundColor Green
Write-Host "$($SuccessEmoji) Successfully deleted $DeletedCount files" -ForegroundColor Green

$SizeText = if ($DeletedSize -gt 1MB) { "$([math]::Round($DeletedSize / 1MB, 2)) MB" } elseif ($DeletedSize -gt 1KB) { "$([math]::Round($DeletedSize / 1KB, 2)) KB" } else { "$DeletedSize bytes" }
Write-Host "$($SuccessEmoji) Freed up $SizeText of disk space" -ForegroundColor Green

# Show remaining files
$RemainingFiles = Get-ChildItem -Path $BackupPath -Filter $BackupPattern | Sort-Object LastWriteTime
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