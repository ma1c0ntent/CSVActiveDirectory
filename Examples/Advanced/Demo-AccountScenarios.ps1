# Demo: Account Scenarios
# This script demonstrates the realistic account scenarios in the database

Import-Module .\CSVActiveDirectory.psd1 -Force

Write-Host "=== CSVActiveDirectory Account Scenarios Demo ===" -ForegroundColor Cyan
Write-Host ""

# Get all users with all properties for analysis
$AllUsers = Get-ADUser -Identity "*" -Properties *

Write-Host "1. Account Status Analysis" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Analyze account statuses with robust date parsing
$LockedAccounts = Search-ADAccount -LockedOut
$DisabledAccounts = $AllUsers | Where-Object { $_.Enabled -eq "FALSE" }
$HighActivityAccounts = $AllUsers | Where-Object { [int]$_.LogonCount -ge 100 -and [datetime]$_.whenCreated -ge $(Get-Date).AddDays(-30) }

# Improved inactive accounts detection with better date parsing
$InactiveAccounts = $AllUsers | Where-Object { 
    # Skip if LastLogon is empty or null
    if ([string]::IsNullOrWhiteSpace($_.LastLogonDate)) {
        return $false
    }
    
    try {
        [datetime]$_.LastLogonDate -le $(Get-Date).AddDays(-30)
    }
    catch {
        return $false
    }
}

Write-Host "Account Distribution:" -ForegroundColor Green
Write-Host "  Total Users: $($AllUsers.Count)" -ForegroundColor White
Write-Host "  Locked Out Accounts: $($LockedAccounts.Name.Count)" -ForegroundColor Red
Write-Host "  Disabled Accounts: $($DisabledAccounts.Count)" -ForegroundColor Yellow
Write-Host "  High Activity Accounts: $($HighActivityAccounts.Count)" -ForegroundColor Green
Write-Host "  Inactive Accounts (30+ days): $($InactiveAccounts.Count)" -ForegroundColor Magenta

Write-Host ""

# Show locked out accounts
Write-Host "2. Locked Out Accounts" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
Write-Host "These accounts have exceeded the maximum failed password attempts:" -ForegroundColor White

$LockedAccounts | Select-Object -First 5 | Format-Table SamAccountName, DisplayName, BadPasswordCount, LockoutTime, LastLogon -AutoSize

Write-Host ""

# Show disabled accounts
Write-Host "3. Disabled Accounts" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "These accounts have been disabled due to inactivity (90+ days old):" -ForegroundColor White

$DisabledAccounts | Select-Object -First 5 | Format-Table SamAccountName, DisplayName, Enabled, LastLogon, LogonCount -AutoSize

Write-Host ""

# Show high activity accounts
Write-Host "4. High Activity Accounts" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "These accounts show frequent usage (200+ logons):" -ForegroundColor White

$HighActivityAccounts | Select-Object -First 5 | Format-Table SamAccountName, DisplayName, LogonCount, LastLogon, BadPasswordCount -AutoSize

Write-Host ""

# Show inactive accounts
Write-Host "5. Inactive Accounts" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "These accounts haven't logged on in 30+ days:" -ForegroundColor White

$InactiveAccounts | Select-Object -First 5 | Format-Table SamAccountName, DisplayName, LastLogon, LogonCount, Enabled -AutoSize

Write-Host ""

# Demonstrate account management functions
Write-Host "6. Account Management Functions" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

# Show how to find locked accounts
Write-Host "Finding locked accounts (BadPasswordCount >= 6):" -ForegroundColor Green
$LockedFilter = "BadPasswordCount -ge 6"
$LockedByFilter = Get-ADUser -Filter $LockedFilter -Properties *
Write-Host "Found $($LockedByFilter.Count) locked accounts using filter" -ForegroundColor White

# Show how to find disabled accounts
Write-Host "Finding disabled accounts:" -ForegroundColor Green
$DisabledFilter = "Enabled -eq 'FALSE'"
$DisabledByFilter = Get-ADUser -Filter $DisabledFilter -Properties *
Write-Host "Found $($DisabledByFilter.Count) disabled accounts using filter" -ForegroundColor White

# Show how to find high activity accounts
Write-Host "Finding high activity accounts (LogonCount >= 200):" -ForegroundColor Green
$HighActivityFilter = "LogonCount -ge 200"
$HighActivityByFilter = Get-ADUser -Filter $HighActivityFilter -Properties *
Write-Host "Found $($HighActivityByFilter.Count) high activity accounts using filter" -ForegroundColor White

Write-Host ""

# Demonstrate account operations
Write-Host "7. Account Operations Demo" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Get a sample disabled account
$SampleDisabled = $DisabledAccounts | Select-Object -First 1
if ($SampleDisabled) {
    Write-Host "Sample disabled account: $($SampleDisabled.SamAccountName)" -ForegroundColor White
    Write-Host "  Current status: $($SampleDisabled.Enabled)" -ForegroundColor White
    Write-Host "  Last logon: $($SampleDisabled.LastLogon)" -ForegroundColor White
    Write-Host "  Logon count: $($SampleDisabled.LogonCount)" -ForegroundColor White
    
    # Note: In a real scenario, you might enable this account
    Write-Host "  (In a real scenario, you could enable this account with Enable-ADAccount)" -ForegroundColor Gray
}

Write-Host ""

# Show account statistics with improved calculations
Write-Host "8. Account Statistics" -ForegroundColor Yellow
Write-Host "====================" -ForegroundColor Yellow

# Improved statistics calculation with error handling
try {
    $LogonCounts = $AllUsers | Where-Object { ![string]::IsNullOrEmpty($_.LogonCount) } | ForEach-Object { [int]$_.LogonCount }
    $BadPasswordCounts = $AllUsers | Where-Object { ![string]::IsNullOrEmpty($_.BadPasswordCount) } | ForEach-Object { [int]$_.BadPasswordCount }
    
    $AvgLogonCount = if ($LogonCounts.Count -gt 0) { ($LogonCounts | Measure-Object -Average).Average } else { 0 }
    $AvgBadPasswordCount = if ($BadPasswordCounts.Count -gt 0) { ($BadPasswordCounts | Measure-Object -Average).Average } else { 0 }
} catch {
    $AvgLogonCount = 0
    $AvgBadPasswordCount = 0
}

$EnabledCount = ($AllUsers | Where-Object { $_.Enabled -eq "TRUE" }).Count
$DisabledCount = ($AllUsers | Where-Object { $_.Enabled -eq "FALSE" }).Count

Write-Host "Account Statistics:" -ForegroundColor Green
Write-Host "  Average Logon Count: $([math]::Round($AvgLogonCount, 1))" -ForegroundColor White
Write-Host "  Average Bad Password Count: $([math]::Round($AvgBadPasswordCount, 1))" -ForegroundColor White
Write-Host "  Enabled Accounts: $EnabledCount" -ForegroundColor White
Write-Host "  Disabled Accounts: $DisabledCount" -ForegroundColor White

Write-Host ""

# Show department distribution with improved error handling
Write-Host "9. Department Analysis" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow

$Departments = $AllUsers | Group-Object Department | Sort-Object Count -Descending
Write-Host "Users by Department:" -ForegroundColor Green
foreach ($Dept in $Departments) {
    $DeptLocked = ($Dept.Group | Where-Object { ![string]::IsNullOrEmpty($_.BadPasswordCount) -and [int]$_.BadPasswordCount -ge 6 }).Count
    $DeptDisabled = ($Dept.Group | Where-Object { $_.Enabled -eq "FALSE" }).Count
    Write-Host "  $($Dept.Name): $($Dept.Count) users ($DeptLocked locked, $DeptDisabled disabled)" -ForegroundColor White
}

Write-Host ""

# Show account status breakdown
Write-Host "10. Account Status Breakdown" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow

$AccountStatuses = $AllUsers | Group-Object AccountStatus | Sort-Object Count -Descending
Write-Host "Account Status Distribution:" -ForegroundColor Green
foreach ($Status in $AccountStatuses) {
    $StatusColor = switch ($Status.Name) {
        "LOCKED" { "Red" }
        "DISABLED" { "Yellow" }
        "HIGH_ACTIVITY" { "Green" }
        "INACTIVE" { "Magenta" }
        default { "White" }
    }
    Write-Host "  $($Status.Name): $($Status.Count) accounts" -ForegroundColor $StatusColor
}

Write-Host ""

Write-Host "11. Summary" -ForegroundColor Yellow
Write-Host "===========" -ForegroundColor Yellow

Write-Host "This demo showed:" -ForegroundColor Green
Write-Host "  Realistic account scenarios (locked, disabled, high activity, inactive)" -ForegroundColor White
Write-Host "  Account filtering and analysis" -ForegroundColor White
Write-Host "  Account statistics and metrics" -ForegroundColor White
Write-Host "  Department-based analysis" -ForegroundColor White
Write-Host "  Account management capabilities" -ForegroundColor White
Write-Host "  Account status breakdown" -ForegroundColor White

Write-Host ""
Write-Host "The database now contains realistic Active Directory scenarios that simulate:" -ForegroundColor Cyan
Write-Host "  • Users who failed password attempts and got locked out" -ForegroundColor White
Write-Host "  • Inactive accounts that were disabled after 90+ days" -ForegroundColor White
Write-Host "  • High-activity users with frequent logons" -ForegroundColor White
Write-Host "  • Normal users with typical activity patterns" -ForegroundColor White

Write-Host ""
Write-Host "=== Demo Complete ===" -ForegroundColor Cyan 
