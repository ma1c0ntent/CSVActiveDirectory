# Get-ADSecurityReport-Enterprise.ps1
# Enterprise-grade security report for Active Directory user accounts
# Enhanced with additional IoC detection patterns
# Designed for real AD environments with export capabilities

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeDisabled = $true,
    
    [Parameter(Mandatory=$false)]
    [int]$InactiveDays = 90,
    
    [Parameter(Mandatory=$false)]
    [int]$PasswordAgeDays = 90,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedReport = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnhancedIoCDetection = $true,
    
    [Parameter(Mandatory=$false)]
    [string]$ExportCSV = "$env:USERPROFILE\Documents\ADSecurityReport\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Warning "Active Directory module not available. Using CSV simulation module."
    Import-Module .\CSVActiveDirectory.psd1 -Force
}

Write-Host "=== ENTERPRISE AD SECURITY REPORT ===" -ForegroundColor Cyan
Write-Host "Enhanced with IoC detection patterns..." -ForegroundColor Yellow
Write-Host "Scanning for dangerous user accounts..." -ForegroundColor Yellow
Write-Host ""

# Initialize report data
$ReportData = @{
    ScanTime = Get-Date
    TotalUsers = 0
    CriticalRisks = @()
    HighRisks = @()
    MediumRisks = @()
    LowRisks = @()
    Summary = @{}
    Recommendations = @()
    IoCDetections = @{
        GoldenTicket = 0
        PrivilegeEscalation = 0
        CredentialDumping = 0
        LateralMovement = 0
        AccountManipulation = 0
        SuspiciousAuth = 0
        ServiceAccountAbuse = 0
        Reconnaissance = 0
        DataExfiltration = 0
        InsiderThreat = 0
    }
}

# Get all users with extended properties
try {
    $AllUsers = Get-ADUser -Filter * -Properties *
    $ReportData.TotalUsers = $AllUsers.Count
}
catch {
    Write-Warning "Using CSV simulation data"
    $AllUsers = Get-ADUser -Identity "*" -Properties *
    $ReportData.TotalUsers = $AllUsers.Count
}

# Function to add risk account
function Add-RiskAccount {
    param(
        [string]$RiskLevel,
        [string]$Reason,
        [object]$User,
        [string]$Details,
        [hashtable]$AdditionalData = @{}
    )
    
    $RiskAccount = [PSCustomObject]@{
        SamAccountName = $User.SamAccountName
        DisplayName = $User.DisplayName
        Department = $User.Department
        Title = $User.Title
        Enabled = $User.Enabled
        LastLogon = $User.LastLogon
        PasswordLastSet = $User.PasswordLastSet
        LogonCount = $User.LogonCount
        BadPasswordCount = $User.BadPasswordCount
        LockoutTime = $User.LockoutTime
        RiskLevel = $RiskLevel
        Reason = $Reason
        Details = $Details
        Priority = switch ($RiskLevel) {
            "CRITICAL" { 1 }
            "HIGH" { 2 }
            "MEDIUM" { 3 }
            "LOW" { 4 }
        }
    }
    
    # Add additional data
    foreach ($Key in $AdditionalData.Keys) {
        $RiskAccount | Add-Member -MemberType NoteProperty -Name $Key -Value $AdditionalData[$Key] -Force
    }
    
    switch ($RiskLevel) {
        "CRITICAL" { $ReportData.CriticalRisks += $RiskAccount }
        "HIGH" { $ReportData.HighRisks += $RiskAccount }
        "MEDIUM" { $ReportData.MediumRisks += $RiskAccount }
        "LOW" { $ReportData.LowRisks += $RiskAccount }
    }
}

# Analyze each user for security risks
Write-Host "Analyzing user accounts..." -ForegroundColor Yellow
$ProgressCounter = 0

foreach ($User in $AllUsers) {
    $ProgressCounter++
    if ($ProgressCounter % 10 -eq 0) {
        Write-Progress -Activity "Analyzing Users" -Status "Processed $ProgressCounter of $($AllUsers.Count)" -PercentComplete (($ProgressCounter / $AllUsers.Count) * 100)
    }
    
    # CRITICAL RISKS - Enhanced IoC Detection
    
    # 1. Locked accounts that are still enabled
    if ($User.LockoutTime -ne "" -and $User.Enabled -eq "TRUE") {
        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Locked but Enabled Account" -User $User -Details "Account is locked due to failed password attempts but remains enabled"
    }
    
    # 2. Accounts with excessive failed password attempts but not locked
    if ($User.BadPasswordCount -ge 5 -and $User.LockoutTime -eq "") {
        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "High Failed Password Attempts" -User $User -Details "Account has $($User.BadPasswordCount) failed password attempts but is not locked"
    }
    
    # 3. Never logged on accounts that are enabled
    if ($User.LastLogon -eq "" -and $User.Enabled -eq "TRUE" -and $User.LogonCount -eq 0) {
        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Never Logged On but Enabled" -User $User -Details "Account has never been used but is enabled"
    }
    
    # 4. Service accounts with excessive privileges (simplified check)
    if ($User.SamAccountName -like "*svc*" -or $User.SamAccountName -like "*service*") {
        if ($User.Enabled -eq "TRUE" -and $User.LogonCount -eq 0) {
            Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Unused Service Account" -User $User -Details "Service account is enabled but has never been used"
        }
    }
    
    # 5. Enhanced IoC: Privilege Escalation Indicators
    if ($EnhancedIoCDetection) {
        # Domain admin accounts with recent password changes
        if ($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*") {
            if ($User.PasswordLastSet -ne "") {
                try {
                    $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                    $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                    if ($DaysSincePasswordSet.Days -le 7) {
                        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Privileged Account Password Change" -User $User -Details "Privileged account password changed $($DaysSincePasswordSet.Days) days ago" -AdditionalData @{DaysSincePasswordSet = $DaysSincePasswordSet.Days}
                        $ReportData.IoCDetections.PrivilegeEscalation++
                    }
                }
                catch { }
            }
        }
        
        # 6. Expired accounts that are still enabled (CRITICAL RISK)
        if ($User.AccountExpires -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ExpirationDate = [DateTime]::ParseExact($User.AccountExpires, "M/d/yyyy h:mm tt", $null)
                if ((Get-Date) -gt $ExpirationDate) {
                    $DaysExpired = ((Get-Date) - $ExpirationDate).Days
                    Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Expired but Enabled Account" -User $User -Details "Account expired $DaysExpired days ago but remains enabled" -AdditionalData @{DaysExpired = $DaysExpired; ExpirationDate = $User.AccountExpires}
                    $ReportData.IoCDetections.AccountManipulation++
                }
            }
            catch {
                # Skip if date parsing fails
            }
        }
        
        # Service accounts with domain admin privileges
        if ($User.SamAccountName -like "*svc*" -and $User.Title -like "*Admin*") {
            Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Service Account with Admin Privileges" -User $User -Details "Service account has administrative privileges"
            $ReportData.IoCDetections.PrivilegeEscalation++
        }
        
        # Accounts with suspicious naming patterns (potential reconnaissance)
        $SuspiciousNames = @("admin", "administrator", "test", "guest", "temp", "demo", "backup", "service")
        foreach ($Pattern in $SuspiciousNames) {
            if ($User.SamAccountName -like "*$Pattern*" -and $User.Enabled -eq "TRUE") {
                Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Suspicious Account Naming" -User $User -Details "Account with suspicious naming pattern: $Pattern" -AdditionalData @{SuspiciousPattern = $Pattern}
                $ReportData.IoCDetections.Reconnaissance++
                break
            }
        }
    }
    
    # HIGH RISKS - Enhanced IoC Detection
    
    # 6. Inactive accounts (configurable days) that are still enabled
    if ($User.LastLogon -ne "" -and $User.Enabled -eq "TRUE") {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            if ($DaysSinceLogon.Days -ge $InactiveDays) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Inactive but Enabled Account" -User $User -Details "Account hasn't logged on for $($DaysSinceLogon.Days) days but remains enabled" -AdditionalData @{DaysInactive = $DaysSinceLogon.Days}
            }
        }
        catch {
            # Skip if date parsing fails
        }
    }
    
    # 7. Old password (configurable days) but account is enabled
    if ($User.PasswordLastSet -ne "" -and $User.Enabled -eq "TRUE") {
        try {
            $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
            $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
            if ($DaysSincePasswordSet.Days -ge $PasswordAgeDays) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Old Password" -User $User -Details "Password hasn't been changed for $($DaysSincePasswordSet.Days) days" -AdditionalData @{DaysSincePasswordSet = $DaysSincePasswordSet.Days}
            }
        }
        catch {
            # Skip if date parsing fails
        }
    }
    
    # 8. High activity accounts with recent lockouts
    if ($User.LogonCount -ge 200 -and $User.LockoutTime -ne "") {
        Add-RiskAccount -RiskLevel "HIGH" -Reason "High Activity Account Locked" -User $User -Details "High-activity account ($($User.LogonCount) logons) is currently locked"
    }
    
    # 9. Enhanced IoC: Suspicious Authentication Patterns
    if ($EnhancedIoCDetection) {
        # Failed logon attempts followed by successful logon pattern
        if ($User.BadPasswordCount -ge 3 -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 1) {
                    Add-RiskAccount -RiskLevel "HIGH" -Reason "Suspicious Auth Pattern" -User $User -Details "Account has $($User.BadPasswordCount) failed attempts but recent successful logon" -AdditionalData @{DaysSinceLogon = $DaysSinceLogon.Days}
                    $ReportData.IoCDetections.SuspiciousAuth++
                }
            }
            catch { }
        }
        
        # Service account abuse indicators
        if ($User.SamAccountName -like "*svc*" -and $User.Enabled -eq "TRUE") {
            if ($User.LastLogon -ne "") {
                try {
                    $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                    $LogonHour = $LastLogonDate.Hour
                    # Service accounts logging in during off-hours (6 PM - 6 AM)
                    if ($LogonHour -ge 18 -or $LogonHour -le 6) {
                        Add-RiskAccount -RiskLevel "HIGH" -Reason "Service Account Off-Hours Activity" -User $User -Details "Service account logged in during off-hours ($LogonHour:00)" -AdditionalData @{LogonHour = $LogonHour}
                        $ReportData.IoCDetections.ServiceAccountAbuse++
                    }
                }
                catch { }
            }
        }
        
        # High activity accounts with suspicious patterns (potential lateral movement)
        if ($User.LogonCount -ge 500 -and $User.Enabled -eq "TRUE" -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 7) {
                    Add-RiskAccount -RiskLevel "HIGH" -Reason "High Activity Recent Logon" -User $User -Details "High-activity account ($($User.LogonCount) logons) with recent activity" -AdditionalData @{LogonCount = $User.LogonCount; DaysSinceLogon = $DaysSinceLogon.Days}
                    $ReportData.IoCDetections.LateralMovement++
                }
            }
            catch { }
        }
        
        # 7. Accounts expiring soon (within 30 days) - HIGH RISK
        if ($User.AccountExpires -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ExpirationDate = [DateTime]::ParseExact($User.AccountExpires, "M/d/yyyy h:mm tt", $null)
                $DaysUntilExpiration = ($ExpirationDate - (Get-Date)).Days
                if ($DaysUntilExpiration -ge 0 -and $DaysUntilExpiration -le 30) {
                    Add-RiskAccount -RiskLevel "HIGH" -Reason "Account Expiring Soon" -User $User -Details "Account expires in $DaysUntilExpiration days" -AdditionalData @{DaysUntilExpiration = $DaysUntilExpiration; ExpirationDate = $User.AccountExpires}
                }
            }
            catch {
                # Skip if date parsing fails
            }
        }
    }
    
    # MEDIUM RISKS - Enhanced IoC Detection
    
    # 10. Disabled accounts with recent activity
    if ($User.Enabled -eq "FALSE" -and $User.LastLogon -ne "") {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            if ($DaysSinceLogon.Days -le 30) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Recently Active Disabled Account" -User $User -Details "Account was disabled but had recent activity ($($DaysSinceLogon.Days) days ago)" -AdditionalData @{DaysSinceLogon = $DaysSinceLogon.Days}
            }
        }
        catch {
            # Skip if date parsing fails
        }
    }
    
    # 11. Accounts with moderate failed password attempts
    if ($User.BadPasswordCount -ge 3 -and $User.BadPasswordCount -lt 5) {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Moderate Failed Password Attempts" -User $User -Details "Account has $($User.BadPasswordCount) failed password attempts"
    }
    
    # 12. New accounts with no activity
    if ($User.Created -ne "" -and $User.LastLogon -eq "") {
        try {
            $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
            $DaysSinceCreated = (Get-Date) - $CreatedDate
            if ($DaysSinceCreated.Days -ge 30) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "New Account No Activity" -User $User -Details "Account created $($DaysSinceCreated.Days) days ago but never used" -AdditionalData @{DaysSinceCreated = $DaysSinceCreated.Days}
            }
        }
        catch {
            # Skip if date parsing fails
        }
    }
    
    # 13. Enhanced IoC: Reconnaissance and Insider Threat Indicators
    if ($EnhancedIoCDetection) {
        # New accounts with specific naming patterns (potential reconnaissance)
        if ($User.Created -ne "") {
        try {
            $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
            $DaysSinceCreated = (Get-Date) - $CreatedDate
                if ($DaysSinceCreated.Days -le 7) {
                    # Check for suspicious naming patterns
                    $SuspiciousPatterns = @("test", "admin", "user", "guest", "temp", "demo")
                    foreach ($Pattern in $SuspiciousPatterns) {
                        if ($User.SamAccountName -like "*$Pattern*") {
                            Add-RiskAccount -RiskLevel "MEDIUM" -Reason "New Suspicious Account" -User $User -Details "New account with suspicious naming pattern: $Pattern" -AdditionalData @{SuspiciousPattern = $Pattern; DaysSinceCreated = $DaysSinceCreated.Days}
                            $ReportData.IoCDetections.Reconnaissance++
                            break
                        }
                    }
                }
            }
            catch { }
        }
        
        # Insider threat indicators - role/department mismatches
        if ($User.Title -like "*Admin*" -and $User.Department -notlike "*IT*" -and $User.Department -notlike "*Engineering*") {
            Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Role-Department Mismatch" -User $User -Details "Administrative role in non-IT department" -AdditionalData @{Department = $User.Department; Title = $User.Title}
            $ReportData.IoCDetections.InsiderThreat++
        }
        
        # Accounts with unusual activity patterns (potential credential dumping)
        if ($User.LogonCount -ge 200 -and $User.BadPasswordCount -ge 2 -and $User.Enabled -eq "TRUE") {
            Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Unusual Activity Pattern" -User $User -Details "High-activity account with failed password attempts" -AdditionalData @{LogonCount = $User.LogonCount; BadPasswordCount = $User.BadPasswordCount}
            $ReportData.IoCDetections.CredentialDumping++
        }
        
        # Recently modified accounts (potential account manipulation)
        if ($User.Modified -ne "") {
            try {
                $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
                $DaysSinceModified = (Get-Date) - $ModifiedDate
                if ($DaysSinceModified.Days -le 3 -and $User.Enabled -eq "TRUE") {
                    Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Recently Modified Account" -User $User -Details "Account modified $($DaysSinceModified.Days) days ago" -AdditionalData @{DaysSinceModified = $DaysSinceModified.Days}
                    $ReportData.IoCDetections.AccountManipulation++
            }
        }
            catch { }
        }
    }
    
    # LOW RISKS - Removed low activity detections as requested
}

Write-Progress -Activity "Analyzing Users" -Completed

# Sort accounts by priority within each risk level
$ReportData.CriticalRisks = $ReportData.CriticalRisks | Sort-Object Priority, BadPasswordCount -Descending
$ReportData.HighRisks = $ReportData.HighRisks | Sort-Object Priority, BadPasswordCount -Descending
$ReportData.MediumRisks = $ReportData.MediumRisks | Sort-Object Priority, BadPasswordCount -Descending
$ReportData.LowRisks = $ReportData.LowRisks | Sort-Object Priority, BadPasswordCount -Descending

# Calculate summary statistics
$AllRiskyAccounts = $ReportData.CriticalRisks + $ReportData.HighRisks + $ReportData.MediumRisks + $ReportData.LowRisks
$ReportData.Summary = @{
    TotalUsers = $ReportData.TotalUsers
    CriticalRisks = $ReportData.CriticalRisks.Count
    HighRisks = $ReportData.HighRisks.Count
    MediumRisks = $ReportData.MediumRisks.Count
    LowRisks = $ReportData.LowRisks.Count
    TotalRiskyAccounts = $AllRiskyAccounts.Count
    RiskPercentage = if ($ReportData.TotalUsers -gt 0) { [math]::Round(($AllRiskyAccounts.Count / $ReportData.TotalUsers) * 100, 2) } else { 0 }
    IoCDetections = $ReportData.IoCDetections
}

# Display report
Write-Host "=== ENTERPRISE SECURITY RISK REPORT ===" -ForegroundColor Red
Write-Host ""

# CRITICAL RISKS
if ($ReportData.CriticalRisks.Count -gt 0) {
    Write-Host "[CRITICAL] CRITICAL RISKS ($($ReportData.CriticalRisks.Count) accounts)" -ForegroundColor Red
    Write-Host "Immediate action required - High security risk" -ForegroundColor Red
    Write-Host ""
    $ReportData.CriticalRisks | Format-Table SamAccountName, DisplayName, Department, Reason, Details -AutoSize -Wrap
    Write-Host ""
}

# HIGH RISKS
if ($ReportData.HighRisks.Count -gt 0) {
    Write-Host "[HIGH] HIGH RISKS ($($ReportData.HighRisks.Count) accounts)" -ForegroundColor Yellow
    Write-Host "Investigate within 24 hours" -ForegroundColor Yellow
    Write-Host ""
    $ReportData.HighRisks | Format-Table SamAccountName, DisplayName, Department, Reason, Details -AutoSize -Wrap
    Write-Host ""
}

# MEDIUM RISKS
if ($ReportData.MediumRisks.Count -gt 0) {
    Write-Host "[MEDIUM] MEDIUM RISKS ($($ReportData.MediumRisks.Count) accounts)" -ForegroundColor Magenta
    Write-Host "Investigate within 1 week" -ForegroundColor Magenta
    Write-Host ""
    $ReportData.MediumRisks | Format-Table SamAccountName, DisplayName, Department, Reason, Details -AutoSize -Wrap
    Write-Host ""
}

# LOW RISKS
if ($ReportData.LowRisks.Count -gt 0) {
    Write-Host "[LOW] LOW RISKS ($($ReportData.LowRisks.Count) accounts)" -ForegroundColor Blue
    Write-Host "Monitor and investigate as time permits" -ForegroundColor Blue
    Write-Host ""
    $ReportData.LowRisks | Format-Table SamAccountName, DisplayName, Department, Reason, Details -AutoSize -Wrap
    Write-Host ""
}

# Summary statistics
Write-Host "=== SUMMARY STATISTICS ===" -ForegroundColor Cyan
Write-Host "Total Users Scanned: $($ReportData.Summary.TotalUsers)" -ForegroundColor White
Write-Host "Critical Risks: $($ReportData.Summary.CriticalRisks)" -ForegroundColor Red
Write-Host "High Risks: $($ReportData.Summary.HighRisks)" -ForegroundColor Yellow
Write-Host "Medium Risks: $($ReportData.Summary.MediumRisks)" -ForegroundColor Magenta
Write-Host "Low Risks: $($ReportData.Summary.LowRisks)" -ForegroundColor Blue
Write-Host "Total Risky Accounts: $($ReportData.Summary.TotalRiskyAccounts)" -ForegroundColor White
Write-Host "Risk Percentage: $($ReportData.Summary.RiskPercentage)%" -ForegroundColor White
Write-Host ""

# Enhanced IoC Detection Summary
if ($EnhancedIoCDetection) {
    Write-Host "=== ENHANCED IoC DETECTION SUMMARY ===" -ForegroundColor Green
    Write-Host "Privilege Escalation Indicators: $($ReportData.Summary.IoCDetections.PrivilegeEscalation)" -ForegroundColor Yellow
    Write-Host "Suspicious Authentication Patterns: $($ReportData.Summary.IoCDetections.SuspiciousAuth)" -ForegroundColor Yellow
    Write-Host "Service Account Abuse: $($ReportData.Summary.IoCDetections.ServiceAccountAbuse)" -ForegroundColor Yellow
    Write-Host "Lateral Movement Indicators: $($ReportData.Summary.IoCDetections.LateralMovement)" -ForegroundColor Yellow
    Write-Host "Reconnaissance Indicators: $($ReportData.Summary.IoCDetections.Reconnaissance)" -ForegroundColor Yellow
    Write-Host "Credential Dumping Indicators: $($ReportData.Summary.IoCDetections.CredentialDumping)" -ForegroundColor Yellow
    Write-Host "Account Manipulation Indicators: $($ReportData.Summary.IoCDetections.AccountManipulation)" -ForegroundColor Yellow
    Write-Host "Insider Threat Indicators: $($ReportData.Summary.IoCDetections.InsiderThreat)" -ForegroundColor Yellow
    Write-Host ""
}

# Risk breakdown by type
$RiskBreakdown = $AllRiskyAccounts | Group-Object Reason | Sort-Object Count -Descending
Write-Host "=== RISK BREAKDOWN ===" -ForegroundColor Cyan
$RiskBreakdown | Format-Table Name, Count -AutoSize
Write-Host ""

# Risk by department
$DepartmentRisks = $AllRiskyAccounts | Group-Object Department | Sort-Object Count -Descending
Write-Host "=== RISK BY DEPARTMENT ===" -ForegroundColor Cyan
$DepartmentRisks | Format-Table Name, Count -AutoSize
Write-Host ""

# Generate recommendations
$Recommendations = @()

if ($ReportData.CriticalRisks.Count -gt 0) {
    $Recommendations += "• IMMEDIATE: Address $($ReportData.CriticalRisks.Count) critical security risks"
}

if ($ReportData.HighRisks.Count -gt 0) {
    $Recommendations += "• URGENT: Investigate $($ReportData.HighRisks.Count) high-risk accounts within 24 hours"
}

if ($ReportData.MediumRisks.Count -gt 0) {
    $Recommendations += "• PLANNED: Investigate $($ReportData.MediumRisks.Count) medium-risk accounts within 1 week"
}

if ($ReportData.Summary.IoCDetections.PrivilegeEscalation -gt 0) {
    $Recommendations += "• SECURITY: Review privilege escalation indicators for potential compromise"
}

if ($ReportData.Summary.IoCDetections.ServiceAccountAbuse -gt 0) {
    $Recommendations += "• MONITOR: Investigate service account abuse patterns"
}

Write-Host "=== RECOMMENDATIONS ===" -ForegroundColor Cyan
foreach ($Recommendation in $Recommendations) {
    Write-Host $Recommendation -ForegroundColor White
}
Write-Host ""

Write-Host "=== ENTERPRISE REPORT COMPLETE ===" -ForegroundColor Green
Write-Host "Generated: $(Get-Date)" -ForegroundColor Gray
Write-Host "Scan Duration: $((Get-Date) - $ReportData.ScanTime)" -ForegroundColor Gray

# Export to CSV if requested
if ($ExportCSV -ne "") {
    try {
        Write-Host ""
        Write-Host "=== EXPORTING SECURITY REPORT ===" -ForegroundColor Cyan
        
        # Ensure directory exists
        $Directory = Split-Path $ExportCSV -Parent
        if (!(Test-Path $Directory)) {
            Write-Host "Creating directory: $Directory" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        }
        
        Write-Host "Exporting report to CSV..." -ForegroundColor Cyan
        
        # Create export data with all risky accounts
        $ExportData = @()
        
        # Add critical risks
        foreach ($Risk in $ReportData.CriticalRisks) {
            $IoCCategory = ""
            if ($EnhancedIoCDetection) {
                # Determine IoC category based on reason
                switch -Wildcard ($Risk.Reason) {
                    "*Privileged Account Password Change*" { $IoCCategory = "PrivilegeEscalation" }
                    "*Service Account with Admin Privileges*" { $IoCCategory = "PrivilegeEscalation" }
                    "*Suspicious Account Naming*" { $IoCCategory = "Reconnaissance" }
                    default { $IoCCategory = "Other" }
                }
            }
            
            $ExportData += [PSCustomObject]@{
                RiskLevel = "CRITICAL"
                SamAccountName = $Risk.SamAccountName
                DisplayName = $Risk.DisplayName
                Department = $Risk.Department
                Title = $Risk.Title
                Reason = $Risk.Reason
                Details = $Risk.Details
                Enabled = $Risk.Enabled
                LastLogon = $Risk.LastLogon
                PasswordLastSet = $Risk.PasswordLastSet
                LogonCount = $Risk.LogonCount
                BadPasswordCount = $Risk.BadPasswordCount
                LockoutTime = $Risk.LockoutTime
                Created = $Risk.Created
                Modified = $Risk.Modified
                ScanTime = $ReportData.ScanTime
                IoCDetection = if ($EnhancedIoCDetection) { "Enhanced" } else { "Standard" }
                IoCCategory = $IoCCategory
            }
        }
        
        # Add high risks
        foreach ($Risk in $ReportData.HighRisks) {
            $IoCCategory = ""
            if ($EnhancedIoCDetection) {
                # Determine IoC category based on reason
                switch -Wildcard ($Risk.Reason) {
                    "*Suspicious Auth Pattern*" { $IoCCategory = "SuspiciousAuth" }
                    "*Service Account Off-Hours Activity*" { $IoCCategory = "ServiceAccountAbuse" }
                    "*High Activity Recent Logon*" { $IoCCategory = "LateralMovement" }
                    default { $IoCCategory = "Other" }
                }
            }
            
            $ExportData += [PSCustomObject]@{
                RiskLevel = "HIGH"
                SamAccountName = $Risk.SamAccountName
                DisplayName = $Risk.DisplayName
                Department = $Risk.Department
                Title = $Risk.Title
                Reason = $Risk.Reason
                Details = $Risk.Details
                Enabled = $Risk.Enabled
                LastLogon = $Risk.LastLogon
                PasswordLastSet = $Risk.PasswordLastSet
                LogonCount = $Risk.LogonCount
                BadPasswordCount = $Risk.BadPasswordCount
                LockoutTime = $Risk.LockoutTime
                Created = $Risk.Created
                Modified = $Risk.Modified
                ScanTime = $ReportData.ScanTime
                IoCDetection = if ($EnhancedIoCDetection) { "Enhanced" } else { "Standard" }
                IoCCategory = $IoCCategory
            }
        }
        
        # Add medium risks
        foreach ($Risk in $ReportData.MediumRisks) {
            $IoCCategory = ""
            if ($EnhancedIoCDetection) {
                # Determine IoC category based on reason
                switch -Wildcard ($Risk.Reason) {
                    "*New Suspicious Account*" { $IoCCategory = "Reconnaissance" }
                    "*Role-Department Mismatch*" { $IoCCategory = "InsiderThreat" }
                    "*Unusual Activity Pattern*" { $IoCCategory = "CredentialDumping" }
                    "*Recently Modified Account*" { $IoCCategory = "AccountManipulation" }
                    default { $IoCCategory = "Other" }
                }
            }
            
            $ExportData += [PSCustomObject]@{
                RiskLevel = "MEDIUM"
                SamAccountName = $Risk.SamAccountName
                DisplayName = $Risk.DisplayName
                Department = $Risk.Department
                Title = $Risk.Title
                Reason = $Risk.Reason
                Details = $Risk.Details
                Enabled = $Risk.Enabled
                LastLogon = $Risk.LastLogon
                PasswordLastSet = $Risk.PasswordLastSet
                LogonCount = $Risk.LogonCount
                BadPasswordCount = $Risk.BadPasswordCount
                LockoutTime = $Risk.LockoutTime
                Created = $Risk.Created
                Modified = $Risk.Modified
                ScanTime = $ReportData.ScanTime
                IoCDetection = if ($EnhancedIoCDetection) { "Enhanced" } else { "Standard" }
                IoCCategory = $IoCCategory
            }
        }
        
        # Add low risks
        foreach ($Risk in $ReportData.LowRisks) {
            $IoCCategory = ""
            if ($EnhancedIoCDetection) {
                # Determine IoC category based on reason
                switch -Wildcard ($Risk.Reason) {
                    default { $IoCCategory = "Other" }
                }
            }
            
            $ExportData += [PSCustomObject]@{
                RiskLevel = "LOW"
                SamAccountName = $Risk.SamAccountName
                DisplayName = $Risk.DisplayName
                Department = $Risk.Department
                Title = $Risk.Title
                Reason = $Risk.Reason
                Details = $Risk.Details
                Enabled = $Risk.Enabled
                LastLogon = $Risk.LastLogon
                PasswordLastSet = $Risk.PasswordLastSet
                LogonCount = $Risk.LogonCount
                BadPasswordCount = $Risk.BadPasswordCount
                LockoutTime = $Risk.LockoutTime
                Created = $Risk.Created
                Modified = $Risk.Modified
                ScanTime = $ReportData.ScanTime
                IoCDetection = if ($EnhancedIoCDetection) { "Enhanced" } else { "Standard" }
                IoCCategory = $IoCCategory
            }
        }
        
        # Ensure directory exists
        $Directory = Split-Path $ExportCSV -Parent
        if (!(Test-Path $Directory)) {
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        }
        
        # Export to CSV
        $ExportData | Export-Csv -Path $ExportCSV -NoTypeInformation -Encoding UTF8
        
        Write-Host ""
        Write-Host "✅ SECURITY REPORT EXPORTED SUCCESSFULLY" -ForegroundColor Green
        Write-Host "📁 Location: $ExportCSV" -ForegroundColor Cyan
        Write-Host "📊 Total Records: $($ExportData.Count)" -ForegroundColor Green
        Write-Host "📈 Risk Breakdown:" -ForegroundColor Yellow
        Write-Host "   • Critical Risks: $($ReportData.CriticalRisks.Count)" -ForegroundColor Red
        Write-Host "   • High Risks: $($ReportData.HighRisks.Count)" -ForegroundColor Yellow
        Write-Host "   • Medium Risks: $($ReportData.MediumRisks.Count)" -ForegroundColor Blue
        Write-Host "   • Low Risks: $($ReportData.LowRisks.Count)" -ForegroundColor Gray
        
        # Create summary CSV if enhanced IoC detection is enabled
        if ($EnhancedIoCDetection) {
            $SummaryCSV = $ExportCSV -replace "\.csv$", "_Summary.csv"
            $SummaryData = @()
            
            # Add IoC summary
            foreach ($IoCType in $ReportData.Summary.IoCDetections.Keys) {
                $SummaryData += [PSCustomObject]@{
                    Category = "IoC Detection"
                    Type = $IoCType
                    Count = $ReportData.Summary.IoCDetections[$IoCType]
                    RiskLevel = "N/A"
                    Description = "Enhanced IoC detection pattern"
                }
            }
            
            # Add risk summary
            $SummaryData += [PSCustomObject]@{
                Category = "Risk Summary"
                Type = "Critical Risks"
                Count = $ReportData.Summary.CriticalRisks
                RiskLevel = "CRITICAL"
                Description = "Immediate action required"
            }
            
            $SummaryData += [PSCustomObject]@{
                Category = "Risk Summary"
                Type = "High Risks"
                Count = $ReportData.Summary.HighRisks
                RiskLevel = "HIGH"
                Description = "Investigate within 24 hours"
            }
            
            $SummaryData += [PSCustomObject]@{
                Category = "Risk Summary"
                Type = "Medium Risks"
                Count = $ReportData.Summary.MediumRisks
                RiskLevel = "MEDIUM"
                Description = "Investigate within 1 week"
            }
            
            $SummaryData += [PSCustomObject]@{
                Category = "Risk Summary"
                Type = "Low Risks"
                Count = $ReportData.Summary.LowRisks
                RiskLevel = "LOW"
                Description = "Monitor and investigate as time permits"
            }
            
            $SummaryData += [PSCustomObject]@{
                Category = "Statistics"
                Type = "Total Users"
                Count = $ReportData.Summary.TotalUsers
                RiskLevel = "N/A"
                Description = "Total users scanned"
            }
            
            $SummaryData += [PSCustomObject]@{
                Category = "Statistics"
                Type = "Risk Percentage"
                Count = $ReportData.Summary.RiskPercentage
                RiskLevel = "N/A"
                Description = "Percentage of risky accounts"
            }
            
            $SummaryData | Export-Csv -Path $SummaryCSV -NoTypeInformation -Encoding UTF8
            Write-Host "📋 Summary Report: $SummaryCSV" -ForegroundColor Green
        }
        
    }
    catch {
        Write-Error "Failed to export report: $($_.Exception.Message)"
    }
}