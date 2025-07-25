# Test Password Complexity
Import-Module ..\..\CSVActiveDirectory.psd1 -Force

Write-Host "Testing Password Complexity" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# Get password policy
$PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
Write-Host "Password Policy:" -ForegroundColor Yellow
$PasswordPolicy | Format-List

# Test various passwords
$TestPasswords = @(
    "weak",
    "Weak123",
    "Weak123!",
    "StrongP@ssw0rd!",
    "VeryLongPassword123!@#"
)

foreach ($Password in $TestPasswords) {
    Write-Host "`nTesting: $Password" -ForegroundColor White
    $Validation = Test-ADPasswordComplexity -Password $Password -Config $PasswordPolicy
    
    if ($Validation.IsValid) {
        Write-Host "Valid password" -ForegroundColor Green
    } else {
        Write-Host "Invalid password:" -ForegroundColor Red
        foreach ($Issue in $Validation.Issues) {
            Write-Host "  - $Issue" -ForegroundColor Red
        }
    }
} 