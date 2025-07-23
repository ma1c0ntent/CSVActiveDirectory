# Queries.ps1
# Individual query functions for Active Directory security analysis
# Each function can be highlighted and run independently for focused analysis

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Warning "Active Directory module not available. Using CSV simulation module."
    Import-Module .\CSVActiveDirectory.psd1 -Force
}

# Get all users with extended properties (cached for performance)
$script:AllUsers = $null

function Get-AllUsers {
    if ($null -eq $script:AllUsers) {
        try {
            $script:AllUsers = Get-ADUser -Filter * -Properties *
        }
        catch {
            Write-Warning "Using CSV simulation data"
            $script:AllUsers = Get-ADUser -Identity "*" -Properties *
        }
    }
    return $script:AllUsers
}

# Helper function to display results
function Show-QueryResults {
    param(
        [string]$QueryName,
        [array]$Results,
        [string]$RiskLevel,
        [string]$Description
    )
    
    Write-Host "=== $QueryName ===" -ForegroundColor Cyan
    Write-Host "Risk Level: $RiskLevel" -ForegroundColor $(switch ($RiskLevel) { "CRITICAL" { "Red" } "HIGH" { "Yellow" } "MEDIUM" { "Magenta" } "LOW" { "Blue" } })
    Write-Host "Description: $Description" -ForegroundColor Gray
    Write-Host "Found: $($Results.Count) accounts" -ForegroundColor White
    Write-Host ""
    
    if ($Results.Count -gt 0) {
        $Results | Format-Table SamAccountName, DisplayName, Department, Title, Enabled, LastLogon, BadPasswordCount, LockoutTime -AutoSize -Wrap
    } else {
        Write-Host "✅ No accounts found matching this criteria." -ForegroundColor Green
    }
    Write-Host ""
}

# CRITICAL RISK QUERIES

function Find-LockedButEnabledAccounts {
    <#
    .SYNOPSIS
    Finds accounts that are locked due to failed password attempts but remain enabled.
    
    .DESCRIPTION
    CRITICAL RISK: Accounts that are locked but still enabled pose a significant security risk
    as they could be targeted for further attack attempts or indicate a compromised account.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LockoutTime -ne "" -and $User.Enabled -eq "TRUE") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LastLogon = $User.LastLogon
                BadPasswordCount = $User.BadPasswordCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "CRITICAL"
                Reason = "Locked but Enabled Account"
                Details = "Account is locked due to failed password attempts but remains enabled"
            }
        }
    }
    
    Show-QueryResults -QueryName "Locked but Enabled Accounts" -Results $Results -RiskLevel "CRITICAL" -Description "Accounts locked due to failed attempts but still enabled"
    return $Results
}
# Find-LockedButEnabledAccounts

function Find-HighFailedPasswordAttempts {
    <#
    .SYNOPSIS
    Finds accounts with excessive failed password attempts that are not locked.
    
    .DESCRIPTION
    CRITICAL RISK: Accounts with 5+ failed password attempts but not locked indicate
    potential brute force attacks or security policy issues.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.BadPasswordCount -ge 5 -and $User.LockoutTime -eq "") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LastLogon = $User.LastLogon
                BadPasswordCount = $User.BadPasswordCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "CRITICAL"
                Reason = "High Failed Password Attempts"
                Details = "Account has $($User.BadPasswordCount) failed password attempts but is not locked"
            }
        }
    }
    
    Show-QueryResults -QueryName "High Failed Password Attempts" -Results $Results -RiskLevel "CRITICAL" -Description "Accounts with 5+ failed attempts but not locked"
    return $Results
}
# Find-HighFailedPasswordAttempts

function Find-NeverLoggedOnButEnabled {
    <#
    .SYNOPSIS
    Finds accounts that have never been used but are still enabled.
    
    .DESCRIPTION
    CRITICAL RISK: Never-logged-on enabled accounts are potential security risks
    as they could be orphaned accounts or targets for attackers.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LastLogon -eq "" -and $User.Enabled -eq "TRUE" -and $User.LogonCount -eq 0) {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LastLogon = $User.LastLogon
                LogonCount = $User.LogonCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "CRITICAL"
                Reason = "Never Logged On but Enabled"
                Details = "Account has never been used but is enabled"
            }
        }
    }
    
    Show-QueryResults -QueryName "Never Logged On but Enabled" -Results $Results -RiskLevel "CRITICAL" -Description "Accounts that have never been used but are enabled"
    return $Results
}
# Find-NeverLoggedOnButEnabled

function Find-UnusedServiceAccounts {
    <#
    .SYNOPSIS
    Finds service accounts that are enabled but have never been used.
    
    .DESCRIPTION
    CRITICAL RISK: Unused service accounts that are enabled pose security risks
    as they could be targeted by attackers or indicate orphaned accounts.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if (($User.SamAccountName -like "*svc*" -or $User.SamAccountName -like "*service*") -and 
            $User.Enabled -eq "TRUE" -and $User.LogonCount -eq 0) {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LastLogon = $User.LastLogon
                LogonCount = $User.LogonCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "CRITICAL"
                Reason = "Unused Service Account"
                Details = "Service account is enabled but has never been used"
            }
        }
    }
    
    Show-QueryResults -QueryName "Unused Service Accounts" -Results $Results -RiskLevel "CRITICAL" -Description "Service accounts that are enabled but never used"
    return $Results
}
# Find-UnusedServiceAccounts

function Find-PrivilegedAccountPasswordChanges {
    <#
    .SYNOPSIS
    Finds privileged accounts with recent password changes (within 7 days).
    
    .DESCRIPTION
    CRITICAL RISK: Recent password changes on privileged accounts could indicate
    privilege escalation attempts or compromised credentials.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if (($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*") -and $User.PasswordLastSet -ne "") {
            try {
                $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                if ($DaysSincePasswordSet.Days -le 7) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        PasswordLastSet = $User.PasswordLastSet
                        DaysSincePasswordSet = $DaysSincePasswordSet.Days
                        RiskLevel = "CRITICAL"
                        Reason = "Privileged Account Password Change"
                        Details = "Privileged account password changed $($DaysSincePasswordSet.Days) days ago"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Privileged Account Password Changes" -Results $Results -RiskLevel "CRITICAL" -Description "Privileged accounts with recent password changes"
    return $Results
}
# Find-PrivilegedAccountPasswordChanges

function Find-ExpiredButEnabledAccounts {
    <#
    .SYNOPSIS
    Finds accounts that have expired but are still enabled.
    
    .DESCRIPTION
    CRITICAL RISK: Expired accounts that remain enabled violate security policies
    and could be exploited by attackers.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.AccountExpires -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ExpirationDate = [DateTime]::ParseExact($User.AccountExpires, "M/d/yyyy h:mm tt", $null)
                if ((Get-Date) -gt $ExpirationDate) {
                    $DaysExpired = ((Get-Date) - $ExpirationDate).Days
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        AccountExpires = $User.AccountExpires
                        DaysExpired = $DaysExpired
                        RiskLevel = "CRITICAL"
                        Reason = "Expired but Enabled Account"
                        Details = "Account expired $DaysExpired days ago but remains enabled"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Expired but Enabled Accounts" -Results $Results -RiskLevel "CRITICAL" -Description "Accounts that have expired but remain enabled"
    return $Results
}
# Find-ExpiredButEnabledAccounts

function Find-ServiceAccountsWithAdminPrivileges {
    <#
    .SYNOPSIS
    Finds service accounts that have administrative privileges.
    
    .DESCRIPTION
    CRITICAL RISK: Service accounts with admin privileges pose significant security risks
    as they could be exploited for privilege escalation attacks.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.SamAccountName -like "*svc*" -and $User.Title -like "*Admin*") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LastLogon = $User.LastLogon
                RiskLevel = "CRITICAL"
                Reason = "Service Account with Admin Privileges"
                Details = "Service account has administrative privileges"
            }
        }
    }
    
    Show-QueryResults -QueryName "Service Accounts with Admin Privileges" -Results $Results -RiskLevel "CRITICAL" -Description "Service accounts with administrative privileges"
    return $Results
}
# Find-ServiceAccountsWithAdminPrivileges

function Find-SuspiciousAccountNaming {
    <#
    .SYNOPSIS
    Finds accounts with suspicious naming patterns that are enabled.
    
    .DESCRIPTION
    CRITICAL RISK: Accounts with suspicious naming patterns could indicate
    reconnaissance activities or unauthorized account creation.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    $SuspiciousNames = @("admin", "administrator", "test", "guest", "temp", "demo", "backup", "service")
    
    foreach ($User in $Users) {
        foreach ($Pattern in $SuspiciousNames) {
            if ($User.SamAccountName -like "*$Pattern*" -and $User.Enabled -eq "TRUE") {
                $Results += [PSCustomObject]@{
                    SamAccountName = $User.SamAccountName
                    DisplayName = $User.DisplayName
                    Department = $User.Department
                    Title = $User.Title
                    Enabled = $User.Enabled
                    SuspiciousPattern = $Pattern
                    RiskLevel = "CRITICAL"
                    Reason = "Suspicious Account Naming"
                    Details = "Account with suspicious naming pattern: $Pattern"
                }
                break
            }
        }
    }
    
    Show-QueryResults -QueryName "Suspicious Account Naming" -Results $Results -RiskLevel "CRITICAL" -Description "Accounts with suspicious naming patterns"
    return $Results
}
# Find-SuspiciousAccountNaming

# HIGH RISK QUERIES

function Find-InactiveButEnabledAccounts {
    <#
    .SYNOPSIS
    Finds accounts that haven't logged on for 90+ days but are still enabled.
    
    .DESCRIPTION
    HIGH RISK: Inactive enabled accounts should be disabled to reduce attack surface.
    #>
    
    param([int]$InactiveDays = 90)
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LastLogon -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -ge $InactiveDays) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        LastLogon = $User.LastLogon
                        DaysInactive = $DaysSinceLogon.Days
                        RiskLevel = "HIGH"
                        Reason = "Inactive but Enabled Account"
                        Details = "Account hasn't logged on for $($DaysSinceLogon.Days) days but remains enabled"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Inactive but Enabled Accounts" -Results $Results -RiskLevel "HIGH" -Description "Accounts inactive for $InactiveDays+ days but still enabled"
    return $Results
}
# Find-InactiveButEnabledAccounts

function Find-OldPasswords {
    <#
    .SYNOPSIS
    Finds accounts with old passwords (90+ days) that are still enabled.
    
    .DESCRIPTION
    HIGH RISK: Old passwords increase the risk of credential compromise.
    #>
    
    param([int]$PasswordAgeDays = 90)
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.PasswordLastSet -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                if ($DaysSincePasswordSet.Days -ge $PasswordAgeDays) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        PasswordLastSet = $User.PasswordLastSet
                        DaysSincePasswordSet = $DaysSincePasswordSet.Days
                        RiskLevel = "HIGH"
                        Reason = "Old Password"
                        Details = "Password hasn't been changed for $($DaysSincePasswordSet.Days) days"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Old Passwords" -Results $Results -RiskLevel "HIGH" -Description "Accounts with passwords older than $PasswordAgeDays days"
    return $Results
}
# Find-OldPasswords

function Find-HighActivityLockedAccounts {
    <#
    .SYNOPSIS
    Finds high-activity accounts that are currently locked.
    
    .DESCRIPTION
    HIGH RISK: High-activity locked accounts could be service accounts or power users
    that need immediate attention.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LogonCount -ge 200 -and $User.LockoutTime -ne "") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LogonCount = $User.LogonCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "HIGH"
                Reason = "High Activity Account Locked"
                Details = "High-activity account ($($User.LogonCount) logons) is currently locked"
            }
        }
    }
    
    Show-QueryResults -QueryName "High Activity Locked Accounts" -Results $Results -RiskLevel "HIGH" -Description "High-activity accounts that are currently locked"
    return $Results
}
# Find-HighActivityLockedAccounts

function Find-SuspiciousAuthPatterns {
    <#
    .SYNOPSIS
    Finds accounts with suspicious authentication patterns.
    
    .DESCRIPTION
    HIGH RISK: Failed logon attempts followed by successful logon could indicate
    brute force attacks or credential compromise.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.BadPasswordCount -ge 3 -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 1) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        BadPasswordCount = $User.BadPasswordCount
                        LastLogon = $User.LastLogon
                        DaysSinceLogon = $DaysSinceLogon.Days
                        RiskLevel = "HIGH"
                        Reason = "Suspicious Auth Pattern"
                        Details = "Account has $($User.BadPasswordCount) failed attempts but recent successful logon"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Suspicious Auth Patterns" -Results $Results -RiskLevel "HIGH" -Description "Accounts with failed attempts followed by recent successful logon"
    return $Results
}
# Find-SuspiciousAuthPatterns

function Find-ServiceAccountOffHoursActivity {
    <#
    .SYNOPSIS
    Finds service accounts with off-hours activity.
    
    .DESCRIPTION
    HIGH RISK: Service accounts logging in during off-hours could indicate
    abuse or unauthorized access.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.SamAccountName -like "*svc*" -and $User.Enabled -eq "TRUE" -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $LogonHour = $LastLogonDate.Hour
                # Service accounts logging in during off-hours (6 PM - 6 AM)
                if ($LogonHour -ge 18 -or $LogonHour -le 6) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        LastLogon = $User.LastLogon
                        LogonHour = $LogonHour
                        RiskLevel = "HIGH"
                        Reason = "Service Account Off-Hours Activity"
                        Details = "Service account logged in during off-hours ($LogonHour:00)"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Service Account Off-Hours Activity" -Results $Results -RiskLevel "HIGH" -Description "Service accounts with off-hours logon activity"
    return $Results
}
# Find-ServiceAccountOffHoursActivity

function Find-HighActivityRecentLogons {
    <#
    .SYNOPSIS
    Finds high-activity accounts with recent logon activity.
    
    .DESCRIPTION
    HIGH RISK: High-activity accounts with recent activity could indicate
    lateral movement or credential abuse.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LogonCount -ge 500 -and $User.Enabled -eq "TRUE" -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 7) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        LogonCount = $User.LogonCount
                        LastLogon = $User.LastLogon
                        DaysSinceLogon = $DaysSinceLogon.Days
                        RiskLevel = "HIGH"
                        Reason = "High Activity Recent Logon"
                        Details = "High-activity account ($($User.LogonCount) logons) with recent activity"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "High Activity Recent Logons" -Results $Results -RiskLevel "HIGH" -Description "High-activity accounts with recent logon activity"
    return $Results
}
# Find-HighActivityRecentLogons

function Find-AccountsExpiringSoon {
    <#
    .SYNOPSIS
    Finds accounts that are expiring within 30 days.
    
    .DESCRIPTION
    HIGH RISK: Accounts expiring soon need attention to prevent service disruption.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.AccountExpires -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ExpirationDate = [DateTime]::ParseExact($User.AccountExpires, "M/d/yyyy h:mm tt", $null)
                $DaysUntilExpiration = ($ExpirationDate - (Get-Date)).Days
                if ($DaysUntilExpiration -ge 0 -and $DaysUntilExpiration -le 30) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        AccountExpires = $User.AccountExpires
                        DaysUntilExpiration = $DaysUntilExpiration
                        RiskLevel = "HIGH"
                        Reason = "Account Expiring Soon"
                        Details = "Account expires in $DaysUntilExpiration days"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Accounts Expiring Soon" -Results $Results -RiskLevel "HIGH" -Description "Accounts expiring within 30 days"
    return $Results
}
# Find-AccountsExpiringSoon

# MEDIUM RISK QUERIES

function Find-RecentlyActiveDisabledAccounts {
    <#
    .SYNOPSIS
    Finds disabled accounts with recent activity.
    
    .DESCRIPTION
    MEDIUM RISK: Recently active disabled accounts could indicate
    unauthorized re-enabling or suspicious activity.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.Enabled -eq "FALSE" -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 30) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        LastLogon = $User.LastLogon
                        DaysSinceLogon = $DaysSinceLogon.Days
                        RiskLevel = "MEDIUM"
                        Reason = "Recently Active Disabled Account"
                        Details = "Account was disabled but had recent activity ($($DaysSinceLogon.Days) days ago)"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Recently Active Disabled Accounts" -Results $Results -RiskLevel "MEDIUM" -Description "Disabled accounts with recent activity"
    return $Results
}
# Find-RecentlyActiveDisabledAccounts

function Find-ModerateFailedPasswordAttempts {
    <#
    .SYNOPSIS
    Finds accounts with moderate failed password attempts (3-4).
    
    .DESCRIPTION
    MEDIUM RISK: Moderate failed attempts should be monitored for potential attacks.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.BadPasswordCount -ge 3 -and $User.BadPasswordCount -lt 5) {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                BadPasswordCount = $User.BadPasswordCount
                LockoutTime = $User.LockoutTime
                RiskLevel = "MEDIUM"
                Reason = "Moderate Failed Password Attempts"
                Details = "Account has $($User.BadPasswordCount) failed password attempts"
            }
        }
    }
    
    Show-QueryResults -QueryName "Moderate Failed Password Attempts" -Results $Results -RiskLevel "MEDIUM" -Description "Accounts with 3-4 failed password attempts"
    return $Results
}
# Find-ModerateFailedPasswordAttempts

function Find-NewAccountsNoActivity {
    <#
    .SYNOPSIS
    Finds new accounts (30+ days old) with no activity.
    
    .DESCRIPTION
    MEDIUM RISK: New accounts with no activity could be orphaned or unused accounts.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.Created -ne "" -and $User.LastLogon -eq "") {
            try {
                $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
                $DaysSinceCreated = (Get-Date) - $CreatedDate
                if ($DaysSinceCreated.Days -ge 30) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        Created = $User.Created
                        DaysSinceCreated = $DaysSinceCreated.Days
                        RiskLevel = "MEDIUM"
                        Reason = "New Account No Activity"
                        Details = "Account created $($DaysSinceCreated.Days) days ago but never used"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "New Accounts No Activity" -Results $Results -RiskLevel "MEDIUM" -Description "New accounts (30+ days) with no activity"
    return $Results
}
# Find-NewAccountsNoActivity

function Find-NewSuspiciousAccounts {
    <#
    .SYNOPSIS
    Finds new accounts (7 days or less) with suspicious naming patterns.
    
    .DESCRIPTION
    MEDIUM RISK: New accounts with suspicious naming could indicate reconnaissance
    or unauthorized account creation.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    $SuspiciousPatterns = @("test", "admin", "user", "guest", "temp", "demo")
    
    foreach ($User in $Users) {
        if ($User.Created -ne "") {
            try {
                $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
                $DaysSinceCreated = (Get-Date) - $CreatedDate
                if ($DaysSinceCreated.Days -le 7) {
                    foreach ($Pattern in $SuspiciousPatterns) {
                        if ($User.SamAccountName -like "*$Pattern*") {
                            $Results += [PSCustomObject]@{
                                SamAccountName = $User.SamAccountName
                                DisplayName = $User.DisplayName
                                Department = $User.Department
                                Title = $User.Title
                                Enabled = $User.Enabled
                                Created = $User.Created
                                DaysSinceCreated = $DaysSinceCreated.Days
                                SuspiciousPattern = $Pattern
                                RiskLevel = "MEDIUM"
                                Reason = "New Suspicious Account"
                                Details = "New account with suspicious naming pattern: $Pattern"
                            }
                            break
                        }
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "New Suspicious Accounts" -Results $Results -RiskLevel "MEDIUM" -Description "New accounts with suspicious naming patterns"
    return $Results
}
# Find-NewSuspiciousAccounts

function Find-RoleDepartmentMismatches {
    <#
    .SYNOPSIS
    Finds administrative roles in non-IT departments.
    
    .DESCRIPTION
    MEDIUM RISK: Administrative roles in non-IT departments could indicate
    insider threats or role misconfigurations.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.Title -like "*Admin*" -and $User.Department -notlike "*IT*" -and $User.Department -notlike "*Engineering*") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                RiskLevel = "MEDIUM"
                Reason = "Role-Department Mismatch"
                Details = "Administrative role in non-IT department"
            }
        }
    }
    
    Show-QueryResults -QueryName "Role-Department Mismatches" -Results $Results -RiskLevel "MEDIUM" -Description "Administrative roles in non-IT departments"
    return $Results
}
# Find-RoleDepartmentMismatches

function Find-UnusualActivityPatterns {
    <#
    .SYNOPSIS
    Finds accounts with unusual activity patterns.
    
    .DESCRIPTION
    MEDIUM RISK: High-activity accounts with failed password attempts could indicate
    credential dumping or abuse.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.LogonCount -ge 200 -and $User.BadPasswordCount -ge 2 -and $User.Enabled -eq "TRUE") {
            $Results += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName = $User.DisplayName
                Department = $User.Department
                Title = $User.Title
                Enabled = $User.Enabled
                LogonCount = $User.LogonCount
                BadPasswordCount = $User.BadPasswordCount
                RiskLevel = "MEDIUM"
                Reason = "Unusual Activity Pattern"
                Details = "High-activity account with failed password attempts"
            }
        }
    }
    
    Show-QueryResults -QueryName "Unusual Activity Patterns" -Results $Results -RiskLevel "MEDIUM" -Description "High-activity accounts with failed password attempts"
    return $Results
}
# Find-UnusualActivityPatterns

function Find-RecentlyModifiedAccounts {
    <#
    .SYNOPSIS
    Finds accounts that were recently modified (within 3 days).
    
    .DESCRIPTION
    MEDIUM RISK: Recently modified accounts could indicate account manipulation
    or unauthorized changes.
    #>
    
    $Users = Get-AllUsers
    $Results = @()
    
    foreach ($User in $Users) {
        if ($User.Modified -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
                $DaysSinceModified = (Get-Date) - $ModifiedDate
                if ($DaysSinceModified.Days -le 3) {
                    $Results += [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        DisplayName = $User.DisplayName
                        Department = $User.Department
                        Title = $User.Title
                        Enabled = $User.Enabled
                        Modified = $User.Modified
                        DaysSinceModified = $DaysSinceModified.Days
                        RiskLevel = "MEDIUM"
                        Reason = "Recently Modified Account"
                        Details = "Account modified $($DaysSinceModified.Days) days ago"
                    }
                }
            }
            catch { }
        }
    }
    
    Show-QueryResults -QueryName "Recently Modified Accounts" -Results $Results -RiskLevel "MEDIUM" -Description "Accounts modified within 3 days"
    return $Results
}
# Find-RecentlyModifiedAccounts

# Utility function to run all queries
function Invoke-AllQueries {
    <#
    .SYNOPSIS
    Runs all security queries and displays a comprehensive report.
    
    .DESCRIPTION
    Executes all individual query functions and provides a summary of findings.
    #>
    
    Write-Host "=== COMPREHENSIVE SECURITY QUERY REPORT ===" -ForegroundColor Cyan
    Write-Host "Running all security queries..." -ForegroundColor Yellow
    Write-Host ""
    
    $AllResults = @()
    
    # CRITICAL RISKS
    $AllResults += Find-LockedButEnabledAccounts
    $AllResults += Find-HighFailedPasswordAttempts
    $AllResults += Find-NeverLoggedOnButEnabled
    $AllResults += Find-UnusedServiceAccounts
    $AllResults += Find-PrivilegedAccountPasswordChanges
    $AllResults += Find-ExpiredButEnabledAccounts
    $AllResults += Find-ServiceAccountsWithAdminPrivileges
    $AllResults += Find-SuspiciousAccountNaming
    
    # HIGH RISKS
    $AllResults += Find-InactiveButEnabledAccounts
    $AllResults += Find-OldPasswords
    $AllResults += Find-HighActivityLockedAccounts
    $AllResults += Find-SuspiciousAuthPatterns
    $AllResults += Find-ServiceAccountOffHoursActivity
    $AllResults += Find-HighActivityRecentLogons
    $AllResults += Find-AccountsExpiringSoon
    
    # MEDIUM RISKS
    $AllResults += Find-RecentlyActiveDisabledAccounts
    $AllResults += Find-ModerateFailedPasswordAttempts
    $AllResults += Find-NewAccountsNoActivity
    $AllResults += Find-NewSuspiciousAccounts
    $AllResults += Find-RoleDepartmentMismatches
    $AllResults += Find-UnusualActivityPatterns
    $AllResults += Find-RecentlyModifiedAccounts
    
    # Summary
    $CriticalCount = ($AllResults | Where-Object { $_.RiskLevel -eq "CRITICAL" }).Count
    $HighCount = ($AllResults | Where-Object { $_.RiskLevel -eq "HIGH" }).Count
    $MediumCount = ($AllResults | Where-Object { $_.RiskLevel -eq "MEDIUM" }).Count
    
    Write-Host "=== SUMMARY ===" -ForegroundColor Green
    Write-Host "Total Findings: $($AllResults.Count)" -ForegroundColor White
    Write-Host "Critical Risks: $CriticalCount" -ForegroundColor Red
    Write-Host "High Risks: $HighCount" -ForegroundColor Yellow
    Write-Host "Medium Risks: $MediumCount" -ForegroundColor Magenta
    Write-Host ""
    
    return $AllResults
}
# Invoke-AllQueries

Write-Host "=== AD SECURITY QUERIES LOADED ===" -ForegroundColor Green
Write-Host "Available functions:" -ForegroundColor Cyan
Write-Host "• Find-LockedButEnabledAccounts" -ForegroundColor White
Write-Host "• Find-HighFailedPasswordAttempts" -ForegroundColor White
Write-Host "• Find-NeverLoggedOnButEnabled" -ForegroundColor White
Write-Host "• Find-UnusedServiceAccounts" -ForegroundColor White
Write-Host "• Find-PrivilegedAccountPasswordChanges" -ForegroundColor White
Write-Host "• Find-ExpiredButEnabledAccounts" -ForegroundColor White
Write-Host "• Find-ServiceAccountsWithAdminPrivileges" -ForegroundColor White
Write-Host "• Find-SuspiciousAccountNaming" -ForegroundColor White
Write-Host "• Find-InactiveButEnabledAccounts" -ForegroundColor White
Write-Host "• Find-OldPasswords" -ForegroundColor White
Write-Host "• Find-HighActivityLockedAccounts" -ForegroundColor White
Write-Host "• Find-SuspiciousAuthPatterns" -ForegroundColor White
Write-Host "• Find-ServiceAccountOffHoursActivity" -ForegroundColor White
Write-Host "• Find-HighActivityRecentLogons" -ForegroundColor White
Write-Host "• Find-AccountsExpiringSoon" -ForegroundColor White
Write-Host "• Find-RecentlyActiveDisabledAccounts" -ForegroundColor White
Write-Host "• Find-ModerateFailedPasswordAttempts" -ForegroundColor White
Write-Host "• Find-NewAccountsNoActivity" -ForegroundColor White
Write-Host "• Find-NewSuspiciousAccounts" -ForegroundColor White
Write-Host "• Find-RoleDepartmentMismatches" -ForegroundColor White
Write-Host "• Find-UnusualActivityPatterns" -ForegroundColor White
Write-Host "• Find-RecentlyModifiedAccounts" -ForegroundColor White
Write-Host "• Invoke-AllQueries" -ForegroundColor Green
Write-Host ""
Write-Host "Highlight any function above and press F8 to run it!" -ForegroundColor Yellow 