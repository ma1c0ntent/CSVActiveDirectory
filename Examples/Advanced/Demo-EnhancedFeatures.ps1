# Demo-EnhancedFeatures.ps1
# Demonstrates advanced features of the CSVActiveDirectory module

# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

Write-Host "=== CSVActiveDirectory Enhanced Features Demo ===" -ForegroundColor Cyan
Write-Host ""

# 1. Basic User Retrieval
Write-Host "1. Basic User Retrieval" -ForegroundColor Yellow
Write-Host "Getting all users with default properties..."
$AllUsers = Get-ADUser -Identity "*"
$AllUsers | Format-Table -AutoSize
Write-Host ""

# 2. Extended Properties
Write-Host "2. Extended Properties" -ForegroundColor Yellow
Write-Host "Getting users with extended properties..."
$Users = Get-ADUser -Identity "*" -Properties "FirstName", "LastName", "DisplayName", "SamAccountName", "Department", "Title", "Enabled", "Modified"
$Users | Format-Table -AutoSize
Write-Host ""

# 3. Filtering Examples
Write-Host "3. Filtering Examples" -ForegroundColor Yellow

Write-Host "Users in Security department:"
$SecurityUsers = Get-ADUser -Filter "Department -eq 'Security'" -Properties *
$SecurityUsers | Format-Table DisplayName, SamAccountName, Department, Title, Enabled -AutoSize
Write-Host ""

Write-Host "Enabled users:"
$EnabledUsers = Get-ADUser -Filter "Enabled -eq 'TRUE'" -Properties *
$EnabledUsers | Select-Object -First 5 | Format-Table DisplayName, SamAccountName, Department, Title, Enabled -AutoSize
Write-Host ""

# 4. User Creation
Write-Host "4. User Creation" -ForegroundColor Yellow
Write-Host "Creating a new user..."

$NewUser = New-ADUser -SamAccountName "demouser" -FirstName "Demo" -LastName "User" -EmailAddress "demo.user@adnauseumgaming.com" -Department "IT" -Title "Developer"
Write-Host "Created user: $($NewUser.DisplayName)" -ForegroundColor Green
Write-Host ""

# 5. Account Management
Write-Host "5. Account Management" -ForegroundColor Yellow

Write-Host "Disabling the demo user..."
Disable-ADAccount -Identity "demouser"
$DisabledUser = Get-ADUser -Identity "demouser" -Properties "Enabled"
Write-Host "User enabled status: $($DisabledUser.Enabled)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Re-enabling the demo user..."
Enable-ADAccount -Identity "demouser"
$EnabledUser = Get-ADUser -Identity "demouser" -Properties "Enabled"
Write-Host "User enabled status: $($EnabledUser.Enabled)" -ForegroundColor Green
Write-Host ""

# 6. Advanced Formatting
Write-Host "6. Advanced Formatting" -ForegroundColor Yellow

Write-Host "Table format with extended properties:"
Get-ADUser -Identity "*" -Properties * | Select-Object -First 3 | Format-Table -AutoSize
Write-Host ""

Write-Host "List format with specific properties:"
Get-ADUser -Identity "mbryan" -Properties "DisplayName", "EmailAddress", "Department", "Title", "Enabled", "LastLogon" | Format-List
Write-Host ""

# 7. Bulk Operations
Write-Host "7. Bulk Operations" -ForegroundColor Yellow

Write-Host "Creating multiple users..."
$UsersToCreate = @(
    @{SamAccountName="user1"; FirstName="John"; LastName="Doe"; EmailAddress="john.doe@adnauseumgaming.com"; Department="Marketing"; Title="Analyst"},
    @{SamAccountName="user2"; FirstName="Jane"; LastName="Smith"; EmailAddress="jane.smith@adnauseumgaming.com"; Department="HR"; Title="Manager"},
    @{SamAccountName="user3"; FirstName="Bob"; LastName="Johnson"; EmailAddress="bob.johnson@adnauseumgaming.com"; Department="Sales"; Title="Representative"}
)

foreach ($UserData in $UsersToCreate) {
    $NewUser = New-ADUser @UserData
    Write-Host "Created: $($NewUser.DisplayName) - $($NewUser.Department)" -ForegroundColor Green
}
Write-Host ""

# 8. Data Analysis
Write-Host "8. Data Analysis" -ForegroundColor Yellow

Write-Host "Department distribution:"
$DepartmentStats = Get-ADUser -Identity "*" -Properties "Department" | Group-Object Department | Sort-Object Count -Descending
$DepartmentStats | Format-Table Name, Count -AutoSize
Write-Host ""

Write-Host "Title distribution:"
$TitleStats = Get-ADUser -Identity "*" -Properties "Title" | Group-Object Title | Sort-Object Count -Descending
$TitleStats | Format-Table Name, Count -AutoSize
Write-Host ""

# 9. Cleanup
Write-Host "9. Cleanup" -ForegroundColor Yellow
Write-Host "Removing demo users..."

$DemoUsers = @("demouser", "user1", "user2", "user3")
foreach ($User in $DemoUsers) {
    $ExistingUser = Get-ADUser -Identity $User -ErrorAction SilentlyContinue
    if ($ExistingUser) {
        Remove-ADUser -Identity $User -Confirm:$false
        Write-Host "Removed: $User" -ForegroundColor Red
    }
}
Write-Host ""

# 10. Final Summary
Write-Host "10. Final Summary" -ForegroundColor Yellow
$FinalCount = (Get-ADUser -Identity "*").Count
Write-Host "Total users in database: $FinalCount" -ForegroundColor Cyan

Write-Host ""
Write-Host "=== Demo Complete ===" -ForegroundColor Cyan
Write-Host "The CSVActiveDirectory module provides a comprehensive Active Directory simulation experience!" 