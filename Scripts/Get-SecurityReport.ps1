# Get-SecurityReport.ps1
# Enterprise-grade security report for Active Directory user accounts
# Enhanced with additional IoC detection patterns
# Designed for real AD environments with export capabilities

[CmdletBinding()]
param(
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
    [switch]$ExportCSV = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "ADSecurityReport\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Warning "Active Directory module not available. Using CSV simulation module."
    Import-Module .\CSVActiveDirectory.psd1 -Force
}

# Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $FolderEmoji = Get-Emoji -Type "Search"
    $ChartEmoji = Get-Emoji -Type "Target"
    $TrendEmoji = Get-Emoji -Type "Lightning"
    $ClipboardEmoji = Get-Emoji -Type "Bulb"
}
catch {
    # Fallback to ASCII characters if emoji function is not available
    $SuccessEmoji = "[OK]"
    $FolderEmoji = "[FOLDER]"
    $ChartEmoji = "[CHART]"
    $TrendEmoji = "[TREND]"
    $ClipboardEmoji = "[CLIP]"
}

Write-Host "=== ENTERPRISE AD SECURITY REPORT ===" -ForegroundColor White
Write-Host "Enhanced with IoC detection patterns..." -ForegroundColor White
Write-Host "Scanning for dangerous user accounts..." -ForegroundColor White
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
        RiskLevel = $RiskLevel
        Reason = $Reason
        Details = $Details
        ScanTime = $ReportData.ScanTime
        IoCCategory = if ($AdditionalData.IoCCategory) { $AdditionalData.IoCCategory } else { "General" }
        Confidence = if ($AdditionalData.Confidence) { $AdditionalData.Confidence } else { 75 }
    }
    
    switch ($RiskLevel) {
        "CRITICAL" { $ReportData.CriticalRisks += $RiskAccount }
        "HIGH" { $ReportData.HighRisks += $RiskAccount }
        "MEDIUM" { $ReportData.MediumRisks += $RiskAccount }
        "LOW" { $ReportData.LowRisks += $RiskAccount }
    }
}

# Enhanced IoC Detection Patterns
function Test-GoldenTicket {
    param([object]$User)
    
    # Check for suspicious admin account activity
    if ($User.Title -like "*Admin*" -and $User.Enabled -eq $true) {
        try {
            $PasswordSetDate = [DateTime]::Parse($User.PasswordLastSet)
            $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
            
            # Recent password change for admin account
            if ($DaysSincePasswordSet.Days -le 7) {
                Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Golden Ticket Detection" -User $User -Details "Recent password change for admin account" -AdditionalData @{ IoCCategory = "GoldenTicket"; Confidence = 90 }
                $ReportData.IoCDetections.GoldenTicket++
            }
        }
        catch { }
    }
}

function Test-PrivilegeEscalation {
    param([object]$User)
    
    # Check for service accounts with admin rights
    if ($User.SamAccountName -like "svc_*" -and $User.Title -like "*Admin*") {
        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Privilege Escalation" -User $User -Details "Service account with admin privileges" -AdditionalData @{ IoCCategory = "PrivilegeEscalation"; Confidence = 95 }
        $ReportData.IoCDetections.PrivilegeEscalation++
    }
    
    # Check for role-department mismatches
    if ($User.Title -like "*Admin*" -and $User.Department -ne "IT" -and $User.Department -ne "Engineering") {
        Add-RiskAccount -RiskLevel "HIGH" -Reason "Privilege Escalation" -User $User -Details "Admin role in non-IT department" -AdditionalData @{ IoCCategory = "PrivilegeEscalation"; Confidence = 80 }
        $ReportData.IoCDetections.PrivilegeEscalation++
    }
}

function Test-CredentialDumping {
    param([object]$User)
    
    # Check for high failed password attempts
    if ($User.BadPasswordCount -ge 8) {
        Add-RiskAccount -RiskLevel "CRITICAL" -Reason "Credential Dumping" -User $User -Details "High failed password attempts: $($User.BadPasswordCount)" -AdditionalData @{ IoCCategory = "CredentialDumping"; Confidence = 85 }
        $ReportData.IoCDetections.CredentialDumping++
    }
    
    # Check for suspicious authentication patterns
    if ($User.LogonCount -ge 500 -and $User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            
            if ($DaysSinceLogon.Days -le 1) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Credential Dumping" -User $User -Details "Suspicious authentication pattern with high logon count" -AdditionalData @{ IoCCategory = "CredentialDumping"; Confidence = 75 }
                $ReportData.IoCDetections.CredentialDumping++
            }
        }
        catch { }
    }
}

function Test-LateralMovement {
    param([object]$User)
    
    # Check for excessive logon activity
    if ($User.LogonCount -ge 800) {
        Add-RiskAccount -RiskLevel "HIGH" -Reason "Lateral Movement" -User $User -Details "Excessive logon activity: $($User.LogonCount) logons" -AdditionalData @{ IoCCategory = "LateralMovement"; Confidence = 80 }
        $ReportData.IoCDetections.LateralMovement++
    }
    
    # Check for off-hours activity for service accounts
    if ($User.SamAccountName -like "svc_*" -and $User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $LogonHour = $LastLogonDate.Hour
            
            if ($LogonHour -ge 18 -or $LogonHour -le 6) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Lateral Movement" -User $User -Details "Service account activity during off-hours" -AdditionalData @{ IoCCategory = "LateralMovement"; Confidence = 85 }
                $ReportData.IoCDetections.LateralMovement++
            }
        }
        catch { }
    }
}

function Test-AccountManipulation {
    param([object]$User)
    
    # Check for recently modified accounts
    if ($User.Modified -ne "" -and $User.Enabled -eq $true) {
        try {
            $ModifiedDate = [DateTime]::Parse($User.Modified)
            $DaysSinceModified = (Get-Date) - $ModifiedDate
            
            if ($DaysSinceModified.Days -le 3) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Account Manipulation" -User $User -Details "Recently modified account" -AdditionalData @{ IoCCategory = "AccountManipulation"; Confidence = 70 }
                $ReportData.IoCDetections.AccountManipulation++
            }
        }
        catch { }
    }
    
    # Check for new suspicious accounts
    if ($User.Created -ne "") {
        try {
            $CreatedDate = [DateTime]::Parse($User.Created)
            $DaysSinceCreated = (Get-Date) - $CreatedDate
            
            if ($DaysSinceCreated.Days -le 7 -and $User.LogonCount -le 20) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Account Manipulation" -User $User -Details "New account with low activity" -AdditionalData @{ IoCCategory = "AccountManipulation"; Confidence = 65 }
                $ReportData.IoCDetections.AccountManipulation++
            }
        }
        catch { }
    }
}

function Test-SuspiciousAuth {
    param([object]$User)
    
    # Check for unusual login times
    if ($User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $LogonHour = $LastLogonDate.Hour
            $LogonDayOfWeek = $LastLogonDate.DayOfWeek
            
            # Weekend or late night activity
            if ($LogonDayOfWeek -eq "Saturday" -or $LogonDayOfWeek -eq "Sunday" -or $LogonHour -ge 22 -or $LogonHour -le 6) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Suspicious Authentication" -User $User -Details "Unusual login time: $LogonDayOfWeek at $LogonHour`:00" -AdditionalData @{ IoCCategory = "SuspiciousAuth"; Confidence = 70 }
                $ReportData.IoCDetections.SuspiciousAuth++
            }
        }
        catch { }
    }
}

function Test-ServiceAccountAbuse {
    param([object]$User)
    
    # Check for service accounts with recent activity
    if ($User.SamAccountName -like "svc_*" -and $User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            
            if ($DaysSinceLogon.Days -le 1) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Service Account Abuse" -User $User -Details "Service account with recent interactive logon" -AdditionalData @{ IoCCategory = "ServiceAccountAbuse"; Confidence = 85 }
                $ReportData.IoCDetections.ServiceAccountAbuse++
            }
        }
        catch { }
    }
}

function Test-Reconnaissance {
    param([object]$User)
    
    # Check for accounts with unusual naming patterns
    if ($User.SamAccountName -match "admin|test|temp|guest|demo" -and $User.Enabled -eq $true) {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Reconnaissance" -User $User -Details "Suspicious account naming pattern" -AdditionalData @{ IoCCategory = "Reconnaissance"; Confidence = 60 }
        $ReportData.IoCDetections.Reconnaissance++
    }
    
    # Check for accounts with high activity but low profile
    if ($User.LogonCount -ge 300 -and $User.Title -notlike "*Admin*" -and $User.Title -notlike "*Manager*") {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Reconnaissance" -User $User -Details "High activity account with low privilege role" -AdditionalData @{ IoCCategory = "Reconnaissance"; Confidence = 65 }
        $ReportData.IoCDetections.Reconnaissance++
    }
}

function Test-DataExfiltration {
    param([object]$User)
    
    # Check for accounts with unusual activity patterns
    if ($User.LogonCount -ge 600 -and $User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            
            if ($DaysSinceLogon.Days -le 3) {
                Add-RiskAccount -RiskLevel "HIGH" -Reason "Data Exfiltration" -User $User -Details "High activity account with recent logon" -AdditionalData @{ IoCCategory = "DataExfiltration"; Confidence = 75 }
                $ReportData.IoCDetections.DataExfiltration++
            }
        }
        catch { }
    }
}

function Test-InsiderThreat {
    param([object]$User)
    
    # Check for department mismatches
    if ($User.Title -like "*Admin*" -and $User.Department -eq "Sales") {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Insider Threat" -User $User -Details "Admin role in sales department" -AdditionalData @{ IoCCategory = "InsiderThreat"; Confidence = 70 }
        $ReportData.IoCDetections.InsiderThreat++
    }
    
    # Check for accounts with unusual access patterns
    if ($User.BadPasswordCount -ge 3 -and $User.Enabled -eq $true) {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Insider Threat" -User $User -Details "Multiple failed login attempts" -AdditionalData @{ IoCCategory = "InsiderThreat"; Confidence = 65 }
        $ReportData.IoCDetections.InsiderThreat++
    }
}

# Standard security checks
function Test-StandardSecurity {
    param([object]$User)
    
    # Check for disabled accounts
    if ($User.Enabled -eq $false) {
        Add-RiskAccount -RiskLevel "LOW" -Reason "Disabled Account" -User $User -Details "Account is disabled"
    }
    
    # Check for locked accounts
    if ($User.LockedOut -eq $true) {
        Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Locked Account" -User $User -Details "Account is locked out"
    }
    
    # Check for expired passwords
    if ($User.PasswordLastSet -ne "") {
        try {
            $PasswordSetDate = [DateTime]::Parse($User.PasswordLastSet)
            $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
            
            if ($DaysSincePasswordSet.Days -gt $PasswordAgeDays) {
                Add-RiskAccount -RiskLevel "MEDIUM" -Reason "Expired Password" -User $User -Details "Password set $($DaysSincePasswordSet.Days) days ago"
            }
        }
        catch { }
    }
    
    # Check for inactive accounts
    if ($User.LastLogonDate -ne "") {
        try {
            $LastLogonDate = [DateTime]::Parse($User.LastLogonDate)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            
            if ($DaysSinceLogon.Days -gt $InactiveDays) {
                Add-RiskAccount -RiskLevel "LOW" -Reason "Inactive Account" -User $User -Details "No logon for $($DaysSinceLogon.Days) days"
            }
        }
        catch { }
    }
    
    # Check for passwords that never expire
    if ($User.PasswordNeverExpires -eq $true) {
        Add-RiskAccount -RiskLevel "HIGH" -Reason "Password Never Expires" -User $User -Details "Password set to never expire"
    }
}

# Main security analysis
Write-Host "$FolderEmoji Analyzing $($AllUsers.Count) user accounts..." -ForegroundColor Cyan

foreach ($User in $AllUsers) {
    # Skip disabled accounts if not included
    if (-not $IncludeDisabled -and $User.Enabled -eq $false) {
        continue
    }
    
    # Enhanced IoC Detection
    if ($EnhancedIoCDetection) {
        Test-GoldenTicket -User $User
        Test-PrivilegeEscalation -User $User
        Test-CredentialDumping -User $User
        Test-LateralMovement -User $User
        Test-AccountManipulation -User $User
        Test-SuspiciousAuth -User $User
        Test-ServiceAccountAbuse -User $User
        Test-Reconnaissance -User $User
        Test-DataExfiltration -User $User
        Test-InsiderThreat -User $User
    }
    
    # Standard security checks
    Test-StandardSecurity -User $User
}

# Generate summary statistics
# Get unique users across all risk categories to avoid double-counting
$AllRiskUsers = @()
$AllRiskUsers += $ReportData.CriticalRisks.SamAccountName
$AllRiskUsers += $ReportData.HighRisks.SamAccountName
$AllRiskUsers += $ReportData.MediumRisks.SamAccountName
$AllRiskUsers += $ReportData.LowRisks.SamAccountName
$UniqueRiskUsers = ($AllRiskUsers | Sort-Object -Unique).Count

$ReportData.Summary = @{
    TotalUsers = $AllUsers.Count
    CriticalRisks = $ReportData.CriticalRisks.Count
    HighRisks = $ReportData.HighRisks.Count
    MediumRisks = $ReportData.MediumRisks.Count
    LowRisks = $ReportData.LowRisks.Count
    TotalRisks = $ReportData.CriticalRisks.Count + $ReportData.HighRisks.Count + $ReportData.MediumRisks.Count + $ReportData.LowRisks.Count
    UniqueRiskUsers = $UniqueRiskUsers
    RiskPercentage = if ($AllUsers.Count -gt 0) { [math]::Round(($UniqueRiskUsers / $AllUsers.Count) * 100, 2) } else { 0 }
}

# Display results
Write-Host ""
Write-Host "=== SECURITY REPORT SUMMARY ===" -ForegroundColor Cyan
Write-Host "Scan Time: $($ReportData.ScanTime)" -ForegroundColor White
Write-Host "Total Users: $($ReportData.Summary.TotalUsers)" -ForegroundColor White
Write-Host "Total Risk Entries: $($ReportData.Summary.TotalRisks)" -ForegroundColor Yellow
Write-Host "Unique Users at Risk: $($ReportData.Summary.UniqueRiskUsers)" -ForegroundColor Yellow
Write-Host "Risk Percentage: $($ReportData.Summary.RiskPercentage)%" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== RISK BREAKDOWN ===" -ForegroundColor Cyan
Write-Host "$ChartEmoji Critical Risks: $($ReportData.Summary.CriticalRisks)" -ForegroundColor Red
Write-Host "$TrendEmoji High Risks: $($ReportData.Summary.HighRisks)" -ForegroundColor Yellow
Write-Host "$ClipboardEmoji Medium Risks: $($ReportData.Summary.MediumRisks)" -ForegroundColor Magenta
        Write-Host "$SuccessEmoji Low Risks: $($ReportData.Summary.LowRisks)" -ForegroundColor DarkCyan
Write-Host ""

if ($EnhancedIoCDetection) {
    Write-Host "=== IoC DETECTION SUMMARY ===" -ForegroundColor Cyan
    foreach ($IoC in $ReportData.IoCDetections.GetEnumerator()) {
        if ($IoC.Value -gt 0) {
            Write-Host "$($IoC.Key): $($IoC.Value) detection(s)" -ForegroundColor White
        }
    }
    Write-Host ""
}

# Display detailed results if requested
if ($DetailedReport) {
    Write-Host "=== DETAILED RISK ACCOUNTS ===" -ForegroundColor Cyan
    
    if ($ReportData.CriticalRisks.Count -gt 0) {
        Write-Host "CRITICAL RISKS:" -ForegroundColor Red
        $ReportData.CriticalRisks | Format-Table SamAccountName, DisplayName, Department, Reason, IoCCategory, Confidence -AutoSize
        Write-Host ""
    }
    
    if ($ReportData.HighRisks.Count -gt 0) {
        Write-Host "HIGH RISKS:" -ForegroundColor Yellow
        $ReportData.HighRisks | Format-Table SamAccountName, DisplayName, Department, Reason, IoCCategory, Confidence -AutoSize
        Write-Host ""
    }
    
    if ($ReportData.MediumRisks.Count -gt 0) {
        Write-Host "MEDIUM RISKS:" -ForegroundColor Magenta
        $ReportData.MediumRisks | Format-Table SamAccountName, DisplayName, Department, Reason, IoCCategory, Confidence -AutoSize
        Write-Host ""
    }
    
    if ($ReportData.LowRisks.Count -gt 0) {
        Write-Host "LOW RISKS:" -ForegroundColor DarkCyan
        $ReportData.LowRisks | Format-Table SamAccountName, DisplayName, Department, Reason, IoCCategory, Confidence -AutoSize
        Write-Host ""
    }
}

# Export to CSV if requested
if ($ExportCSV) {
    try {
        # Use the specified path or default path
        $ExportPath = if ($ExportPath) { $ExportPath } else { "ADSecurityReport\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" }
        
        # Ensure directory exists
        $ExportDir = Split-Path $ExportPath -Parent
        if ($ExportDir -and -not (Test-Path $ExportDir)) {
            New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
        }
        
        # Combine all risk accounts
        $AllRiskAccounts = @()
        $AllRiskAccounts += $ReportData.CriticalRisks
        $AllRiskAccounts += $ReportData.HighRisks
        $AllRiskAccounts += $ReportData.MediumRisks
        $AllRiskAccounts += $ReportData.LowRisks
        
        if ($AllRiskAccounts.Count -gt 0) {
            $AllRiskAccounts | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
            Write-Host "$SuccessEmoji Security report exported to: $ExportPath" -ForegroundColor Green
        } else {
            Write-Host "$SuccessEmoji No risks found - no CSV export needed" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to export security report: $($_.Exception.Message)"
    }
}

# Generate recommendations
Write-Host "=== RECOMMENDATIONS ===" -ForegroundColor Cyan
if ($ReportData.Summary.CriticalRisks -gt 0) {
    Write-Host "[CRITICAL] IMMEDIATE ACTION REQUIRED:" -ForegroundColor Red
    Write-Host "  - Investigate all critical risks immediately" -ForegroundColor White
    Write-Host "  - Review admin account permissions" -ForegroundColor White
    Write-Host "  - Check for compromised service accounts" -ForegroundColor White
    Write-Host ""
}

if ($ReportData.Summary.HighRisks -gt 0) {
    Write-Host "[HIGH] HIGH PRIORITY:" -ForegroundColor Yellow
    Write-Host "  - Review high-risk accounts within 24 hours" -ForegroundColor White
    Write-Host "  - Implement additional monitoring" -ForegroundColor White
    Write-Host "  - Consider account restrictions" -ForegroundColor White
    Write-Host ""
}

if ($ReportData.Summary.MediumRisks -gt 0) {
    Write-Host "[MEDIUM] MEDIUM PRIORITY:" -ForegroundColor Magenta
    Write-Host "  - Review medium-risk accounts within 1 week" -ForegroundColor White
    Write-Host "  - Update password policies if needed" -ForegroundColor White
    Write-Host "  - Consider additional training" -ForegroundColor White
    Write-Host ""
}

Write-Host "$SuccessEmoji Security report completed successfully!" -ForegroundColor Green 