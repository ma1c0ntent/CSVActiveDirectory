# Demo: Basic CSVActiveDirectory Features
# This script demonstrates the basic functionality of the module

# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

Write-Host "=== CSVActiveDirectory Basic Features Demo ===" -ForegroundColor Cyan
Write-Host ""

# 1. Basic User Management
Write-Host "1. Basic User Management" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Get all users
Write-Host "Getting all users..." -ForegroundColor Green
$AllUsers = Get-ADUser -Identity "*"
Write-Host "Found $($AllUsers.Count) users:" -ForegroundColor White
$AllUsers | Format-Table -AutoSize

Write-Host ""

# Get a specific user
Write-Host "Getting specific user (mbryan)..." -ForegroundColor Green
$User = Get-ADUser -Identity "mbryan"
if ($User) {
    Write-Host "User found: $($User.DisplayName) ($($User.SamAccountName))" -ForegroundColor White
} else {
    Write-Host "User not found" -ForegroundColor Red
}

Write-Host ""

# Get users by department
Write-Host "Getting users from Security department..." -ForegroundColor Green
$SecurityUsers = Get-ADUser -Filter "Department -eq 'Security'"
Write-Host "Found $($SecurityUsers.Count) Security users:" -ForegroundColor White
$SecurityUsers | Format-Table -AutoSize

Write-Host ""

# 2. Password Management
Write-Host "2. Password Management" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

# Test password complexity
$TestPasswords = @(
    "weak",
    "Password123",
    "StrongP@ssw0rd!"
)

foreach ($Password in $TestPasswords) {
    Write-Host "Testing password: $Password" -ForegroundColor White
    $Validation = Test-ADPasswordComplexity -Password $Password -Config (Get-ADConfig -Section "PasswordPolicy")
    
    if ($Validation.IsValid) {
        Write-Host "  Valid password" -ForegroundColor Green
    } else {
        Write-Host "  Invalid password:" -ForegroundColor Red
        foreach ($Issue in $Validation.Issues) {
            Write-Host "    - $Issue" -ForegroundColor Red
        }
    }
}

Write-Host ""

# 3. Configuration Management
Write-Host "3. Configuration Management" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Get password policy
Write-Host "Password Policy:" -ForegroundColor Green
$PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
Write-Host "  Minimum Length: $($PasswordPolicy.MinimumLength)" -ForegroundColor White
Write-Host "  Maximum Length: $($PasswordPolicy.MaximumLength)" -ForegroundColor White
Write-Host "  Require Uppercase: $($PasswordPolicy.RequireUppercase)" -ForegroundColor White
Write-Host "  Require Lowercase: $($PasswordPolicy.RequireLowercase)" -ForegroundColor White
Write-Host "  Require Numbers: $($PasswordPolicy.RequireNumbers)" -ForegroundColor White
Write-Host "  Require Special Characters: $($PasswordPolicy.RequireSpecialCharacters)" -ForegroundColor White

Write-Host ""

# 4. Simple Progress and Status
Write-Host "4. Progress and Status" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

# Simple progress
Show-ADProgress -Activity "Basic Operation" -Status "Processing..." -PercentComplete 25
Start-Sleep -Milliseconds 500
Show-ADProgress -Activity "Basic Operation" -Status "Processing..." -PercentComplete 50
Start-Sleep -Milliseconds 500
Show-ADProgress -Activity "Basic Operation" -Status "Processing..." -PercentComplete 75
Start-Sleep -Milliseconds 500
Show-ADProgress -Activity "Basic Operation" -Status "Completed" -PercentComplete 100

# Status messages
Show-ADStatus -Type "Info" -Message "Basic demo completed successfully"
Show-ADStatus -Type "Success" -Message "All operations completed"

Write-Host ""

# 5. Summary
Write-Host "5. Summary" -ForegroundColor Yellow
Write-Host "=========" -ForegroundColor Yellow

Write-Host "This demo showed:" -ForegroundColor Green
Write-Host "  User retrieval and filtering" -ForegroundColor White
Write-Host "  Password complexity validation" -ForegroundColor White
Write-Host "  Configuration management" -ForegroundColor White
Write-Host "  Progress indicators" -ForegroundColor White
Write-Host "  Status messages" -ForegroundColor White

Write-Host ""
Write-Host "=== Demo Complete ===" -ForegroundColor Cyan 