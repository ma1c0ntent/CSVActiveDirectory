# install.ps1 - One-Click Installation Script with Interactive Menu
# Run this script immediately after cloning from GitLab

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$SkipDatabase,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipSecurityTest,
    
    [Parameter(Mandatory = $false)]
    [switch]$Interactive
)

# Set the current working directory to the script's directory
$CurrentDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $CurrentDirectory

# Initialize emoji variables for compatibility
. .\Functions\Private\Get-Emoji.ps1
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"
$InfoEmoji = Get-Emoji -Type "Info"
$RocketEmoji = Get-Emoji -Type "Rocket"
$BulbEmoji = Get-Emoji -Type "Bulb"
$SearchEmoji = Get-Emoji -Type "Search"
$TargetEmoji = Get-Emoji -Type "Target"
$LightningEmoji = Get-Emoji -Type "Lightning"

# Function to display the main installation menu
function Show-InstallMenu {
    Clear-Host
    Write-Host "=== CSV ACTIVE DIRECTORY - INSTALLATION MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose an installation option:" -ForegroundColor White
    Write-Host "1. Quick Install (Basic setup)" -ForegroundColor Green
    Write-Host "2. Standard Install (With database)" -ForegroundColor Yellow
    Write-Host "3. Full Install (With database + security test)" -ForegroundColor Magenta
    Write-Host "4. Custom Install (Configure options)" -ForegroundColor Blue
    Write-Host "5. System Check (Verify requirements)" -ForegroundColor Cyan
    Write-Host "6. View Documentation" -ForegroundColor Gray
    Write-Host "7. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to display custom installation menu
function Show-CustomInstallMenu {
    Clear-Host
    Write-Host "=== CUSTOM INSTALLATION CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure installation options:" -ForegroundColor White
    Write-Host "1. Database Options" -ForegroundColor Green
    Write-Host "2. Security Test Options" -ForegroundColor Yellow
    Write-Host "3. Execution Policy Options" -ForegroundColor Magenta
    Write-Host "4. Module Import Options" -ForegroundColor Blue
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

# Function to perform system check
function Test-SystemRequirements {
    Write-Host "=== SYSTEM REQUIREMENTS CHECK ===" -ForegroundColor Cyan
    Write-Host ""
    
    $allGood = $true
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-Host "PowerShell Version: $psVersion" -ForegroundColor White
    if ($psVersion.Major -ge 5) {
        Write-Host "$($SuccessEmoji) PowerShell version is compatible" -ForegroundColor Green
    } else {
        Write-Host "$($ErrorEmoji) PowerShell 5.0 or higher required" -ForegroundColor Red
        $allGood = $false
    }
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Write-Host "Running as Administrator: $isAdmin" -ForegroundColor White
    if ($isAdmin) {
        Write-Host "$($SuccessEmoji) Running with administrative privileges" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Not running as administrator (some features may be limited)" -ForegroundColor Yellow
    }
    
    # Check if module files exist
    $moduleFile = "CSVActiveDirectory.psd1"
    if (Test-Path $moduleFile) {
        Write-Host "$($SuccessEmoji) Module file found: $moduleFile" -ForegroundColor Green
    } else {
        Write-Host "$($ErrorEmoji) Module file not found: $moduleFile" -ForegroundColor Red
        $allGood = $false
    }
    
    # Check if Functions directory exists
    if (Test-Path "Functions") {
        Write-Host "$($SuccessEmoji) Functions directory found" -ForegroundColor Green
    } else {
        Write-Host "$($ErrorEmoji) Functions directory not found" -ForegroundColor Red
        $allGood = $false
    }
    
    Write-Host ""
    if ($allGood) {
        Write-Host "$($SuccessEmoji) All system requirements met!" -ForegroundColor Green
    } else {
        Write-Host "$($ErrorEmoji) Some requirements not met. Please resolve issues before installation." -ForegroundColor Red
    }
    
    Read-Host "Press Enter to continue"
    return $allGood
}

# Function to show documentation
function Show-Documentation {
    Clear-Host
    Write-Host "=== DOCUMENTATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available documentation:" -ForegroundColor White
    Write-Host "1. README.md - Main documentation" -ForegroundColor Green
    Write-Host "2. Docs\SETUP.md - Setup guide" -ForegroundColor Yellow
    Write-Host "3. Docs\Active-Directory-Cybersecurity-Guide.md - Security guide" -ForegroundColor Magenta
    Write-Host "4. Docs\CSV-Export-Guide.md - Export guide" -ForegroundColor Blue
    Write-Host "5. Back to Main Menu" -ForegroundColor Gray
    Write-Host ""
    
    $docChoice = Read-Host "Enter your choice (1-5)"
    
    switch ($docChoice) {
        "1" {
            if (Test-Path "README.md") {
                Get-Content "README.md" | Select-Object -First 20
            } else {
                Write-Host "README.md not found" -ForegroundColor Red
            }
        }
        "2" {
            if (Test-Path "Docs\SETUP.md") {
                Get-Content "Docs\SETUP.md" | Select-Object -First 20
            } else {
                Write-Host "Docs\SETUP.md not found" -ForegroundColor Red
            }
        }
        "3" {
            if (Test-Path "Docs\Active-Directory-Cybersecurity-Guide.md") {
                Get-Content "Docs\Active-Directory-Cybersecurity-Guide.md" | Select-Object -First 20
            } else {
                Write-Host "Docs\Active-Directory-Cybersecurity-Guide.md not found" -ForegroundColor Red
            }
        }
        "4" {
            if (Test-Path "Docs\CSV-Export-Guide.md") {
                Get-Content "Docs\CSV-Export-Guide.md" | Select-Object -First 20
            } else {
                Write-Host "Docs\CSV-Export-Guide.md not found" -ForegroundColor Red
            }
        }
        "5" {
            return
        }
        default {
            Write-Host "Invalid choice." -ForegroundColor Red
        }
    }
    
    Read-Host "Press Enter to continue"
}

# Function to perform installation steps
function Install-CSVActiveDirectory {
    param(
        [bool]$CreateDatabase = $false,
        [bool]$RunSecurityTest = $false,
        [bool]$SetExecutionPolicy = $true,
        [bool]$ImportModule = $true
    )
    $success = $true
    Write-Host "=== CSVActiveDirectory - Installation Process ===" -ForegroundColor Cyan
    Write-Host "Starting installation with selected options..." -ForegroundColor Green
    Write-Host ""
    
    if ($CreateDatabase) {
        Write-Host "$($WarningEmoji) IMPORTANT: This will create users to populate the database" -ForegroundColor Yellow
        Write-Host "   This is required for the module to function properly" -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Step 1: Set Execution Policy
    if ($SetExecutionPolicy) {
        Write-Host "Step 1: Setting execution policy..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null
            Write-Host "$($SuccessEmoji) Execution policy set successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "$($WarningEmoji) Execution policy setting failed, continuing..." -ForegroundColor Yellow
        }
    }
    
    # Step 2: Import Module
    if ($ImportModule) {
        Write-Host "Step 2: Importing CSVActiveDirectory module..." -ForegroundColor Yellow
        try {
            Import-Module .\CSVActiveDirectory.psd1 -Force
            Write-Host "$($SuccessEmoji) Module imported successfully" -ForegroundColor Green
        }
        catch {
            Write-Error "$($ErrorEmoji) Failed to import module: $($_.Exception.Message)"
            Write-Host "Please ensure you're running this script from the CSVActiveDirectory directory" -ForegroundColor Red
            $success = $false
            # Don't return immediately; let the summary show failure
        }
    }
    
    # Step 3: Verify Installation
    Write-Host "Step 3: Verifying installation..." -ForegroundColor Yellow
    $Commands = Get-Command -Module CSVActiveDirectory
    if ($Commands.Count -gt 0) {
        Write-Host "$($SuccessEmoji) Found $($Commands.Count) commands available" -ForegroundColor Green
        Write-Host "Available commands: $($Commands.Name -join ', ')" -ForegroundColor Cyan
    }
    else {
        Write-Error "$($ErrorEmoji) No commands found in module"
        $success = $false
    }
    
    # Step 4: Generate Database (if requested)
    if ($CreateDatabase) {
        Write-Host "Step 4: Generating test database..." -ForegroundColor Yellow
        try {
            $CreateUsersParams = @{
                SkipSecurityTest = -not $RunSecurityTest
            }
            & ".\Scripts\Private\Create-Users.ps1" @CreateUsersParams
            Write-Host "$($SuccessEmoji) Database generated successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "$($WarningEmoji) Database generation failed: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "You can generate the database later with: .\Scripts\Private\Create-Users.ps1" -ForegroundColor Cyan
            $success = $false
        }
    }
    
    # Step 5: Test Basic Functionality
    Write-Host "Step 5: Testing basic functionality..." -ForegroundColor Yellow
    try {
        $TestUsers = Get-ADUser -Identity "*" | Select-Object -First 3
        if ($TestUsers) {
            Write-Host "$($SuccessEmoji) Basic functionality test passed" -ForegroundColor Green
            Write-Host "Sample users found: $($TestUsers.Count)" -ForegroundColor Cyan
        }
        else {
            Write-Host "$($WarningEmoji) No users found in database" -ForegroundColor Yellow
            $success = $false
        }
    }
    catch {
        Write-Host "$($WarningEmoji) Basic functionality test failed: $($_.Exception.Message)" -ForegroundColor Yellow
        $success = $false
    }
    
    # Step 6: Security Test (if requested)
    if ($RunSecurityTest) {
        Write-Host "Step 6: Running security assessment..." -ForegroundColor Yellow
        try {
            & ".\Scripts\Public\Get-SecurityReport.ps1" | Out-Null
            Write-Host "$($SuccessEmoji) Security assessment completed" -ForegroundColor Green
        }
        catch {
            Write-Host "$($WarningEmoji) Security assessment failed: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "You can run security reports later with: .\Scripts\Public\Get-SecurityReport.ps1" -ForegroundColor Cyan
            $success = $false
        }
    }
    
    # Step 7: Installation Complete
    Write-Host ""
    Write-Host "=== INSTALLATION COMPLETE ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "$($RocketEmoji) CSVActiveDirectory is now ready to use!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "$($SuccessEmoji) Module Status: All functions available" -ForegroundColor Green
    if ($CreateDatabase) {
        Write-Host "$($SuccessEmoji) Database Status: Users created successfully" -ForegroundColor Green
    }
    if ($RunSecurityTest) {
        Write-Host "$($SuccessEmoji) Security Status: Risk scenarios configured" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "$($InfoEmoji) Quick Start Commands:" -ForegroundColor Yellow
    Write-Host "  Get-ADUser -Identity '*'                    # List all users" -ForegroundColor White
    Write-Host "  Get-ADUser -Filter 'Department -eq \"IT\"'  # Filter users" -ForegroundColor White
    Write-Host "  .\Scripts\Private\Create-Users.ps1       # Generate database" -ForegroundColor White
    Write-Host "  .\Scripts\Public\Get-SecurityReport.ps1 -EnhancedIoCDetection  # Security scan" -ForegroundColor White
    Write-Host ""
    Write-Host "$($InfoEmoji) Documentation:" -ForegroundColor Yellow
    Write-Host "  README.md                                   # Main documentation" -ForegroundColor White
    Write-Host "  Docs\SETUP.md                              # Setup guide" -ForegroundColor White
    Write-Host "  Docs\Active-Directory-Cybersecurity-Guide.md # Cybersecurity guide" -ForegroundColor White
    Write-Host ""
    Write-Host "$($BulbEmoji) Customization:" -ForegroundColor Yellow
    Write-Host "  Edit Scripts\Private\Create-Users.ps1    # Modify risk scenarios" -ForegroundColor White
    Write-Host "  Edit Scripts\Public\Get-SecurityReport.ps1 # Adjust security thresholds" -ForegroundColor White
    Write-Host ""
    Write-Host "$($BulbEmoji) Pro Tips:" -ForegroundColor Yellow
    Write-Host "  - Use -EnhancedIoCDetection for advanced security scanning" -ForegroundColor White
    Write-Host "  - Export reports to CSV for external analysis" -ForegroundColor White
    Write-Host "  - Check Documents\ADSecurityReport\ for exported reports" -ForegroundColor White
    Write-Host ""
    Write-Host "$($RocketEmoji) Ready to start learning Active Directory security!" -ForegroundColor Green
    Write-Host ""
    if ($success) {
        Write-Host "==== SUMMARY: INSTALLATION SUCCESSFUL ====" -ForegroundColor Green
    } else {
        Write-Host "==== SUMMARY: INSTALLATION HAD ERRORS ====" -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Press Enter to return to the menu"
    return $success
}

# Main script logic
if ($Interactive -or $PSBoundParameters.Count -eq 0) {
    # Interactive menu mode
    $customConfig = @{
        CreateDatabase = $true
        RunSecurityTest = $true
        SetExecutionPolicy = $true
        ImportModule = $true
    }
    
    do {
        Show-InstallMenu
        $choice = Read-Host "Enter your choice (1-7)"
        
        switch ($choice) {
            "1" {
                # Quick Install
                Install-CSVActiveDirectory -CreateDatabase $false -RunSecurityTest $false
                exit 0
            }
            "2" {
                # Standard Install
                Install-CSVActiveDirectory -CreateDatabase $true -RunSecurityTest $false
                exit 0
            }
            "3" {
                # Full Install
                Install-CSVActiveDirectory -CreateDatabase $true -RunSecurityTest $true
                exit 0
            }
            "4" {
                # Custom Install
                do {
                    Show-CustomInstallMenu
                    $customChoice = Read-Host "Enter your choice (1-5)"
                    
                    switch ($customChoice) {
                        "1" {
                            $customConfig.CreateDatabase = Get-UserInput "Create database? (Y/N): " "Y" "yesno"
                        }
                        "2" {
                            $customConfig.RunSecurityTest = Get-UserInput "Run security test? (Y/N): " "Y" "yesno"
                        }
                        "3" {
                            $customConfig.SetExecutionPolicy = Get-UserInput "Set execution policy? (Y/N): " "Y" "yesno"
                        }
                        "4" {
                            $customConfig.ImportModule = Get-UserInput "Import module? (Y/N): " "Y" "yesno"
                        }
                        "5" {
                            break
                        }
                        default {
                            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                            Start-Sleep -Seconds 2
                        }
                    }
                } while ($customChoice -ne "5")
                
                # Execute custom configuration
                Install-CSVActiveDirectory -CreateDatabase $customConfig.CreateDatabase -RunSecurityTest $customConfig.RunSecurityTest -SetExecutionPolicy $customConfig.SetExecutionPolicy -ImportModule $customConfig.ImportModule
                exit 0
            }
            "5" {
                # System Check
                Test-SystemRequirements
            }
            "6" {
                # View Documentation
                Show-Documentation
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
    Install-CSVActiveDirectory -CreateDatabase (-not $SkipDatabase) -RunSecurityTest (-not $SkipSecurityTest)
} 
