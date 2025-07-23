# Test script to verify all functions are properly exported
Write-Host "Testing CSVActiveDirectory Module Functions" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

# List all exported functions
Write-Host "`nExported Functions:" -ForegroundColor Yellow
Get-Command -Module CSVActiveDirectory | Select-Object Name | Format-Table

# Test configuration functions
Write-Host "`nTesting Configuration Functions:" -ForegroundColor Yellow
try {
    $Config = Get-ADConfig -Section "DomainSettings"
    Write-Host "✓ Get-ADConfig working" -ForegroundColor Green
} catch {
    Write-Host "✗ Get-ADConfig failed: $_" -ForegroundColor Red
}

# Test password functions
Write-Host "`nTesting Password Functions:" -ForegroundColor Yellow
try {
    $PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
    $Validation = Test-ADPasswordComplexity -Password "Test123!" -Config $PasswordPolicy
    Write-Host "✓ Test-ADPasswordComplexity working" -ForegroundColor Green
} catch {
    Write-Host "✗ Test-ADPasswordComplexity failed: $_" -ForegroundColor Red
}

# Test progress functions
Write-Host "`nTesting Progress Functions:" -ForegroundColor Yellow
try {
    Show-ADProgress -Activity "Test" -Status "Testing..." -Style "Simple"
    Write-Host "✓ Show-ADProgress working" -ForegroundColor Green
} catch {
    Write-Host "✗ Show-ADProgress failed: $_" -ForegroundColor Red
}

# Test status functions
Write-Host "`nTesting Status Functions:" -ForegroundColor Yellow
try {
    Show-ADStatus -Type "Success" -Message "Test message"
    Write-Host "✓ Show-ADStatus working" -ForegroundColor Green
} catch {
    Write-Host "✗ Show-ADStatus failed: $_" -ForegroundColor Red
}

Write-Host "`nModule test completed!" -ForegroundColor Green 