function Detect-UserIoCs {
    <#
    .SYNOPSIS
    Shared detection logic for AD user IoCs.
    .DESCRIPTION
    Returns an array of IoC hashtables for a given user, using all rules from Get-IOCs.ps1.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object]$User
    )
    $IoCs = @()

    # 1. Privilege Escalation Indicators
    if ($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*" -or $User.Title -like "*Domain*") {
        $Indicators = @()
        $Confidence = 95
        if ($User.PasswordLastSet -ne "" -and $User.PasswordLastSet -ne $null) {
            try {
                $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                if ($DaysSincePasswordSet.Days -le 7) {
                    $Indicators += "Recent password change ($($DaysSincePasswordSet.Days) days ago)"
                    $Confidence += 5
                }
            } catch { }
        }
        if ($User.BadPasswordCount -ge 3) {
            $Indicators += "High failed password attempts ($($User.BadPasswordCount))"
            $Confidence += 5
        }
        $IoCs += @{
            Type = "Privilege Escalation"
            Severity = "CRITICAL"
            Confidence = [math]::Min(100, $Confidence)
            Indicators = $Indicators
            AttackType = "Privilege Escalation / Admin Privilege Abuse"
            Description = "User has administrative privileges."
        }
    }

    # 2. Credential Dumping Indicators
    if ($User.BadPasswordCount -ge 5) {
        $Indicators = @("Excessive failed password attempts ($($User.BadPasswordCount))")
        $Confidence = 90
        if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null -and $User.BadPasswordCount -ge 3) {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 1) {
                    $Indicators += "Recent successful logon after failed attempts"
                    $Confidence += 5
                }
            } catch { }
        }
        $IoCs += @{
            Type = "Credential Dumping"
            Severity = "CRITICAL"
            Confidence = [math]::Min(100, $Confidence)
            Indicators = $Indicators
            AttackType = "Credential Harvesting / Brute Force"
            Description = "Multiple failed authentication attempts indicate credential discovery attempts."
        }
    }

    # 3. Lateral Movement Indicators
    if ($User.LogonCount -ge 200) {
        $Indicators = @("High logon count ($($User.LogonCount))")
        $Confidence = 85
        if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 7) {
                    $Indicators += "Recent high-activity logon ($($DaysSinceLogon.Days) days ago)"
                    $Confidence += 5
                }
            } catch { }
        }
        $IoCs += @{
            Type = "Lateral Movement"
            Severity = "HIGH"
            Confidence = [math]::Min(100, $Confidence)
            Indicators = $Indicators
            AttackType = "Lateral Movement / Network Traversal"
            Description = "Excessive logon activity suggests network traversal."
        }
    }

    # 4. Account Manipulation Indicators
    if ($User.Modified -ne "" -and $User.Modified -ne $null) {
        try {
            $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
            $DaysSinceModified = (Get-Date) - $ModifiedDate
            if ($DaysSinceModified.Days -le 3) {
                $IoCs += @{
                    Type = "Account Manipulation"
                    Severity = "HIGH"
                    Confidence = 80
                    Indicators = @("Recent account modification ($($DaysSinceModified.Days) days ago)")
                    AttackType = "Account Takeover / Privilege Escalation"
                    Description = "Recent account changes suggest manipulation."
                }
            }
        } catch { }
    }

    # 5. Suspicious Authentication Patterns
    if ($User.BadPasswordCount -ge 3 -and $User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            if ($DaysSinceLogon.Days -le 1) {
                $IoCs += @{
                    Type = "Suspicious Authentication"
                    Severity = "HIGH"
                    Confidence = 75
                    Indicators = @("Failed attempts followed by successful logon", "Recent activity after failed attempts")
                    AttackType = "Credential Spraying / Brute Force"
                    Description = "Failed authentication followed by successful logon."
                }
            }
        } catch { }
    }

    # 6. Service Account Abuse
    if ($User.SamAccountName -like "*svc*" -or $User.Title -like "*Service*") {
        $Indicators = @("Service account with recent activity")
        $Confidence = 70
        if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
                $LogonHour = $LastLogonDate.Hour
                if ($LogonHour -ge 18 -or $LogonHour -le 6) {
                    $Indicators += "Off-hours activity ($LogonHour:00)"
                    $Confidence += 5
                }
            } catch { }
        }
        $IoCs += @{
            Type = "Service Account Abuse"
            Severity = "MEDIUM"
            Confidence = [math]::Min(100, $Confidence)
            Indicators = $Indicators
            AttackType = "Service Account Compromise"
            Description = "Service account showing unusual activity patterns."
        }
    }

    # 7. Recently Created Account (Low Severity) - More restrictive
    if ($User.Created -ne "" -and $User.Created -ne $null) {
        try {
            $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
            $DaysSinceCreated = (Get-Date) - $CreatedDate
            if ($DaysSinceCreated.Days -le 1) {  # Only flag accounts created in the last 24 hours
                $IoCs += @{
                    Type = "Recently Created Account"
                    Severity = "LOW"
                    Confidence = 50
                    Indicators = @("Account created $($DaysSinceCreated.Days) days ago")
                    AttackType = "Account Creation / Reconnaissance"
                    Description = "Recently created account may indicate reconnaissance or testing."
                }
            }
        } catch { }
    }

    # 8. Insider Threat Indicators (More restrictive)
    if ($User.Title -like "*Admin*" -and $User.Title -notlike "*System Admin*" -and $User.Department -notlike "*IT*" -and $User.Department -notlike "*Engineering*" -and $User.Department -notlike "*Security*") {
        $IoCs += @{
            Type = "Insider Threat"
            Severity = "MEDIUM"
            Confidence = 60
            Indicators = @("Administrative role in non-IT department")
            AttackType = "Insider Threat / Privilege Abuse"
            Description = "Administrative privileges in non-technical department."
        }
    }

    # 9. Suspicious Account Naming (More restrictive)
    if ($User.SamAccountName -match '^(test|adm|svc|temp|guest|admin|demo|dev|backup|service|sys|root|support|helpdesk|qa|testuser)$' -or $User.DisplayName -match '^(test|adm|svc|temp|guest|admin|demo|dev|backup|service|sys|root|support|helpdesk|qa|testuser)$') {
        $IoCs += @{
            Type = "Suspicious Account Naming"
            Severity = "MEDIUM"
            Confidence = 60
            Indicators = @("Account name matches suspicious pattern: $($User.SamAccountName)")
            AttackType = "Reconnaissance / Account Creation"
            Description = "Account name matches patterns commonly used for test, service, or default accounts."
        }
    }

    # 10. Disabled Account with Recent Activity
    if ($User.Enabled -eq $false) {
        $HasRecentActivity = $false
        
        # Check for recent logon activity
        if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
                if (((Get-Date) - $LastLogonDate).Days -le 7) {
                    $HasRecentActivity = $true
                }
            } catch { }
        }
        
        # Check for recent modification activity
        if (-not $HasRecentActivity -and $User.Modified -ne "" -and $User.Modified -ne $null) {
            try {
                $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
                if (((Get-Date) - $ModifiedDate).Days -le 7) {
                    $HasRecentActivity = $true
                }
            } catch { }
        }
        
        if ($HasRecentActivity) {
            $IoCs += @{
                Type = "Disabled Account with Recent Activity"
                Severity = "HIGH"
                Confidence = 80
                Indicators = @("Disabled account with recent logon or modification activity")
                AttackType = "Dormant Account Abuse"
                Description = "A disabled account has recent activity, which may indicate re-enablement or abuse by an attacker."
            }
        }
    }

    # 11. Account with Password Never Set
    if (-not $User.PasswordLastSet -or $User.PasswordLastSet -eq "") {
        $IoCs += @{
            Type = "Account with Password Never Set"
            Severity = "HIGH"
            Confidence = 90
            Indicators = @("Account has no password set")
            AttackType = "Weak Account Configuration"
            Description = "Account has never had a password set, making it highly vulnerable to abuse."
        }
    }

    # 12. Enabled Account with Expired Password
    if ($User.PasswordExpired -eq $true -and $User.Enabled -eq $true) {
        $IoCs += @{
            Type = "Enabled Account with Expired Password"
            Severity = "MEDIUM"
            Confidence = 70
            Indicators = @("Enabled account with expired password")
            AttackType = "Policy Bypass / Poor Hygiene"
            Description = "Enabled account has an expired password, which may indicate a policy bypass or poor account hygiene."
        }
    }

    # 13. Locked Out Account with High Bad Password Count
    if ($User.LockedOut -eq $true -and $User.BadPasswordCount -ge 5) {
        $IoCs += @{
            Type = "Locked Out Account with High Bad Password Count"
            Severity = "HIGH"
            Confidence = 85
            Indicators = @("Account locked out after multiple failed password attempts ($($User.BadPasswordCount))")
            AttackType = "Brute Force / Password Spraying"
            Description = "Account is locked out after many failed password attempts, indicating possible brute force or password spraying attack."
        }
    }

    # 14. Unusual Logon Time
    if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
            if ($LastLogonDate.Hour -lt 7 -or $LastLogonDate.Hour -gt 19) {
                $IoCs += @{
                    Type = "Unusual Logon Time"
                    Severity = "MEDIUM"
                    Confidence = 60
                    Indicators = @("Logon occurred outside normal business hours: $($LastLogonDate.ToString('hh:mm tt'))")
                    AttackType = "After-Hours Activity"
                    Description = "Account logged on outside of normal business hours, which may indicate compromise or misuse."
                }
            }
        } catch { }
    }

    # 15. Stale Account (No Recent Logon)
    if ($User.LastLogonDate -ne "" -and $User.LastLogonDate -ne $null) {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogonDate, "M/d/yyyy h:mm tt", $null)
            if (((Get-Date) - $LastLogonDate).Days -ge 90) {
                $IoCs += @{
                    Type = "Stale Account (No Recent Logon)"
                    Severity = "MEDIUM"
                    Confidence = 65
                    Indicators = @("Account has not logged on in over 90 days")
                    AttackType = "Stale Account / Abandonment"
                    Description = "Account has not been used in over 90 days, which may indicate it is forgotten and vulnerable to abuse."
                }
            }
        } catch { }
    }

    return $IoCs
} 