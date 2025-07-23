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
    [switch]$ExportReport = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "$env:USERPROFILE\Documents\IoCReports"
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Warning "Active Directory module not available. Using CSV simulation module."
    Import-Module .\CSVActiveDirectory.psd1 -Force
}

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
                    $PrivilegeEscalation.Confidence += 10
                }
            }
            catch { }
        }
        
        # Check for failed password attempts
        if ($User.BadPasswordCount -ge 3) {
            $PrivilegeEscalation.Indicators += "High failed password attempts ($($User.BadPasswordCount))"
            $PrivilegeEscalation.Confidence += 15
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
                    $CredentialDumping.Confidence += 10
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
                    $LateralMovement.Confidence += 10
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
                    $ServiceAccountAbuse.Confidence += 15
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
                        $Reconnaissance.Confidence += 10
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
        $IoCAnalysis.Confidence = [math]::Min(100, ($IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "CRITICAL" } | Measure-Object -Property Confidence -Average).Average)
    }
    elseif ($HighCount -gt 0) {
        $IoCAnalysis.Severity = "HIGH"
        $IoCAnalysis.Confidence = [math]::Min(100, ($IoCAnalysis.IoCDetections | Where-Object { $_.Severity -eq "HIGH" } | Measure-Object -Property Confidence -Average).Average)
    }
    else {
        $IoCAnalysis.Confidence = [math]::Min(100, ($IoCAnalysis.IoCDetections | Measure-Object -Property Confidence -Average).Average)
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
    
    Write-Host "=== IoC ANALYSIS REPORT ===" -ForegroundColor Cyan
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
        "LOW" { "Blue" }
    }
    
    Write-Host "=== OVERALL ASSESSMENT ===" -ForegroundColor Cyan
    Write-Host "Severity: $($Analysis.Severity)" -ForegroundColor $SeverityColor
    Write-Host "Confidence: $($Analysis.Confidence)%" -ForegroundColor White
    Write-Host "Attack Patterns: $($Analysis.AttackPatterns -join ', ')" -ForegroundColor White
    Write-Host ""
    
    # IoC Detections
    if ($Analysis.IoCDetections.Count -gt 0) {
        Write-Host "=== IoC DETECTIONS ===" -ForegroundColor Cyan
        foreach ($IoC in $Analysis.IoCDetections) {
            $Color = switch ($IoC.Severity) {
                "CRITICAL" { "Red" }
                "HIGH" { "Yellow" }
                "MEDIUM" { "Magenta" }
                "LOW" { "Blue" }
            }
            
            Write-Host "[$($IoC.Severity)] $($IoC.Type)" -ForegroundColor $Color
            Write-Host "  Attack Type: $($IoC.AttackType)" -ForegroundColor White
            Write-Host "  Confidence: $($IoC.Confidence)%" -ForegroundColor White
            Write-Host "  Description: $($IoC.Description)" -ForegroundColor White
            Write-Host "  Indicators:" -ForegroundColor White
            foreach ($Indicator in $IoC.Indicators) {
                Write-Host "    • $Indicator" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
    
    # Recommended Response
    Write-Host "=== RECOMMENDED RESPONSE ===" -ForegroundColor Cyan
    foreach ($Response in $Analysis.RecommendedResponse) {
        Write-Host "• $Response" -ForegroundColor White
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
    
    Write-Host "=== ACCURACY ASSESSMENT ===" -ForegroundColor Cyan
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        .indicators {
            margin-top: 15px;
        }
        .indicator {
            background: white;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 8px;
            border-left: 3px solid #007bff;
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
            <h1>🔍 IoC Analysis Report</h1>
            <div class="subtitle">Threat Intelligence & Security Assessment</div>
        </div>
        
        <div class="content">
            <!-- User Information Section -->
            <div class="section">
                <div class="section-header">👤 User Information</div>
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
                <div class="section-header">📊 Overall Assessment</div>
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
                <div class="section-header">🚨 IoC Detections</div>
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
                    <div class="ioc-item $SeverityClass">
                        <div class="ioc-header">
                            <div class="ioc-title">$($IoC.Type)</div>
                            <div>
                                <span class="severity-badge $SeverityBadgeClass">$($IoC.Severity)</span>
                                <span class="ioc-confidence">$($IoC.Confidence)% confidence</span>
                            </div>
                        </div>
                        <div class="ioc-description">$($IoC.Description)</div>
                        <div class="ioc-attack-type">🎯 Attack Type: $($IoC.AttackType)</div>
"@
                
                if ($IoC.Indicators.Count -gt 0) {
                    $HtmlContent += @"
                        <div class="indicators">
                            <strong>🔍 Indicators:</strong>
"@
                    foreach ($Indicator in $IoC.Indicators) {
                        $HtmlContent += @"
                            <div class="indicator">• $Indicator</div>
"@
                    }
                    $HtmlContent += @"
                        </div>
"@
                }
                
                $HtmlContent += @"
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
                <div class="section-header">⚡ Recommended Response</div>
                <div class="section-content">
"@
        
        foreach ($Response in $Analysis.RecommendedResponse) {
            $HtmlContent += @"
                    <div class="response-item">• $Response</div>
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
</body>
</html>
"@
        
        # Write HTML content to file
        $HtmlContent | Out-File -FilePath $FilePath -Encoding UTF8
        
        Write-Host "✅ IoC Report exported successfully!" -ForegroundColor Green
        Write-Host "📁 Location: $FilePath" -ForegroundColor Cyan
        
        return $FilePath
    }
    catch {
        Write-Error "Failed to export IoC report: $($_.Exception.Message)"
        return $null
    }
}

# Main execution
Write-Host "=== IoC ANALYSIS FOR USER: $Username ===" -ForegroundColor Cyan
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
        Write-Host "📊 Report Summary:" -ForegroundColor Yellow
        Write-Host "   • Total IoC Detections: $($Analysis.IoCDetections.Count)" -ForegroundColor White
        Write-Host "   • Critical Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'CRITICAL' }).Count)" -ForegroundColor Red
        Write-Host "   • High Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'HIGH' }).Count)" -ForegroundColor Yellow
        Write-Host "   • Medium Detections: $(($Analysis.IoCDetections | Where-Object { $_.Severity -eq 'MEDIUM' }).Count)" -ForegroundColor Magenta
    }
}

Write-Host ""
Write-Host "=== IoC ANALYSIS COMPLETE ===" -ForegroundColor Green 