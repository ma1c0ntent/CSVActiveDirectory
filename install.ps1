# install.ps1 - One-Click Installation Script
# Run this script immediately after cloning from GitLab

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$SkipDatabase,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipSecurityTest
)

# Initialize emoji variables for compatibility
. .\Functions\Private\Get-Emoji.ps1
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"
$InfoEmoji = Get-Emoji -Type "Info"
$RocketEmoji = Get-Emoji -Type "Rocket"
$BulbEmoji = Get-Emoji -Type "Bulb"



Write-Host "=== CSVActiveDirectory - One-Click Installation ===" -ForegroundColor Cyan
Write-Host "Starting installation process..." -ForegroundColor Green
Write-Host ""
Write-Host "$($WarningEmoji) IMPORTANT: This script will create users to populate the database" -ForegroundColor Yellow
Write-Host "   This is required for the module to function properly" -ForegroundColor Yellow
Write-Host "   Use -SkipDatabase to skip user creation if needed" -ForegroundColor Yellow
Write-Host ""

# Step 1: Set Execution Policy
Write-Host "Step 1: Setting execution policy..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null
    Write-Host "$($SuccessEmoji) Execution policy set successfully" -ForegroundColor Green
}
catch {
    Write-Host "$($WarningEmoji) Execution policy setting failed, continuing..." -ForegroundColor Yellow
}

# Step 2: Import Module
Write-Host "Step 2: Importing CSVActiveDirectory module..." -ForegroundColor Yellow
try {
    Import-Module .\CSVActiveDirectory.psd1 -Force
    Write-Host "$($SuccessEmoji) Module imported successfully" -ForegroundColor Green
}
catch {
    Write-Error "$($ErrorEmoji) Failed to import module: $($_.Exception.Message)"
    Write-Host "Please ensure you're running this script from the CSVActiveDirectory directory" -ForegroundColor Red
    exit 1
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
    exit 1
}

# Step 4: Generate Database (if not skipped)
if (-not $SkipDatabase) {
    Write-Host "Step 4: Generating test database..." -ForegroundColor Yellow
    try {
        $CreateUsersParams = @{
            SkipSecurityTest = $SkipSecurityTest
        }
        & ".\Scripts\Create-Users.ps1" @CreateUsersParams
        Write-Host "$($SuccessEmoji) Database generated successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "$($WarningEmoji) Database generation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "You can generate the database later with: .\Scripts\Create-Users.ps1" -ForegroundColor Cyan
    }
}
else {
    Write-Host "Step 4: Skipping database generation (use -SkipDatabase to skip)" -ForegroundColor Yellow
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
    }
}
catch {
    Write-Host "$($WarningEmoji) Basic functionality test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 6: Security Test (if not skipped)
if (-not $SkipSecurityTest) {
    Write-Host "Step 6: Running security assessment..." -ForegroundColor Yellow
    try {
        & ".\Scripts\Get-SecurityReport.ps1" | Out-Null
        Write-Host "$($SuccessEmoji) Security assessment completed" -ForegroundColor Green
    }
    catch {
        Write-Host "$($WarningEmoji) Security assessment failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "You can run security reports later with: .\Scripts\Get-SecurityReport.ps1" -ForegroundColor Cyan
    }
}
else {
    Write-Host "Step 6: Skipping security test (use -SkipSecurityTest to skip)" -ForegroundColor Yellow
}

# Step 7: Installation Complete
Write-Host ""
Write-Host "=== INSTALLATION COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "$($RocketEmoji) CSVActiveDirectory is now ready to use!" -ForegroundColor Cyan
Write-Host ""
Write-Host "$($SuccessEmoji) Database Status: Users created successfully" -ForegroundColor Green
Write-Host "$($SuccessEmoji) Module Status: All functions available" -ForegroundColor Green
Write-Host "$($SuccessEmoji) Security Status: Risk scenarios configured" -ForegroundColor Green
Write-Host ""
Write-Host "$($InfoEmoji) Quick Start Commands:" -ForegroundColor Yellow
Write-Host "  Get-ADUser -Identity '*'                    # List all users" -ForegroundColor White
Write-Host "  Get-ADUser -Filter 'Department -eq \"IT\"'  # Filter users" -ForegroundColor White
Write-Host "  .\Scripts\Create-Users.ps1       # Generate database" -ForegroundColor White
Write-Host "  .\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection  # Security scan" -ForegroundColor White
Write-Host ""
Write-Host "$($InfoEmoji) Documentation:" -ForegroundColor Yellow
Write-Host "  README.md                                   # Main documentation" -ForegroundColor White
Write-Host "  Docs\SETUP.md                              # Setup guide" -ForegroundColor White
Write-Host "  Docs\Active-Directory-Cybersecurity-Guide.md # Cybersecurity guide" -ForegroundColor White
Write-Host ""
Write-Host "$($BulbEmoji) Customization:" -ForegroundColor Yellow
Write-Host "  Edit Scripts\Create-Users.ps1    # Modify risk scenarios" -ForegroundColor White
Write-Host "  Edit Scripts\Get-SecurityReport.ps1 # Adjust security thresholds" -ForegroundColor White
Write-Host ""
Write-Host "$($BulbEmoji) Pro Tips:" -ForegroundColor Yellow
Write-Host "  - Use -EnhancedIoCDetection for advanced security scanning" -ForegroundColor White
Write-Host "  - Export reports to CSV for external analysis" -ForegroundColor White
Write-Host "  - Check Documents\ADSecurityReport\ for exported reports" -ForegroundColor White
Write-Host ""
Write-Host "$($RocketEmoji) Ready to start learning Active Directory security!" -ForegroundColor Green 
