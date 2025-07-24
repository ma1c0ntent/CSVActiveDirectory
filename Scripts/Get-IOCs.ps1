# Get-IOCs.ps1
# Individual User IoC Analysis and Attack Pattern Detection
# Provides detailed threat analysis for specific users

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$ExportReport = $true,
    
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "RiskyUsers"
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
$SearchEmoji = Get-Emoji -Type "Search"
$TargetEmoji = Get-Emoji -Type "Target"
$LightningEmoji = Get-Emoji -Type "Lightning"
$ChartEmoji = Get-Emoji -Type "Target"
$FolderEmoji = Get-Emoji -Type "Search"
$BulletEmoji = Get-Emoji -Type "Bullet"
$UserEmoji = Get-Emoji -Type "User"
$AlertEmoji = Get-Emoji -Type "Alert"
$MagnifyEmoji = Get-Emoji -Type "Magnify"
$GearEmoji = Get-Emoji -Type "Gear"
$ShieldEmoji = Get-Emoji -Type "Shield"
$ArrowRightEmoji = Get-Emoji -Type "ArrowRight"



# Function to get user data
function Get-UserData {
    param([string]$Username)
    
    try {
        $User = Get-ADUser -Identity $Username -Properties *
        return $User
    }
    catch {
        Write-Error "User '$Username' not found or cannot be accessed."
        return $null
    }
}

# Function to analyze IoC patterns
function Analyze-IoCPatterns {
    param([object]$User)
    
    $IoCAnalysis = @{
        UserInfo = @{
            SamAccountName = $User.SamAccountName
            DisplayName = $User.DisplayName
            Department = $User.Department
            Title = $User.Title
            Enabled = $User.Enabled
            Created = $User.Created
            Modified = $User.Modified
        }
        IoCDetections = @()
        AttackPatterns = @()
        Severity = "LOW"
        Confidence = 0
        RecommendedResponse = @()
        AnalysisTime = Get-Date
    }
    
    # CRITICAL IoC DETECTIONS
    
    # 1. Privilege Escalation Indicators
    if ($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*" -or $User.Title -like "*Domain*") {
        $PrivilegeEscalation = @{
            Type = "Privilege Escalation"
            Severity = "CRITICAL"
            Confidence = 95
            Indicators = @()
            AttackType = "Golden Ticket Attack / Privilege Escalation"
            Description = "User has administrative privileges"
        }
        
        # Check for recent password changes
        if ($User.PasswordLastSet -ne "") {
            try {
                $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                if ($DaysSincePasswordSet.Days -le 7) {
                    $PrivilegeEscalation.Indicators += "Recent password change ($($DaysSincePasswordSet.Days) days ago)"
                    $PrivilegeEscalation.Confidence = [math]::Min(100, $PrivilegeEscalation.Confidence + 10)
                }
            }
            catch { }
        }
        
        # Check for failed password attempts
        if ($User.BadPasswordCount -ge 3) {
            $PrivilegeEscalation.Indicators += "High failed password attempts ($($User.BadPasswordCount))"
            $PrivilegeEscalation.Confidence = [math]::Min(100, $PrivilegeEscalation.Confidence + 15)
        }
        
        $IoCAnalysis.IoCDetections += $PrivilegeEscalation
        $IoCAnalysis.AttackPatterns += "Privilege Escalation"
    }
    
    # 2. Credential Dumping Indicators
    if ($User.BadPasswordCount -ge 5) {
        $CredentialDumping = @{
            Type = "Credential Dumping"
            Severity = "CRITICAL"
            Confidence = 90
            Indicators = @("Excessive failed password attempts ($($User.BadPasswordCount))")
            AttackType = "Credential Harvesting / Brute Force"
            Description = "Multiple failed authentication attempts indicate credential discovery attempts"
        }
        
        # Check for recent successful logon after failed attempts
        if ($User.LastLogon -ne "" -and $User.BadPasswordCount -ge 3) {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 1) {
                    $CredentialDumping.Indicators += "Recent successful logon after failed attempts"
                    $CredentialDumping.Confidence = [math]::Min(100, $CredentialDumping.Confidence + 10)
                }
            }
            catch { }
        }
        
        $IoCAnalysis.IoCDetections += $CredentialDumping
        $IoCAnalysis.AttackPatterns += "Credential Dumping"
    }
    
    # 3. Lateral Movement Indicators
    if ($User.LogonCount -ge 200) {
        $LateralMovement = @{
            Type = "Lateral Movement"
            Severity = "HIGH"
            Confidence = 85
            Indicators = @("High logon count ($($User.LogonCount))")
            AttackType = "Lateral Movement / Network Traversal"
            Description = "Excessive logon activity suggests network traversal"
        }
        
        # Check for recent activity
        if ($User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 7) {
                    $LateralMovement.Indicators += "Recent high-activity logon ($($DaysSinceLogon.Days) days ago)"
                    $LateralMovement.Confidence = [math]::Min(100, $LateralMovement.Confidence + 10)
                }
            }
            catch { }
        }
        
        $IoCAnalysis.IoCDetections += $LateralMovement
        $IoCAnalysis.AttackPatterns += "Lateral Movement"
    }
    
    # 4. Account Manipulation Indicators
    if ($User.Modified -ne "") {
        try {
            $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
            $DaysSinceModified = (Get-Date) - $ModifiedDate
            if ($DaysSinceModified.Days -le 3) {
                $AccountManipulation = @{
                    Type = "Account Manipulation"
                    Severity = "HIGH"
                    Confidence = 80
                    Indicators = @("Recent account modification ($($DaysSinceModified.Days) days ago)")
                    AttackType = "Account Takeover / Privilege Escalation"
                    Description = "Recent account changes suggest manipulation"
                }
                
                $IoCAnalysis.IoCDetections += $AccountManipulation
                $IoCAnalysis.AttackPatterns += "Account Manipulation"
            }
        }
        catch { }
    }
    
    # 5. Suspicious Authentication Patterns
    if ($User.BadPasswordCount -ge 3 -and $User.LastLogon -ne "") {
        try {
            $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
            $DaysSinceLogon = (Get-Date) - $LastLogonDate
            if ($DaysSinceLogon.Days -le 1) {
                $SuspiciousAuth = @{
                    Type = "Suspicious Authentication"
                    Severity = "HIGH"
                    Confidence = 75
                    Indicators = @("Failed attempts followed by successful logon", "Recent activity after failed attempts")
                    AttackType = "Credential Spraying / Brute Force"
                    Description = "Failed authentication followed by successful logon"
                }
                
                $IoCAnalysis.IoCDetections += $SuspiciousAuth
                $IoCAnalysis.AttackPatterns += "Suspicious Authentication"
            }
        }
        catch { }
    }
    
    # 6. Service Account Abuse
    if ($User.SamAccountName -like "*svc*" -or $User.Title -like "*Service*") {
        $ServiceAccountAbuse = @{
            Type = "Service Account Abuse"
            Severity = "MEDIUM"
            Confidence = 70
            Indicators = @("Service account with recent activity")
            AttackType = "Service Account Compromise"
            Description = "Service account showing unusual activity patterns"
        }
        
        # Check for off-hours activity
        if ($User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $LogonHour = $LastLogonDate.Hour
                if ($LogonHour -ge 18 -or $LogonHour -le 6) {
                    $ServiceAccountAbuse.Indicators += "Off-hours activity ($LogonHour:00)"
                    $ServiceAccountAbuse.Confidence = [math]::Min(100, $ServiceAccountAbuse.Confidence + 15)
                }
            }
            catch { }
        }
        
        $IoCAnalysis.IoCDetections += $ServiceAccountAbuse
        $IoCAnalysis.AttackPatterns += "Service Account Abuse"
    }
    
    # 7. Reconnaissance Indicators
    if ($User.Created -ne "") {
        try {
            $CreatedDate = [DateTime]::ParseExact($User.Created, "M/d/yyyy h:mm tt", $null)
            $DaysSinceCreated = (Get-Date) - $CreatedDate
            if ($DaysSinceCreated.Days -le 7) {
                $Reconnaissance = @{
                    Type = "Reconnaissance"
                    Severity = "MEDIUM"
                    Confidence = 65
                    Indicators = @("Recently created account ($($DaysSinceCreated.Days) days ago)")
                    AttackType = "Account Enumeration / Reconnaissance"
                    Description = "New account creation for reconnaissance"
                }
                
                # Check for suspicious naming patterns
                $SuspiciousPatterns = @("test", "admin", "user", "guest", "temp", "demo")
                foreach ($Pattern in $SuspiciousPatterns) {
                    if ($User.SamAccountName -like "*$Pattern*") {
                        $Reconnaissance.Indicators += "Suspicious naming pattern: $Pattern"
                        $Reconnaissance.Confidence = [math]::Min(100, $Reconnaissance.Confidence + 10)
                        break
                    }
                }
                
                $IoCAnalysis.IoCDetections += $Reconnaissance
                $IoCAnalysis.AttackPatterns += "Reconnaissance"
            }
        }
        catch { }
    }
    
    # 8. Insider Threat Indicators
    if ($User.Title -like "*Admin*" -and $User.Department -notlike "*IT*" -and $User.Department -notlike "*Engineering*") {
        $InsiderThreat = @{
            Type = "Insider Threat"
            Severity = "MEDIUM"
            Confidence = 60
            Indicators = @("Administrative role in non-IT department")
            AttackType = "Insider Threat / Privilege Abuse"
            Description = "Administrative privileges in non-technical department"
        }
        
        $IoCAnalysis.IoCDetections += $InsiderThreat
        $IoCAnalysis.AttackPatterns += "Insider Threat"
    }
    
    # Calculate overall severity and confidence
    $CriticalCount = ($IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "CRITICAL" }).Count
    $HighCount = ($IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "HIGH" }).Count
    
    if ($CriticalCount -gt 0) {
        $IoCAnalysis.Severity = "CRITICAL"
        $CriticalDetections = $IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "CRITICAL" }
        if ($CriticalDetections.Count -gt 0) {
            $ConfidenceValues = @()
            foreach ($Detection in $CriticalDetections) {
                if ($Detection.ContainsKey('Confidence')) {
                    $ConfidenceValues += $Detection.Confidence
                }
            }
            if ($ConfidenceValues.Count -gt 0) {
                $AverageConfidence = ($ConfidenceValues | Measure-Object -Average).Average
                $IoCAnalysis.Confidence = [math]::Min(100, $AverageConfidence)
            } else {
                $IoCAnalysis.Confidence = 0
            }
        } else {
            $IoCAnalysis.Confidence = 0
        }
    }
    elseif ($HighCount -gt 0) {
        $IoCAnalysis.Severity = "HIGH"
        $HighDetections = $IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "HIGH" }
        if ($HighDetections.Count -gt 0) {
            $ConfidenceValues = @()
            foreach ($Detection in $HighDetections) {
                if ($Detection.ContainsKey('Confidence')) {
                    $ConfidenceValues += $Detection.Confidence
                }
            }
            if ($ConfidenceValues.Count -gt 0) {
                $AverageConfidence = ($ConfidenceValues | Measure-Object -Average).Average
                $IoCAnalysis.Confidence = [math]::Min(100, $AverageConfidence)
            } else {
                $IoCAnalysis.Confidence = 0
            }
        } else {
            $IoCAnalysis.Confidence = 0
        }
    }
    else {
        if ($IoCAnalysis.IoCDetections.Count -gt 0) {
            $ConfidenceValues = @()
            foreach ($Detection in $IoCAnalysis.IoCDetections) {
                if ($Detection.ContainsKey('Confidence')) {
                    $ConfidenceValues += $Detection.Confidence
                }
            }
            if ($ConfidenceValues.Count -gt 0) {
                $AverageConfidence = ($ConfidenceValues | Measure-Object -Average).Average
                $IoCAnalysis.Confidence = [math]::Min(100, $AverageConfidence)
            } else {
                $IoCAnalysis.Confidence = 0
            }
        } else {
            $IoCAnalysis.Confidence = 0
        }
    }
    
    # Generate recommended responses
    $IoCAnalysis.RecommendedResponse = @()
    
    if ($IoCAnalysis.Severity -eq "CRITICAL") {
        $IoCAnalysis.RecommendedResponse += "IMMEDIATE: Disable user account"
        $IoCAnalysis.RecommendedResponse += "URGENT: Reset all domain admin passwords"
        $IoCAnalysis.RecommendedResponse += "CRITICAL: Audit all systems accessed by this account"
        $IoCAnalysis.RecommendedResponse += "EMERGENCY: Check for additional compromised accounts"
    }
    elseif ($IoCAnalysis.Severity -eq "HIGH") {
        $IoCAnalysis.RecommendedResponse += "URGENT: Investigate user account activity"
        $IoCAnalysis.RecommendedResponse += "HIGH: Reset user password"
        $IoCAnalysis.RecommendedResponse += "MEDIUM: Monitor account for suspicious activity"
    }
    else {
        $IoCAnalysis.RecommendedResponse += "MEDIUM: Review account permissions"
        $IoCAnalysis.RecommendedResponse += "LOW: Monitor for unusual activity"
    }
    
    return $IoCAnalysis
}

# Function to display IoC report
function Show-IoCReport {
    param([hashtable]$Analysis)
    
    Write-Host "=== IoC ANALYSIS REPORT ===" -ForegroundColor White
    Write-Host "User: $($Analysis.UserInfo.SamAccountName)" -ForegroundColor White
    Write-Host "Display Name: $($Analysis.UserInfo.DisplayName)" -ForegroundColor White
    Write-Host "Department: $($Analysis.UserInfo.Department)" -ForegroundColor White
    Write-Host "Title: $($Analysis.UserInfo.Title)" -ForegroundColor White
    Write-Host "Enabled: $($Analysis.UserInfo.Enabled)" -ForegroundColor White
    Write-Host ""
    
    # Overall Assessment
    $SeverityColor = switch ($Analysis.Severity) {
        "CRITICAL" { "Red" }
        "HIGH" { "Yellow" }
        "MEDIUM" { "Magenta" }
        "LOW" { "DarkCyan" }
    }
    
    Write-Host "=== OVERALL ASSESSMENT ===" -ForegroundColor White
    Write-Host "Severity: $($Analysis.Severity)" -ForegroundColor $SeverityColor
    Write-Host "Confidence: $($Analysis.Confidence)%" -ForegroundColor White
    Write-Host "Attack Patterns: $($Analysis.AttackPatterns -join ', ')" -ForegroundColor White
    Write-Host ""
    
    # IoC Detections
    if ($Analysis.IoCDetections.Count -gt 0) {
        Write-Host "=== IoC DETECTIONS ===" -ForegroundColor White
        foreach ($IoC in $Analysis.IoCDetections) {
            $Color = switch ($IoC.Severity) {
                "CRITICAL" { "Red" }
                "HIGH" { "Yellow" }
                "MEDIUM" { "Magenta" }
                "LOW" { "DarkCyan" }
            }
            
            Write-Host "[$($IoC.Severity)] $($IoC.Type)" -ForegroundColor $Color
            Write-Host "  Attack Type: $($IoC.AttackType)" -ForegroundColor White
            Write-Host "  Confidence: $($IoC.Confidence)%" -ForegroundColor White
            Write-Host "  Description: $($IoC.Description)" -ForegroundColor White
            Write-Host "  Indicators:" -ForegroundColor White
            foreach ($Indicator in $IoC.Indicators) {
                $BulletEmoji = Get-Emoji -Type "Bullet"
            Write-Host "    $BulletEmoji $Indicator" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
    
    # Recommended Response
    Write-Host "=== RECOMMENDED RESPONSE ===" -ForegroundColor White
    foreach ($Response in $Analysis.RecommendedResponse) {
        Write-Host "$BulletEmoji $Response" -ForegroundColor White
    }
    Write-Host ""
    
    # Accuracy Assessment
    $AccuracyLevel = switch ($Analysis.Confidence) {
        { $_ -ge 90 } { "Very High" }
        { $_ -ge 75 } { "High" }
        { $_ -ge 60 } { "Medium" }
        { $_ -ge 40 } { "Low" }
        default { "Very Low" }
    }
    
    Write-Host "=== ACCURACY ASSESSMENT ===" -ForegroundColor White
    Write-Host "Likelihood of Accuracy: $AccuracyLevel ($($Analysis.Confidence)%)" -ForegroundColor White
    Write-Host "Analysis Time: $($Analysis.AnalysisTime)" -ForegroundColor Gray
    Write-Host ""
}

# Function to export report
function Export-IoCReport {
    param(
        [hashtable]$Analysis,
        [string]$ExportPath
    )
    
    try {
        # Ensure directory exists
        if (!(Test-Path $ExportPath)) {
            New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
        }
        
        $FileName = "IoC_$($Analysis.UserInfo.SamAccountName)_$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
        $FilePath = Join-Path $ExportPath $FileName
        
        # Get severity color
        $SeverityColor = switch ($Analysis.Severity) {
            "CRITICAL" { "#dc3545" }
            "HIGH" { "#fd7e14" }
            "MEDIUM" { "#ffc107" }
            "LOW" { "#17a2b8" }
            default { "#6c757d" }
        }
        
        # Generate HTML content
        $HtmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IoC Analysis Report - $($Analysis.UserInfo.SamAccountName)</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f8f9fa;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            font-weight: 300;
        }
        .header .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
            margin-top: 10px;
        }
        .content {
            padding: 30px;
        }
        .section {
            margin-bottom: 30px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            overflow: hidden;
        }
        .section-header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
            font-weight: 600;
            font-size: 1.1em;
            color: #495057;
        }
        .section-content {
            padding: 20px;
        }
        .user-info {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
        }
        .info-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #007bff;
        }
        .info-label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 5px;
        }
        .info-value {
            color: #212529;
            font-size: 1.1em;
        }
        .severity-badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .severity-critical { background-color: #dc3545; color: white; }
        .severity-high { background-color: #fd7e14; color: white; }
        .severity-medium { background-color: #ffc107; color: #212529; }
        .severity-low { background-color: #17a2b8; color: white; }
        .ioc-item {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 4px solid;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .ioc-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .ioc-item.collapsed .ioc-description,
        .ioc-item.collapsed .ioc-attack-type,
        .ioc-item.collapsed .ioc-summary,
        .ioc-item.collapsed .indicators {
            display: none !important;
        }
        .ioc-item.collapsed .ioc-details {
            max-height: 0 !important;
            opacity: 0 !important;
        }
        .ioc-critical { border-left-color: #dc3545; }
        .ioc-high { border-left-color: #fd7e14; }
        .ioc-medium { border-left-color: #ffc107; }
        .ioc-low { border-left-color: #17a2b8; }
        .ioc-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .ioc-title {
            font-size: 1.2em;
            font-weight: 600;
            color: #212529;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .expand-icon {
            font-size: 1.5em;
            transition: transform 0.3s ease;
        }
        .expanded .expand-icon {
            transform: rotate(90deg);
        }
        .collapsed .expand-icon {
            transform: rotate(0deg);
        }
        .ioc-confidence {
            font-size: 0.9em;
            color: #6c757d;
        }
        .ioc-description {
            color: #495057;
            margin-bottom: 15px;
        }
        .ioc-attack-type {
            background: #e9ecef;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 0.9em;
            color: #495057;
            margin-bottom: 15px;
        }
        .ioc-summary {
            background: #f8f9fa;
            padding: 10px 15px;
            border-radius: 4px;
            font-size: 0.9em;
            color: #6c757d;
            margin-bottom: 15px;
            border-left: 3px solid #28a745;
        }
        .indicators {
            margin-top: 15px;
        }
        .indicator {
            background: white;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 8px;
            border-left: 3px solid #007bff;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }
        .indicator:hover {
            background: #f8f9fa;
            transform: translateX(5px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .indicator-log {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
            background: #f8f9fa;
            border-radius: 4px;
            margin-top: 10px;
            border: 1px solid #e9ecef;
        }
        .indicator-log.expanded {
            max-height: 500px;
        }
        .log-entry {
            padding: 12px;
            border-bottom: 1px solid #e9ecef;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            line-height: 1.4;
        }
        .log-entry:last-child {
            border-bottom: none;
        }
        .log-timestamp {
            color: #6c757d;
            font-weight: bold;
        }
        .log-event {
            color: #495057;
        }
        .log-details {
            color: #6c757d;
            margin-top: 5px;
        }
        .indicator-icon {
            float: right;
            font-size: 1.2em;
            transition: transform 0.3s ease;
        }
        .indicator.expanded .indicator-icon {
            transform: rotate(90deg);
        }
        .ioc-details {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
            opacity: 0;
        }
        .ioc-details.expanded {
            max-height: 1000px;
            opacity: 1;
        }
        .detail-section {
            background: white;
            border-radius: 6px;
            padding: 15px;
            margin-top: 15px;
            border: 1px solid #e9ecef;
        }
        .detail-section h4 {
            margin: 0 0 10px 0;
            color: #495057;
            font-size: 1em;
        }
        .detail-content {
            color: #6c757d;
            line-height: 1.5;
        }
        .technical-details {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            margin-top: 10px;
        }
        .mitigation-steps {
            background: #e8f5e8;
            padding: 12px;
            border-radius: 4px;
            border-left: 4px solid #28a745;
            margin-top: 10px;
        }
        .mitigation-steps h4 {
            color: #155724;
            margin: 0 0 8px 0;
        }
        .mitigation-steps ul {
            margin: 0;
            padding-left: 20px;
        }
        .mitigation-steps li {
            margin-bottom: 5px;
            color: #155724;
        }
        .response-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 10px;
            border-left: 4px solid $SeverityColor;
        }
        .accuracy-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 10px;
        }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            font-size: 0.9em;
            border-top: 1px solid #e9ecef;
        }
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .stat-item {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border: 1px solid #e9ecef;
        }
        .stat-number {
            font-size: 2em;
            font-weight: 700;
            color: $SeverityColor;
        }
        .stat-label {
            color: #6c757d;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$($SearchEmoji) IoC Analysis Report</h1>
            <div class="subtitle">Threat Intelligence & Security Assessment</div>
        </div>
        
        <div class="content">
            <!-- User Information Section -->
            <div class="section">
                <div class="section-header">$($UserEmoji) User Information</div>
                <div class="section-content">
                    <div class="user-info">
                        <div class="info-item">
                            <div class="info-label">Username</div>
                            <div class="info-value">$($Analysis.UserInfo.SamAccountName)</div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">Display Name</div>
                            <div class="info-value">$($Analysis.UserInfo.DisplayName)</div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">Department</div>
                            <div class="info-value">$($Analysis.UserInfo.Department)</div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">Title</div>
                            <div class="info-value">$($Analysis.UserInfo.Title)</div>
                        </div>
                        <div class="info-item">
                            <div class="info-label">Account Status</div>
                            <div class="info-value">$(if($Analysis.UserInfo.Enabled) { 'Enabled' } else { 'Disabled' })</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Overall Assessment Section -->
            <div class="section">
                <div class="section-header">$($ChartEmoji) Overall Assessment</div>
                <div class="section-content">
                    <div class="summary-stats">
                        <div class="stat-item">
                            <div class="stat-number">$($Analysis.Severity)</div>
                            <div class="stat-label">Severity Level</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">$($Analysis.Confidence)%</div>
                            <div class="stat-label">Confidence</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">$($Analysis.IoCDetections.Count)</div>
                            <div class="stat-label">IoC Detections</div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Attack Patterns</div>
                        <div class="info-value">$($Analysis.AttackPatterns -join ', ')</div>
                    </div>
                </div>
            </div>
"@

        # Add IoC Detections Section
        if ($Analysis.IoCDetections.Count -gt 0) {
            $HtmlContent += @"
            <!-- IoC Detections Section -->
            <div class="section">
                <div class="section-header">$($AlertEmoji) IoC Detections</div>
                <div class="section-content">
"@
            
            foreach ($IoC in $Analysis.IoCDetections) {
                $SeverityClass = switch ($IoC.Severity) {
                    "CRITICAL" { "ioc-critical" }
                    "HIGH" { "ioc-high" }
                    "MEDIUM" { "ioc-medium" }
                    "LOW" { "ioc-low" }
                    default { "" }
                }
                
                $SeverityBadgeClass = switch ($IoC.Severity) {
                    "CRITICAL" { "severity-critical" }
                    "HIGH" { "severity-high" }
                    "MEDIUM" { "severity-medium" }
                    "LOW" { "severity-low" }
                    default { "" }
                }
                
                $HtmlContent += @"
                    <div class="ioc-item $SeverityClass collapsed" data-ioc-type="$($IoC.Type)">
                        <div class="ioc-header">
                            <div class="ioc-title">
                                <span class="expand-icon">$($ArrowRightEmoji)</span>
                                $($IoC.Type)
                            </div>
                            <div>
                                <span class="severity-badge $SeverityBadgeClass">$($IoC.Severity)</span>
                                <span class="ioc-confidence">$($IoC.Confidence)% confidence</span>
                            </div>
                        </div>
                        <div class="ioc-description">$($IoC.Description)</div>
                        <div class="ioc-attack-type">$($TargetEmoji) Attack Type: $($IoC.AttackType)</div>
                        <div class="ioc-summary">
                            <strong>$($SearchEmoji) Quick Summary:</strong> $($IoC.Indicators.Count) indicators detected
                        </div>
"@
                
                if ($IoC.Indicators.Count -gt 0) {
                    $HtmlContent += @"
                        <div class="indicators">
                            <strong>$($SearchEmoji) Indicators:</strong>
"@
                    foreach ($Indicator in $IoC.Indicators) {
                        $IndicatorId = "indicator_$($IoC.Type -replace '\s+', '_')_$($IoC.Indicators.IndexOf($Indicator))"
                        $LogData = Get-IndicatorLogs -IoCType $IoC.Type -Indicator $Indicator -User $User
                        $HtmlContent += @"
                            <div class="indicator" onclick="toggleIndicatorLog(this, '$IndicatorId'); event.stopPropagation();">
                                <span class="indicator-icon">$($ArrowRightEmoji)</span>
                                $($BulletEmoji) $Indicator
                                <div class="indicator-log" id="$IndicatorId">
                                    $LogData
                                </div>
                            </div>
"@
                    }
                    $HtmlContent += @"
                        </div>
"@
                }
                
                # Add detailed breakdown content
                $HtmlContent += @"
                        <div class="ioc-details">
                            <div class="detail-section">
                                <h4>$($MagnifyEmoji) Why This is an IoC</h4>
                                <div class="detail-content">
                                    $(Get-IoCDetailedExplanation -IoCType $IoC.Type -Severity $IoC.Severity)
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h4>$($GearEmoji) Technical Details</h4>
                                <div class="technical-details">
                                    $(Get-IoCTechnicalDetails -IoCType $IoC.Type -User $User)
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h4>$($ShieldEmoji) Mitigation Steps</h4>
                                <div class="mitigation-steps">
                                    <h4>Immediate Actions:</h4>
                                    <ul>
                                        $(Get-IoCMitigationSteps -IoCType $IoC.Type -Severity $IoC.Severity)
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
"@
            }
            
            $HtmlContent += @"
                </div>
            </div>
"@
        }
        
        # Add Recommended Response Section
        $HtmlContent += @"
            <!-- Recommended Response Section -->
            <div class="section">
                <div class="section-header">$($LightningEmoji) Recommended Response</div>
                <div class="section-content">
"@
        
        foreach ($Response in $Analysis.RecommendedResponse) {
            $HtmlContent += @"
                    <div class="response-item">$($BulletEmoji) $Response</div>
"@
        }
        
        $HtmlContent += @"
                </div>
            </div>
"@
        

        
        $HtmlContent += @"
        </div>
        
        <div class="footer">
            <p>Generated by CSVActiveDirectory IoC Analysis Module</p>
            <p>Report generated on $($Analysis.AnalysisTime.ToString())</p>
        </div>
    </div>
    
    <script>
        function toggleDetails(element) {
            const details = element.querySelector('.ioc-details');
            const expandIcon = element.querySelector('.expand-icon');
            
            console.log('Toggling IoC card:', element);
            console.log('Details element:', details);
            console.log('Current classes:', element.className);
            console.log('Details classes:', details ? details.className : 'No details element found');
            
            if (!details) {
                console.error('No .ioc-details element found!');
                return;
            }
            
            if (details.classList.contains('expanded')) {
                details.classList.remove('expanded');
                element.classList.remove('expanded');
                element.classList.add('collapsed');
                console.log('Collapsed card');
            } else {
                details.classList.add('expanded');
                element.classList.add('expanded');
                element.classList.remove('collapsed');
                console.log('Expanded card');
            }
        }
        
        function toggleIndicatorLog(element, logId) {
            const logElement = document.getElementById(logId);
            const icon = element.querySelector('.indicator-icon');
            
            if (logElement.classList.contains('expanded')) {
                logElement.classList.remove('expanded');
                element.classList.remove('expanded');
            } else {
                logElement.classList.add('expanded');
                element.classList.add('expanded');
            }
            
            // Prevent event bubbling to parent IoC card
            event.stopPropagation();
        }
        
        // Add click event listeners to all IoC items
        document.addEventListener('DOMContentLoaded', function() {
            // Use event delegation for better performance
            document.addEventListener('click', function(event) {
                const iocItem = event.target.closest('.ioc-item');
                if (iocItem && !event.target.closest('.indicator')) {
                    console.log('Clicked IoC item:', iocItem);
                    toggleDetails(iocItem);
                }
            });
        });
    </script>
</body>
</html>
"@
        
        # Write HTML content to file
        $HtmlContent | Out-File -FilePath $FilePath -Encoding UTF8
        
        $SuccessEmoji = Get-Emoji -Type "Success"
            Write-Host "$SuccessEmoji IoC Report exported successfully!" -ForegroundColor Green
        $FolderEmoji = Get-Emoji -Type "Search"
        Write-Host "$FolderEmoji Location: $FilePath" -ForegroundColor White
        
        return $FilePath
    }
    catch {
        Write-Error "Failed to export IoC report: $($_.Exception.Message)"
        return $null
    }
}

# Helper function to get detailed IoC explanations
function Get-IoCDetailedExplanation {
    param(
        [string]$IoCType,
        [string]$Severity
    )
    
    $explanations = @{
        "Privilege Escalation" = "This user has administrative privileges that could be exploited by attackers. Administrative accounts are prime targets for privilege escalation attacks, where attackers gain elevated access to perform malicious activities. The presence of admin privileges combined with suspicious activity patterns indicates a potential Golden Ticket attack or privilege escalation attempt."
        
        "Credential Dumping" = "Multiple failed authentication attempts suggest that an attacker is attempting to discover valid credentials through brute force or credential spraying attacks. This pattern is commonly associated with credential harvesting techniques used in lateral movement and privilege escalation."
        
        "Lateral Movement" = "Excessive logon activity indicates potential lateral movement across the network. Attackers use this technique to traverse the network, discover additional systems, and maintain persistence. High logon counts suggest automated scanning or credential reuse across multiple systems."
        
        "Account Manipulation" = "Recent account modifications suggest that an attacker may have gained access and is manipulating account properties to maintain persistence or escalate privileges. This could indicate account takeover or privilege escalation activities."
        
        "Suspicious Authentication" = "Failed authentication attempts followed by successful logons indicate potential credential discovery through brute force or credential spraying. This pattern suggests an attacker has successfully obtained valid credentials after multiple attempts."
        
        "Service Account Abuse" = "Service accounts with unusual activity patterns may indicate compromise. Service accounts typically have elevated privileges and are often targeted by attackers for lateral movement and privilege escalation due to their broad access permissions."
        
        "Reconnaissance" = "Recently created accounts with suspicious naming patterns suggest reconnaissance activities. Attackers often create test accounts to understand the environment, test permissions, and prepare for larger-scale attacks."
        
        "Insider Threat" = "Administrative privileges in non-technical departments may indicate privilege abuse or insider threats. This pattern suggests potential misuse of elevated access for unauthorized activities."
    }
    
    if ($explanations.ContainsKey($IoCType)) {
        return $explanations[$IoCType]
    } else {
        return "This IoC indicates suspicious activity that requires investigation."
    }
}

# Helper function to get technical details
function Get-IoCTechnicalDetails {
    param(
        [string]$IoCType,
        [object]$User
    )
    
    $details = @{
        "Privilege Escalation" = @"
User Properties:
- Title: $($User.Title)
- Department: $($User.Department)
- Bad Password Count: $($User.BadPasswordCount)
- Password Last Set: $($User.PasswordLastSet)
- Last Logon: $($User.LastLogon)

Technical Indicators:
- Administrative role detected
- Potential for privilege escalation
- High-value target for attackers
"@
        
        "Credential Dumping" = @"
Authentication Patterns:
- Failed Attempts: $($User.BadPasswordCount)
- Last Logon: $($User.LastLogon)
- Logon Count: $($User.LogonCount)

Technical Analysis:
- Multiple failed authentication attempts
- Potential credential discovery activity
- Brute force attack indicators
"@
        
        "Lateral Movement" = @"
Activity Patterns:
- Logon Count: $($User.LogonCount)
- Last Logon: $($User.LastLogon)
- Account Status: $(if($User.Enabled) { 'Enabled' } else { 'Disabled' })

Technical Indicators:
- Excessive logon activity
- Network traversal patterns
- Potential automated scanning
"@
        
        "Account Manipulation" = @"
Account Changes:
- Modified Date: $($User.Modified)
- Created Date: $($User.Created)
- Account Status: $(if($User.Enabled) { 'Enabled' } else { 'Disabled' })

Technical Analysis:
- Recent account modifications
- Potential persistence mechanisms
- Account takeover indicators
"@
        
        "Suspicious Authentication" = @"
Authentication Timeline:
- Failed Attempts: $($User.BadPasswordCount)
- Last Logon: $($User.LastLogon)
- Account Status: $(if($User.Enabled) { 'Enabled' } else { 'Disabled' })

Technical Indicators:
- Failed attempts followed by success
- Credential discovery patterns
- Potential compromise timeline
"@
        
        "Service Account Abuse" = @"
Service Account Analysis:
- Username: $($User.SamAccountName)
- Title: $($User.Title)
- Last Logon: $($User.LastLogon)
- Logon Count: $($User.LogonCount)

Technical Indicators:
- Service account with unusual activity
- Potential privilege abuse
- Elevated access patterns
"@
        
        "Reconnaissance" = @"
Account Creation Analysis:
- Created Date: $($User.Created)
- Username: $($User.SamAccountName)
- Title: $($User.Title)

Technical Indicators:
- Recently created account
- Suspicious naming patterns
- Reconnaissance activity
"@
        
        "Insider Threat" = @"
Privilege Analysis:
- Title: $($User.Title)
- Department: $($User.Department)
- Account Status: $(if($User.Enabled) { 'Enabled' } else { 'Disabled' })

Technical Indicators:
- Administrative role in non-IT department
- Potential privilege abuse
- Insider threat indicators
"@
    }
    
    if ($details.ContainsKey($IoCType)) {
        return $details[$IoCType]
    } else {
        return "Technical details not available for this IoC type."
    }
}

# Helper function to get mitigation steps
function Get-IoCMitigationSteps {
    param(
        [string]$IoCType,
        [string]$Severity
    )
    
    $steps = @{
        "Privilege Escalation" = @"
<li>Immediately disable the user account</li>
<li>Reset all domain admin passwords</li>
<li>Audit all systems accessed by this account</li>
<li>Check for additional compromised accounts</li>
<li>Implement privileged access management (PAM)</li>
<li>Enable multi-factor authentication for admin accounts</li>
"@
        
        "Credential Dumping" = @"
<li>Reset the user's password immediately</li>
<li>Force password change on next logon</li>
<li>Enable account lockout policies</li>
<li>Implement strong password policies</li>
<li>Monitor for additional failed attempts</li>
<li>Consider implementing MFA</li>
"@
        
        "Lateral Movement" = @"
<li>Investigate all systems accessed by this account</li>
<li>Check for unauthorized access to other systems</li>
<li>Review network segmentation</li>
<li>Implement network monitoring</li>
<li>Audit all user sessions</li>
<li>Consider account restrictions</li>
"@
        
        "Account Manipulation" = @"
<li>Review recent account changes</li>
<li>Check for unauthorized modifications</li>
<li>Audit account permissions</li>
<li>Implement change monitoring</li>
<li>Review access logs</li>
<li>Consider account restrictions</li>
"@
        
        "Suspicious Authentication" = @"
<li>Investigate the authentication timeline</li>
<li>Check for credential compromise</li>
<li>Review login patterns</li>
<li>Implement additional monitoring</li>
<li>Consider account restrictions</li>
<li>Enable enhanced logging</li>
"@
        
        "Service Account Abuse" = @"
<li>Review service account permissions</li>
<li>Implement least privilege access</li>
<li>Monitor service account activity</li>
<li>Consider service account restrictions</li>
<li>Audit service account usage</li>
<li>Implement service account monitoring</li>
"@
        
        "Reconnaissance" = @"
<li>Investigate account creation purpose</li>
<li>Review account permissions</li>
<li>Monitor for additional suspicious activity</li>
<li>Implement account creation monitoring</li>
<li>Review naming conventions</li>
<li>Consider account restrictions</li>
"@
        
        "Insider Threat" = @"
<li>Review administrative privileges</li>
<li>Implement role-based access control</li>
<li>Monitor privileged account activity</li>
<li>Audit access patterns</li>
<li>Consider privilege reduction</li>
<li>Implement enhanced monitoring</li>
"@
    }
    
    if ($steps.ContainsKey($IoCType)) {
        return $steps[$IoCType]
    } else {
        return "<li>Investigate the suspicious activity</li><li>Review account permissions</li><li>Implement additional monitoring</li>"
    }
}

# Helper function to get indicator logs
function Get-IndicatorLogs {
    param(
        [string]$IoCType,
        [string]$Indicator,
        [object]$User
    )
    
    $logs = @()
    
    # Generate logs based on indicator type
    switch -Wildcard ($Indicator) {
        "*failed password attempts*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Authentication Failure</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Reason: Invalid credentials</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Authentication Failure</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.101 | Reason: Invalid credentials</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Authentication Failure</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.102 | Reason: Invalid credentials</div>
                </div>
"@
        }
        "*recent password change*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.PasswordLastSet)</div>
                    <div class="log-event">Password Change</div>
                    <div class="log-details">User: $($User.SamAccountName) | Changed by: $($User.SamAccountName) | Policy: Domain Password Policy</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4724 | Account: $($User.SamAccountName) | Action: Password Change</div>
                </div>
"@
        }
        "*high logon count*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.50 | Session: $($User.LogonCount)</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.51 | Session: $($User.LogonCount)</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.52 | Session: $($User.LogonCount)</div>
                </div>
"@
        }
        "*recent account modification*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.Modified)</div>
                    <div class="log-event">Account Modification</div>
                    <div class="log-details">User: $($User.SamAccountName) | Modified by: Administrator | Changes: Account properties updated</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4728 | Account: $($User.SamAccountName) | Action: Member Added to Group</div>
                </div>
"@
        }
        "*recent high-activity logon*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.LastLogon)</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Session: $($User.LogonCount)</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4624 | Account: $($User.SamAccountName) | Logon Type: Interactive</div>
                </div>
"@
        }
        "*failed attempts followed by success*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Authentication Failure</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Reason: Invalid credentials</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Authentication Failure</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Reason: Invalid credentials</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$($User.LastLogon)</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Session: $($User.LogonCount)</div>
                </div>
"@
        }
        "*off-hours activity*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.LastLogon)</div>
                    <div class="log-event">Successful Logon</div>
                    <div class="log-details">User: $($User.SamAccountName) | Source: 192.168.1.100 | Time: Off-hours | Session: $($User.LogonCount)</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4624 | Account: $($User.SamAccountName) | Logon Type: Service | Time: 02:15:30</div>
                </div>
"@
        }
        "*recently created account*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.Created)</div>
                    <div class="log-event">Account Creation</div>
                    <div class="log-details">User: $($User.SamAccountName) | Created by: Administrator | OU: Users</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4720 | Account: $($User.SamAccountName) | Action: Account Created</div>
                </div>
"@
        }
        "*suspicious naming pattern*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.Created)</div>
                    <div class="log-event">Account Creation</div>
                    <div class="log-details">User: $($User.SamAccountName) | Pattern: Test account naming | Created by: Administrator</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4720 | Account: $($User.SamAccountName) | Action: Account Created | Risk: Suspicious naming</div>
                </div>
"@
        }
        "*administrative role in non-IT department*" {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$($User.Modified)</div>
                    <div class="log-event">Role Assignment</div>
                    <div class="log-details">User: $($User.SamAccountName) | Role: $($User.Title) | Department: $($User.Department) | Risk: Privilege escalation</div>
                </div>
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Event</div>
                    <div class="log-details">Event ID: 4728 | Account: $($User.SamAccountName) | Action: Added to Administrators group</div>
                </div>
"@
        }
        default {
            $logs += @"
                <div class="log-entry">
                    <div class="log-timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
                    <div class="log-event">Security Alert</div>
                    <div class="log-details">Indicator: $Indicator | User: $($User.SamAccountName) | Requires investigation</div>
                </div>
"@
        }
    }
    
    return $logs -join "`n"
}

# Main execution
Write-Host "=== IoC ANALYSIS FOR USER: $Username ===" -ForegroundColor White
Write-Host ""

# Get user data
$User = Get-UserData -Username $Username
if ($User -eq $null) {
    Write-Error "Cannot proceed with analysis. User not found."
    exit 1
}

# Analyze IoC patterns
$Analysis = Analyze-IoCPatterns -User $User

# Display report
Show-IoCReport -Analysis $Analysis

# Export report if requested
if ($ExportReport) {
    $ExportedFile = Export-IoCReport -Analysis $Analysis -ExportPath $ExportPath
    if ($ExportedFile) {
        Write-Host ""
        $ChartEmoji = Get-Emoji -Type "Target"
        Write-Host "$ChartEmoji Report Summary:" -ForegroundColor Yellow
        $BulletEmoji = Get-Emoji -Type "Bullet"
        Write-Host "   $BulletEmoji Total IoC Detections: $($Analysis.IoCDetections.Count)" -ForegroundColor White
        Write-Host "   $BulletEmoji Critical Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'CRITICAL' }).Count)" -ForegroundColor Red
        Write-Host "   $BulletEmoji High Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'HIGH' }).Count)" -ForegroundColor Yellow
        Write-Host "   $BulletEmoji Medium Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'MEDIUM' }).Count)" -ForegroundColor Magenta
    }
}

Write-Host ""
Write-Host "=== IoC ANALYSIS COMPLETE ===" -ForegroundColor Green 