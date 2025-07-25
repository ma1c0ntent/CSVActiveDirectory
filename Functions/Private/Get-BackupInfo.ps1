# Get-BackupInfo.ps1
# Private function for listing and managing backups within the single archive file

function Get-BackupInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$BackupFolder = "Data\Database\Backups",
        
        [Parameter(Mandatory = $false)]
        [string]$BackupArchiveName = "DatabaseBackups.zip",
        
        [Parameter(Mandatory = $false)]
        [switch]$Detailed = $false,
        
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
        $BackupArchivePath = Join-Path $BackupFolder $BackupArchiveName
        
        # Check if backup archive exists
        if (-not (Test-Path $BackupArchivePath)) {
            Write-Host "$($InfoEmoji) No backup archive found: $BackupArchivePath" -ForegroundColor Yellow
            return @()
        }
        
        # Get archive info
        $ArchiveInfo = Get-ChildItem $BackupArchivePath
        $ArchiveSize = if ($ArchiveInfo.Length -gt 1MB) { 
            "$([math]::Round($ArchiveInfo.Length / 1MB, 2)) MB" 
        } elseif ($ArchiveInfo.Length -gt 1KB) { 
            "$([math]::Round($ArchiveInfo.Length / 1KB, 2)) KB" 
        } else { 
            "$($ArchiveInfo.Length) bytes" 
        }
        
        Write-Host "$($ArchiveEmoji) Backup Archive: $BackupArchiveName" -ForegroundColor Cyan
        Write-Host "$($ArchiveEmoji) Archive Size: $ArchiveSize" -ForegroundColor Cyan
        Write-Host "$($ArchiveEmoji) Created: $($ArchiveInfo.CreationTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
        Write-Host "$($ArchiveEmoji) Modified: $($ArchiveInfo.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan
        Write-Host ""
        
        # Extract archive contents to temporary location for analysis
        $TempExtractPath = Join-Path $env:TEMP "CSVActiveDirectory_BackupAnalysis_$(Get-Random)"
        
        if (-not $WhatIf) {
            try {
                # Create temporary directory
                New-Item -Path $TempExtractPath -ItemType Directory -Force | Out-Null
                
                # Extract archive contents
                Expand-Archive -Path $BackupArchivePath -DestinationPath $TempExtractPath -Force
                
                # Get all backup files in the archive
                $BackupFiles = Get-ChildItem -Path $TempExtractPath -Filter "Database.backup.*.csv" | Sort-Object LastWriteTime -Descending
                
                if ($BackupFiles.Count -eq 0) {
                    Write-Host "$($InfoEmoji) No backup files found in archive" -ForegroundColor Yellow
                } else {
                    Write-Host "$($SuccessEmoji) Found $($BackupFiles.Count) backup files in archive" -ForegroundColor Green
                    Write-Host ""
                    
                    if ($Detailed) {
                        Write-Host "=== DETAILED BACKUP LIST ===" -ForegroundColor Yellow
                        $BackupFiles | ForEach-Object {
                            $Age = (Get-Date) - $_.LastWriteTime
                            $AgeText = if ($Age.Days -gt 0) { 
                                "$($Age.Days) days ago" 
                            } elseif ($Age.Hours -gt 0) { 
                                "$($Age.Hours) hours ago" 
                            } else { 
                                "$($Age.Minutes) minutes ago" 
                            }
                            
                            $FileSize = if ($_.Length -gt 1KB) { 
                                "$([math]::Round($_.Length / 1KB, 2)) KB" 
                            } else { 
                                "$($_.Length) bytes" 
                            }
                            
                            Write-Host "  $($_.Name)" -ForegroundColor White
                            Write-Host "    Created: $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
                            Write-Host "    Age: $AgeText" -ForegroundColor Gray
                            Write-Host "    Size: $FileSize" -ForegroundColor Gray
                            Write-Host ""
                        }
                    } else {
                        Write-Host "=== BACKUP SUMMARY ===" -ForegroundColor Yellow
                        $BackupFiles | ForEach-Object {
                            $Age = (Get-Date) - $_.LastWriteTime
                            $AgeText = if ($Age.Days -gt 0) { 
                                "$($Age.Days) days ago" 
                            } elseif ($Age.Hours -gt 0) { 
                                "$($Age.Hours) hours ago" 
                            } else { 
                                "$($Age.Minutes) minutes ago" 
                            }
                            
                            Write-Host "  $($_.Name) ($AgeText)" -ForegroundColor White
                        }
                    }
                    
                    # Show oldest and newest backups
                    $OldestBackup = $BackupFiles | Sort-Object LastWriteTime | Select-Object -First 1
                    $NewestBackup = $BackupFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                    
                    Write-Host ""
                    Write-Host "$($InfoEmoji) Oldest backup: $($OldestBackup.Name) ($($OldestBackup.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')))" -ForegroundColor Cyan
                    Write-Host "$($InfoEmoji) Newest backup: $($NewestBackup.Name) ($($NewestBackup.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')))" -ForegroundColor Cyan
                }
                
                # Clean up temporary directory
                Remove-Item -Path $TempExtractPath -Recurse -Force
                
                return $BackupFiles
            }
            catch {
                Write-Error "$($ErrorEmoji) Failed to analyze backup archive: $($_.Exception.Message)"
                
                # Clean up temporary directory if it exists
                if (Test-Path $TempExtractPath) {
                    Remove-Item -Path $TempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                return @()
            }
        } else {
            Write-Host "$($InfoEmoji) Would analyze backup archive: $BackupArchivePath" -ForegroundColor Cyan
            return @()
        }
    }
    catch {
        Write-Error "$($ErrorEmoji) Backup analysis failed: $($_.Exception.Message)"
        return @()
    }
}

# Export the function (only when loaded as module)
if ($MyInvocation.MyCommand.Path -eq $null) {
    Export-ModuleMember -Function Get-BackupInfo
} 