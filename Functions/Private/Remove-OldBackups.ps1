# Remove-OldBackups.ps1
# Private function for removing old backups from the single archive file

function Remove-OldBackups {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$BackupFolder = "Data\Database\Backups",
        
        [Parameter(Mandatory = $false)]
        [string]$BackupArchiveName = "DatabaseBackups.zip",
        
        [Parameter(Mandatory = $false)]
        [int]$KeepDays = 7,
        
        [Parameter(Mandatory = $false)]
        [int]$KeepCount = 10,
        
        [Parameter(Mandatory = $false)]
        [switch]$KeepAll = $false,
        
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf = $false,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force = $false
    )
    
    # Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $ErrorEmoji = Get-Emoji -Type "Error"
    $WarningEmoji = Get-Emoji -Type "Warning"
    $InfoEmoji = Get-Emoji -Type "Info"
    $TrashEmoji = Get-Emoji -Type "Error"
} catch {
    # Fallback to text if emoji function not available
    $SuccessEmoji = "[OK]"
    $ErrorEmoji = "[ERROR]"
    $WarningEmoji = "[WARN]"
    $InfoEmoji = "[INFO]"
    $TrashEmoji = "[DELETE]"
}
    
    try {
        $BackupArchivePath = Join-Path $BackupFolder $BackupArchiveName
        
        # Check if backup archive exists
        if (-not (Test-Path $BackupArchivePath)) {
            Write-Host "$($InfoEmoji) No backup archive found: $BackupArchivePath" -ForegroundColor Yellow
            return $false
        }
        
        # Extract archive contents to temporary location
        $TempExtractPath = Join-Path $env:TEMP "CSVActiveDirectory_BackupCleanup_$(Get-Random)"
        
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
                    return $true
                }
                
                Write-Host "$($InfoEmoji) Found $($BackupFiles.Count) backup files in archive" -ForegroundColor Cyan
                
                # Determine which files to keep and which to remove
                $FilesToKeep = @()
                $FilesToRemove = @()
                
                if ($KeepAll) {
                    # Keep all files
                    $FilesToKeep = $BackupFiles
                    Write-Host "$($InfoEmoji) Keeping all $($BackupFiles.Count) backup files" -ForegroundColor Green
                } else {
                    # Apply retention policies
                    $CutoffDate = (Get-Date).AddDays(-$KeepDays)
                    
                    # Keep files by age (newer than cutoff date)
                    $AgeBasedKeep = $BackupFiles | Where-Object { $_.LastWriteTime -ge $CutoffDate }
                    
                    # Keep files by count (keep the newest N files)
                    $CountBasedKeep = $BackupFiles | Select-Object -First $KeepCount
                    
                    # Combine both policies - keep files that meet either criteria
                    $FilesToKeep = @($AgeBasedKeep + $CountBasedKeep) | Sort-Object LastWriteTime -Unique
                    $FilesToRemove = $BackupFiles | Where-Object { $FilesToKeep -notcontains $_ }
                    
                    Write-Host "$($InfoEmoji) Age-based retention: Keeping files newer than $KeepDays days" -ForegroundColor Cyan
                    Write-Host "$($InfoEmoji) Count-based retention: Keeping newest $KeepCount files" -ForegroundColor Cyan
                    Write-Host "$($InfoEmoji) Files to keep: $($FilesToKeep.Count)" -ForegroundColor Green
                    Write-Host "$($InfoEmoji) Files to remove: $($FilesToRemove.Count)" -ForegroundColor Yellow
                }
                
                # Show files that will be removed
                if ($FilesToRemove.Count -gt 0) {
                    Write-Host ""
                    Write-Host "=== FILES TO BE REMOVED ===" -ForegroundColor Red
                    $TotalSize = 0
                    $FilesToRemove | ForEach-Object {
                        $Age = (Get-Date) - $_.LastWriteTime
                        $AgeText = if ($Age.Days -gt 0) { 
                            "$($Age.Days) days ago" 
                        } elseif ($Age.Hours -gt 0) { 
                            "$($Age.Hours) hours ago" 
                        } else { 
                            "$($Age.Minutes) minutes ago" 
                        }
                        
                        Write-Host "  $($_.Name) ($AgeText, $($_.Length) bytes)" -ForegroundColor Red
                        $TotalSize += $_.Length
                    }
                    
                    $SizeText = if ($TotalSize -gt 1MB) { 
                        "$([math]::Round($TotalSize / 1MB, 2)) MB" 
                    } elseif ($TotalSize -gt 1KB) { 
                        "$([math]::Round($TotalSize / 1KB, 2)) KB" 
                    } else { 
                        "$TotalSize bytes" 
                    }
                    
                    Write-Host ""
                    Write-Host "Total files to remove: $($FilesToRemove.Count)" -ForegroundColor Yellow
                    Write-Host "Total size to free: $SizeText" -ForegroundColor Yellow
                }
                
                # Confirmation prompt (unless -Force is used)
                if ($FilesToRemove.Count -gt 0 -and -not $Force -and -not $WhatIf) {
                    Write-Host ""
                    Write-Host "$($WarningEmoji) WARNING: This action cannot be undone!" -ForegroundColor Red
                    $Confirmation = Read-Host "Are you sure you want to remove these backup files? (y/N)"
                    if ($Confirmation -notmatch '^[Yy]$') {
                        Write-Host "$($InfoEmoji) Operation cancelled by user" -ForegroundColor Yellow
                        return $false
                    }
                }
                
                # Perform cleanup
                if ($FilesToRemove.Count -gt 0 -and -not $WhatIf) {
                    Write-Host ""
                    Write-Host "=== REMOVING FILES ===" -ForegroundColor Red
                    
                    foreach ($File in $FilesToRemove) {
                        try {
                            Remove-Item -Path $File.FullName -Force
                            Write-Host "$($TrashEmoji) Removed: $($File.Name)" -ForegroundColor Red
                        }
                        catch {
                            Write-Error "$($ErrorEmoji) Failed to remove $($File.Name): $($_.Exception.Message)"
                        }
                    }
                    
                    # Recreate archive with remaining files
                    Write-Host ""
                    Write-Host "=== RECREATING ARCHIVE ===" -ForegroundColor Cyan
                    
                    # Remove old archive
                    Remove-Item -Path $BackupArchivePath -Force
                    
                    # Create new archive with remaining files
                    if ($FilesToKeep.Count -gt 0) {
                        $FilesToKeep | ForEach-Object {
                            Compress-Archive -Path $_.FullName -DestinationPath $BackupArchivePath -Update
                        }
                        Write-Host "$($SuccessEmoji) Recreated backup archive with $($FilesToKeep.Count) files" -ForegroundColor Green
                    } else {
                        Write-Host "$($WarningEmoji) No files remaining - archive will be empty" -ForegroundColor Yellow
                    }
                } elseif ($WhatIf) {
                    Write-Host "$($InfoEmoji) WHAT-IF MODE: No files will actually be removed" -ForegroundColor Cyan
                }
                
                # Clean up temporary directory
                Remove-Item -Path $TempExtractPath -Recurse -Force
                
                return $true
            }
            catch {
                Write-Error "$($ErrorEmoji) Failed to clean up backup archive: $($_.Exception.Message)"
                
                # Clean up temporary directory if it exists
                if (Test-Path $TempExtractPath) {
                    Remove-Item -Path $TempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                return $false
            }
        } else {
            Write-Host "$($InfoEmoji) Would analyze and clean up backup archive: $BackupArchivePath" -ForegroundColor Cyan
            return $true
        }
    }
    catch {
        Write-Error "$($ErrorEmoji) Backup cleanup failed: $($_.Exception.Message)"
        return $false
    }
}

# Export the function (only when loaded as module)
if ($MyInvocation.MyCommand.Path -eq $null) {
    Export-ModuleMember -Function Remove-OldBackups
} 