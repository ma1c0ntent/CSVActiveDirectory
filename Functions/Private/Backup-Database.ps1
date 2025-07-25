# Backup-Database.ps1
# Private function for managing database backups using a single zipped backups folder
# This replaces the individual ZIP file approach with a more efficient single backup archive

function Backup-Database {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DatabasePath = "Data\Database\Database.csv",
        
        [Parameter(Mandatory = $false)]
        [string]$BackupFolder = "Data\Database\Backups",
        
        [Parameter(Mandatory = $false)]
        [string]$BackupArchiveName = "DatabaseBackups.zip",
        
        [Parameter(Mandatory = $false)]
        [switch]$Force = $false,
        
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf = $false
    )
    
    # Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $ErrorEmoji = Get-Emoji -Type "Error"
    $WarningEmoji = Get-Emoji -Type "Warning"
    $InfoEmoji = Get-Emoji -Type "Info"
    $ArchiveEmoji = Get-Emoji -Type "Info"
} catch {
    # Fallback to text if emoji function not available
    $SuccessEmoji = "[OK]"
    $ErrorEmoji = "[ERROR]"
    $WarningEmoji = "[WARN]"
    $InfoEmoji = "[INFO]"
    $ArchiveEmoji = "[ARCHIVE]"
}
    
    try {
        # Validate database path
        if (-not (Test-Path $DatabasePath)) {
            Write-Error "$($ErrorEmoji) Database file not found: $DatabasePath"
            return $false
        }
        
        # Create backup folder if it doesn't exist
        if (-not (Test-Path $BackupFolder)) {
            if (-not $WhatIf) {
                New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
                Write-Host "$($InfoEmoji) Created backup folder: $BackupFolder" -ForegroundColor Green
            } else {
                Write-Host "$($InfoEmoji) Would create backup folder: $BackupFolder" -ForegroundColor Cyan
            }
        }
        
        # Define backup archive path
        $BackupArchivePath = Join-Path $BackupFolder $BackupArchiveName
        
        # Generate timestamp for the backup file
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $BackupFileName = "Database.backup.$timestamp.csv"
        $TempBackupPath = Join-Path $BackupFolder $BackupFileName
        
        # Create temporary backup file
        if (-not $WhatIf) {
            Copy-Item $DatabasePath $TempBackupPath
            Write-Host "$($InfoEmoji) Created temporary backup: $BackupFileName" -ForegroundColor Green
        } else {
            Write-Host "$($InfoEmoji) Would create temporary backup: $BackupFileName" -ForegroundColor Cyan
        }
        
        # Check if backup archive exists
        if (Test-Path $BackupArchivePath) {
            # Archive exists - add new backup to it
            if (-not $WhatIf) {
                try {
                    # Add the new backup file to the existing archive
                    Compress-Archive -Path $TempBackupPath -DestinationPath $BackupArchivePath -Update
                    Write-Host "$($SuccessEmoji) Added backup to archive: $BackupArchiveName" -ForegroundColor Green
                    
                    # Remove the temporary file
                    Remove-Item $TempBackupPath -Force
                    Write-Host "$($InfoEmoji) Removed temporary backup file" -ForegroundColor Yellow
                }
                catch {
                    Write-Error "$($ErrorEmoji) Failed to add backup to archive: $($_.Exception.Message)"
                    # Keep the temporary file as fallback
                    Write-Host "$($WarningEmoji) Keeping temporary backup: $TempBackupPath" -ForegroundColor Yellow
                    return $false
                }
            } else {
                Write-Host "$($InfoEmoji) Would add backup to existing archive: $BackupArchiveName" -ForegroundColor Cyan
                Write-Host "$($InfoEmoji) Would remove temporary backup file" -ForegroundColor Cyan
            }
        } else {
            # Archive doesn't exist - create new one
            if (-not $WhatIf) {
                try {
                    # Create new archive with the backup file
                    Compress-Archive -Path $TempBackupPath -DestinationPath $BackupArchivePath
                    Write-Host "$($SuccessEmoji) Created new backup archive: $BackupArchiveName" -ForegroundColor Green
                    
                    # Remove the temporary file
                    Remove-Item $TempBackupPath -Force
                    Write-Host "$($InfoEmoji) Removed temporary backup file" -ForegroundColor Yellow
                }
                catch {
                    Write-Error "$($ErrorEmoji) Failed to create backup archive: $($_.Exception.Message)"
                    # Keep the temporary file as fallback
                    Write-Host "$($WarningEmoji) Keeping temporary backup: $TempBackupPath" -ForegroundColor Yellow
                    return $false
                }
            } else {
                Write-Host "$($InfoEmoji) Would create new backup archive: $BackupArchiveName" -ForegroundColor Cyan
                Write-Host "$($InfoEmoji) Would remove temporary backup file" -ForegroundColor Cyan
            }
        }
        
        # Get archive info for reporting
        if (-not $WhatIf -and (Test-Path $BackupArchivePath)) {
            $ArchiveInfo = Get-ChildItem $BackupArchivePath
            $ArchiveSize = if ($ArchiveInfo.Length -gt 1MB) { 
                "$([math]::Round($ArchiveInfo.Length / 1MB, 2)) MB" 
            } elseif ($ArchiveInfo.Length -gt 1KB) { 
                "$([math]::Round($ArchiveInfo.Length / 1KB, 2)) KB" 
            } else { 
                "$($ArchiveInfo.Length) bytes" 
            }
            
            Write-Host "$($ArchiveEmoji) Backup archive size: $ArchiveSize" -ForegroundColor Cyan
        }
        
        return $true
    }
    catch {
        Write-Error "$($ErrorEmoji) Backup operation failed: $($_.Exception.Message)"
        return $false
    }
}

# Export the function (only when loaded as module)
if ($MyInvocation.MyCommand.Path -eq $null) {
    Export-ModuleMember -Function Backup-Database
} 