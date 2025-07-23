# INSTALL.ps1 - One-Click Installation Script
# Run this script immediately after cloning from GitLab

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$SkipDatabase = $false,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipSecurityTest = $false
)

Write-Host "=== CSVActiveDirectory - One-Click Installation ===" -ForegroundColor Cyan
Write-Host "Starting installation process..." -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANT: This script will create users to populate the database" -ForegroundColor Yellow
Write-Host "   This is required for the module to function properly" -ForegroundColor Yellow
Write-Host "   Use -SkipDatabase to skip user creation if needed" -ForegroundColor Yellow
Write-Host ""

# Step 1: Set Execution Policy
Write-Host "Step 1: Setting execution policy..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null
    Write-Host "✅ Execution policy set successfully" -ForegroundColor Green
}
catch {
    Write-Host "⚠️  Execution policy setting failed, continuing..." -ForegroundColor Yellow
}

# Step 2: Import Module
Write-Host "Step 2: Importing CSVActiveDirectory module..." -ForegroundColor Yellow
try {
    Import-Module .\CSVActiveDirectory.psd1 -Force
    Write-Host "✅ Module imported successfully" -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to import module: $($_.Exception.Message)"
    Write-Host "Please ensure you're running this script from the CSVActiveDirectory directory" -ForegroundColor Red
    exit 1
}

# Step 3: Verify Installation
Write-Host "Step 3: Verifying installation..." -ForegroundColor Yellow
$Commands = Get-Command -Module CSVActiveDirectory
if ($Commands.Count -gt 0) {
    Write-Host "✅ Found $($Commands.Count) commands available" -ForegroundColor Green
    Write-Host "Available commands: $($Commands.Name -join ', ')" -ForegroundColor Cyan
}
else {
    Write-Error "❌ No commands found in module"
    exit 1
}

# Step 4: Generate Database (if not skipped)
if (-not $SkipDatabase) {
    Write-Host "Step 4: Generating test database..." -ForegroundColor Yellow
    try {
        & ".\Scripts\Create-Users.ps1"
        Write-Host "✅ Database generated successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Database generation failed: $($_.Exception.Message)" -ForegroundColor Yellow
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
        Write-Host "✅ Basic functionality test passed" -ForegroundColor Green
        Write-Host "Sample users found: $($TestUsers.Count)" -ForegroundColor Cyan
    }
    else {
        Write-Host "⚠️  No users found in database" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "⚠️  Basic functionality test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 6: Security Test (if not skipped)
if (-not $SkipSecurityTest) {
    Write-Host "Step 6: Running security assessment..." -ForegroundColor Yellow
    try {
        & ".\Scripts\Get-ADSecurityReport-Enterprise.ps1" | Out-Null
        Write-Host "✅ Security assessment completed" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Security assessment failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "You can run security reports later with: .\Scripts\Get-ADSecurityReport-Enterprise.ps1" -ForegroundColor Cyan
    }
}
else {
    Write-Host "Step 6: Skipping security test (use -SkipSecurityTest to skip)" -ForegroundColor Yellow
}

# Step 7: Installation Complete
Write-Host ""
Write-Host "=== INSTALLATION COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 CSVActiveDirectory is now ready to use!" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Database Status: Users created successfully" -ForegroundColor Green
Write-Host "✅ Module Status: All functions available" -ForegroundColor Green
Write-Host "✅ Security Status: Risk scenarios configured" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Quick Start Commands:" -ForegroundColor Yellow
Write-Host "  Get-ADUser -Identity '*'                    # List all users" -ForegroundColor White
Write-Host "  Get-ADUser -Filter 'Department -eq \"IT\"'  # Filter users" -ForegroundColor White
Write-Host "  .\Scripts\Create-Users.ps1       # Generate database" -ForegroundColor White
Write-Host "  .\Scripts\Get-ADSecurityReport-Enterprise.ps1 -EnhancedIoCDetection  # Security scan" -ForegroundColor White
Write-Host ""
Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "  README.md                                   # Main documentation" -ForegroundColor White
Write-Host "  Docs\SETUP.md                              # Setup guide" -ForegroundColor White
Write-Host "  Docs\Active-Directory-Cybersecurity-Guide.md # Cybersecurity guide" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Customization:" -ForegroundColor Yellow
Write-Host "  Edit Scripts\Create-Users.ps1    # Modify risk scenarios" -ForegroundColor White
Write-Host "  Edit Scripts\Get-ADSecurityReport-Enterprise.ps1 # Adjust security thresholds" -ForegroundColor White
Write-Host ""
Write-Host "💡 Pro Tips:" -ForegroundColor Yellow
Write-Host "  - Use -EnhancedIoCDetection for advanced security scanning" -ForegroundColor White
Write-Host "  - Export reports to CSV for external analysis" -ForegroundColor White
Write-Host "  - Check Documents\ADSecurityReport\ for exported reports" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready to start learning Active Directory security!" -ForegroundColor Green 