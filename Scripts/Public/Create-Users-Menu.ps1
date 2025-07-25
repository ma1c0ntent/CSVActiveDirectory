# Create-Users-Menu.ps1
# Interactive console menu version of Create-Users script
# Provides user-friendly options for creating databases with different configurations

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "Data\Database\Database.csv"
)

# Import required modules
try {
    Import-Module .\CSVActiveDirectory.psd1 -Force
}
catch {
    Write-Error "Failed to import CSVActiveDirectory module"
    exit 1
}

# Import shared detection logic for consistent risk calculation
. Functions\Private\Detect-UserIoCs.ps1

# Initialize emoji variables for compatibility
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"
$InfoEmoji = Get-Emoji -Type "Info"
$SearchEmoji = Get-Emoji -Type "Search"
$TargetEmoji = Get-Emoji -Type "Target"
$LightningEmoji = Get-Emoji -Type "Lightning"
$BulbEmoji = Get-Emoji -Type "Bulb"

# Function to display the main menu
function Show-MainMenu {
    Clear-Host
    Write-Host "=== CSV ACTIVE DIRECTORY - USER CREATION MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose an option:" -ForegroundColor White
    Write-Host "1. Quick Test Database (30 users)" -ForegroundColor Green
    Write-Host "2. Standard Database (100 users)" -ForegroundColor Yellow
    Write-Host "3. Large Database (250 users)" -ForegroundColor Magenta
    Write-Host "4. Enterprise Database (500 users)" -ForegroundColor Red
    Write-Host "5. Custom Configuration" -ForegroundColor Blue
    Write-Host "6. View Current Database Info" -ForegroundColor Cyan
    Write-Host "7. Exit" -ForegroundColor Gray
    Write-Host ""
}

# Function to display custom configuration menu
function Show-CustomMenu {
    Clear-Host
    Write-Host "=== CUSTOM CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose configuration options:" -ForegroundColor White
    Write-Host "1. Set User Count" -ForegroundColor Green
    Write-Host "2. Set Risk Percentage" -ForegroundColor Yellow
    Write-Host "3. Set Output Path" -ForegroundColor Magenta
    Write-Host "4. Backup Options" -ForegroundColor Blue
    Write-Host "5. Security Test Options" -ForegroundColor Cyan
    Write-Host "6. Back to Main Menu" -ForegroundColor Gray
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
            "number" {
                if ($input -match '^\d+$') {
                    return [int]$input
                } else {
                    Write-Host "Please enter a valid number." -ForegroundColor Red
                }
            }
            "percentage" {
                if ($input -match '^\d+(\.\d+)?$' -and [double]$input -ge 0 -and [double]$input -le 100) {
                    return [double]$input
                } else {
                    Write-Host "Please enter a valid percentage (0-100)." -ForegroundColor Red
                }
            }
            "path" {
                if ($input -ne "") {
                    return $input
                } else {
                    Write-Host "Please enter a valid path." -ForegroundColor Red
                }
            }
            default {
                return $input
            }
        }
    } while ($true)
}

# Function to create users with specified parameters
function Create-UsersWithParams {
    param(
        [int]$UserCount,
        [double]$RiskPercentage,
        [string]$OutputPath,
        [bool]$BackupExisting = $true,
        [bool]$SkipSecurityTest = $false
    )
    
    Write-Host "=== CREATING ENHANCED $UserCount-USER DATABASE ===" -ForegroundColor Cyan
    Write-Host "Target Risk Percentage: $RiskPercentage%" -ForegroundColor Yellow
    Write-Host "Enhanced with cybersecurity and incident response scenarios" -ForegroundColor Green
    Write-Host "Ensuring at least one user per IoC category for comprehensive testing" -ForegroundColor Magenta
    Write-Host ""
    
    # Call the actual Create-Users script with parameters
    $params = @{
        UserCount = $UserCount
        RiskPercentage = $RiskPercentage
        OutputPath = $OutputPath
        BackupExisting = $BackupExisting
        SkipSecurityTest = $SkipSecurityTest
    }
    
    # Execute the actual Create-Users script
    try {
        & "Scripts\Private\Create-Users.ps1" @params
        Write-Host "$($SuccessEmoji) Database created successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "$($ErrorEmoji) Failed to create database: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please check the parameters and try again." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to show current database info
function Show-DatabaseInfo {
    $dbPath = "Data\Database\Database.csv"
    
    if (Test-Path $dbPath) {
        try {
            $users = Import-Csv $dbPath
            $totalUsers = $users.Count
            $enabledUsers = ($users | Where-Object { $_.Enabled -eq "TRUE" }).Count
            $disabledUsers = ($users | Where-Object { $_.Enabled -eq "FALSE" }).Count
            $lockedUsers = ($users | Where-Object { $_.LockedOut -eq "TRUE" }).Count
            
            Write-Host "=== CURRENT DATABASE INFORMATION ===" -ForegroundColor Cyan
            Write-Host "Database Path: $dbPath" -ForegroundColor White
            Write-Host "Total Users: $totalUsers" -ForegroundColor Green
            Write-Host "Enabled Users: $enabledUsers" -ForegroundColor Green
            Write-Host "Disabled Users: $disabledUsers" -ForegroundColor Yellow
            Write-Host "Locked Users: $lockedUsers" -ForegroundColor Red
            Write-Host ""
            
            # Calculate risk statistics
            $riskyCount = 0
            foreach ($user in $users) {
                $IoCDetections = Detect-UserIoCs -User $user
                if ($IoCDetections.Count -gt 0) {
                    $riskyCount++
                }
            }
            
            $riskPercentage = if ($totalUsers -gt 0) { [math]::Round(($riskyCount / $totalUsers) * 100, 2) } else { 0 }
            Write-Host "Risky Users: $riskyCount" -ForegroundColor Yellow
            Write-Host "Risk Percentage: $riskPercentage%" -ForegroundColor Yellow
            Write-Host ""
            
        } catch {
            Write-Host "Error reading database: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "No database found at: $dbPath" -ForegroundColor Yellow
        Write-Host "Create a database first using one of the menu options." -ForegroundColor Cyan
    }
    
    Read-Host "Press Enter to continue"
}

# Main menu loop
$customConfig = @{
    UserCount = 100
    RiskPercentage = 30.0
    OutputPath = "Data\Database\Database.csv"
    BackupExisting = $true
    SkipSecurityTest = $false
}

do {
    Show-MainMenu
    $choice = Read-Host "Enter your choice (1-7)"
    
    switch ($choice) {
        "1" {
            # Quick Test Database
            Create-UsersWithParams -UserCount 30 -RiskPercentage 25.0 -OutputPath $customConfig.OutputPath -BackupExisting $customConfig.BackupExisting -SkipSecurityTest $customConfig.SkipSecurityTest
            exit 0
        }
        "2" {
            # Standard Database
            Create-UsersWithParams -UserCount 100 -RiskPercentage 30.0 -OutputPath $customConfig.OutputPath -BackupExisting $customConfig.BackupExisting -SkipSecurityTest $customConfig.SkipSecurityTest
            exit 0
        }
        "3" {
            # Large Database
            Create-UsersWithParams -UserCount 250 -RiskPercentage 35.0 -OutputPath $customConfig.OutputPath -BackupExisting $customConfig.BackupExisting -SkipSecurityTest $customConfig.SkipSecurityTest
            exit 0
        }
        "4" {
            # Enterprise Database
            Create-UsersWithParams -UserCount 500 -RiskPercentage 40.0 -OutputPath $customConfig.OutputPath -BackupExisting $customConfig.BackupExisting -SkipSecurityTest $customConfig.SkipSecurityTest
            exit 0
        }
        "5" {
            # Custom Configuration
            do {
                Show-CustomMenu
                $customChoice = Read-Host "Enter your choice (1-6)"
                
                switch ($customChoice) {
                    "1" {
                        $customConfig.UserCount = Get-UserInput "Enter user count (minimum 30): " "100" "number"
                        if ($customConfig.UserCount -lt 30) {
                            Write-Host "Setting minimum user count to 30" -ForegroundColor Yellow
                            $customConfig.UserCount = 30
                        }
                    }
                    "2" {
                        $customConfig.RiskPercentage = Get-UserInput "Enter risk percentage (0-100): " "30.0" "percentage"
                    }
                    "3" {
                        $customConfig.OutputPath = Get-UserInput "Enter output path: " "Data\Database\Database.csv" "path"
                    }
                    "4" {
                        $backupChoice = Read-Host "Create backup of existing database? (y/n): "
                        $customConfig.BackupExisting = $backupChoice -eq "y" -or $backupChoice -eq "Y"
                    }
                    "5" {
                        $testChoice = Read-Host "Skip security test after creation? (y/n): "
                        $customConfig.SkipSecurityTest = $testChoice -eq "y" -or $testChoice -eq "Y"
                    }
                    "6" {
                        break
                    }
                    default {
                        Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                    }
                }
            } while ($customChoice -ne "6")
            
            # Execute custom configuration
            Create-UsersWithParams -UserCount $customConfig.UserCount -RiskPercentage $customConfig.RiskPercentage -OutputPath $customConfig.OutputPath -BackupExisting $customConfig.BackupExisting -SkipSecurityTest $customConfig.SkipSecurityTest
            exit 0
        }
        "6" {
            # View Current Database Info
            Show-DatabaseInfo
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
