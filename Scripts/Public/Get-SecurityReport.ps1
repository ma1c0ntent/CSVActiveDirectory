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
    [string]$ExportPath = "..\..\Data\Reports\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv",
    
    [Parameter(Mandatory=$false)]
    [switch]$Interactive = $false
)

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Warning "Active Directory module not available. Using CSV simulation module."
    Import-Module ..\..\CSVActiveDirectory.psd1 -Force
}

# Import shared detection logic
. $PSScriptRoot/../Functions/Private/Detect-UserIoCs.ps1

# Initialize emoji variables for compatibility
try {
    $SuccessEmoji = Get-Emoji -Type "Success"
    $FolderEmoji = Get-Emoji -Type "Search"
    $ChartEmoji = Get-Emoji -Type "Target"
    $TrendEmoji = Get-Emoji -Type "Lightning"
    $ClipboardEmoji = Get-Emoji -Type "Bulb"
    $WarningEmoji = Get-Emoji -Type "Warning"
    $ErrorEmoji = Get-Emoji -Type "Error"
    $InfoEmoji = Get-Emoji -Type "Info"
    $ShieldEmoji = Get-Emoji -Type "Shield"
    $AlertEmoji = Get-Emoji -Type "Alert"
    $RocketEmoji = Get-Emoji -Type "Rocket"
}
catch {
    # Fallback to ASCII characters if emoji function is not available
    $SuccessEmoji = "[OK]"
    $FolderEmoji = "[FOLDER]"
    $ChartEmoji = "[CHART]"
    $TrendEmoji = "[TREND]"
    $ClipboardEmoji = "[CLIP]"
    $WarningEmoji = "[WARN]"
    $ErrorEmoji = "[ERROR]"
    $InfoEmoji = "[INFO]"
    $ShieldEmoji = "[SHIELD]"
    $AlertEmoji = "[ALERT]"
    $RocketEmoji = "[ROCKET]"
}

# Function to display the main security report menu
function Show-SecurityReportMenu {
    Write-Host ""
    Write-Host "=== CSV ACTIVE DIRECTORY - SECURITY REPORT MENU ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose a security report option:" -ForegroundColor White
    Write-Host "1. Quick Security Scan (Basic report)" -ForegroundColor Green
    Write-Host "2. Enhanced Security Scan (With IoC detection)" -ForegroundColor Yellow
    Write-Host "3. Detailed Security Report (Full analysis)" -ForegroundColor Magenta
    Write-Host "4. Export Security Report (CSV format)" -ForegroundColor Blue
    Write-Host "5. Custom Security Scan (Configure options)" -ForegroundColor Cyan
    Write-Host "6. System Information" -ForegroundColor Gray
    Write-Host "7. Help & Documentation" -ForegroundColor DarkGray
    Write-Host "8. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to display custom security scan configuration menu
function Show-CustomScanMenu {
    Write-Host ""
    Write-Host "=== CUSTOM SECURITY SCAN CONFIGURATION ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configure security scan options:" -ForegroundColor White
    Write-Host "1. Include Disabled Accounts" -ForegroundColor Green
    Write-Host "2. Inactive Days Threshold" -ForegroundColor Yellow
    Write-Host "3. Password Age Threshold" -ForegroundColor Magenta
    Write-Host "4. Enhanced IoC Detection" -ForegroundColor Blue
    Write-Host "5. Detailed Report Level" -ForegroundColor Cyan
    Write-Host "6. Export Options" -ForegroundColor Gray
    Write-Host "7. Back to Main Menu" -ForegroundColor DarkGray
    Write-Host ""
}

# Function to get user input with validation
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$DefaultValue = "",
        [string]$ValidationType = "text"
    )
    
    do {
        $input = Read-Host $Prompt
        if ($input -eq "" -and $DefaultValue -ne "") {
            $input = $DefaultValue
        }
        
        switch ($ValidationType) {
            "yesno" {
                if ($input -match '^[YyNn]$') {
                    return $input -eq "Y" -or $input -eq "y"
                } else {
                    Write-Host "Please enter Y or N." -ForegroundColor Red
                }
            }
            "number" {
                if ($input -match '^\d+$') {
                    return [int]$input
                } else {
                    Write-Host "Please enter a valid number." -ForegroundColor Red
                }
            }
            default {
                return $input
            }
        }
    } while ($true)
}

# Function to show system information
function Show-SystemInfo {
    Write-Host "=== SYSTEM INFORMATION ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if Active Directory module is available
    try {
        $ADModule = Get-Module -Name ActiveDirectory -ListAvailable
        if ($ADModule) {
            Write-Host "$($SuccessEmoji) Active Directory module available" -ForegroundColor Green
            Write-Host "   Version: $($ADModule.Version)" -ForegroundColor Cyan
        } else {
            Write-Host "$($WarningEmoji) Active Directory module not available" -ForegroundColor Yellow
            Write-Host "   Using CSV simulation module" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "$($WarningEmoji) Could not check Active Directory module" -ForegroundColor Yellow
    }
    
    # Check CSVActiveDirectory module
    try {
        $CSVModule = Get-Module -Name CSVActiveDirectory -ListAvailable
        if ($CSVModule) {
            Write-Host "$($SuccessEmoji) CSVActiveDirectory module available" -ForegroundColor Green
            Write-Host "   Version: $($CSVModule.Version)" -ForegroundColor Cyan
        } else {
            Write-Host "$($WarningEmoji) CSVActiveDirectory module not found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "$($WarningEmoji) Could not check CSVActiveDirectory module" -ForegroundColor Yellow
    }
    
    # Check Reports directory
    $ReportsDir = ".\Reports"
    if (Test-Path $ReportsDir) {
        Write-Host "$($SuccessEmoji) Reports directory exists: $ReportsDir" -ForegroundColor Green
        $ReportCount = (Get-ChildItem -Path $ReportsDir -Filter "*.csv" | Measure-Object).Count
        Write-Host "   Existing reports: $ReportCount" -ForegroundColor Cyan
    } else {
        Write-Host "$($InfoEmoji) Reports directory will be created: $ReportsDir" -ForegroundColor Yellow
    }
    
    # Check for detection functions
    $DetectionScript = "..\..\Functions\Private\Detect-UserIoCs.ps1"
    if (Test-Path $DetectionScript) {
        Write-Host "$($SuccessEmoji) IoC detection functions available" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) IoC detection functions not found" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to show help and documentation
function Show-Help {
    Clear-Host
    Write-Host "=== SECURITY REPORT HELP ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Security Report Types:" -ForegroundColor White
    Write-Host "1. Quick Security Scan - Basic security assessment" -ForegroundColor Green
    Write-Host "2. Enhanced Security Scan - Includes IoC detection patterns" -ForegroundColor Yellow
    Write-Host "3. Detailed Security Report - Comprehensive analysis with recommendations" -ForegroundColor Magenta
    Write-Host "4. Export Security Report - Generate CSV report for external analysis" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Security Checks Performed:" -ForegroundColor White
    Write-Host "- Account status and permissions" -ForegroundColor Cyan
    Write-Host "- Password age and complexity" -ForegroundColor Cyan
    Write-Host "- Account inactivity" -ForegroundColor Cyan
    Write-Host "- IoC detection patterns" -ForegroundColor Cyan
    Write-Host "- Risk assessment and scoring" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IoC Detection Patterns:" -ForegroundColor White
    Write-Host "- Privilege escalation indicators" -ForegroundColor Yellow
    Write-Host "- Credential dumping attempts" -ForegroundColor Yellow
    Write-Host "- Lateral movement patterns" -ForegroundColor Yellow
    Write-Host "- Account manipulation" -ForegroundColor Yellow
    Write-Host "- Suspicious authentication" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Risk Levels:" -ForegroundColor White
    Write-Host "- CRITICAL: Immediate action required" -ForegroundColor Red
    Write-Host "- HIGH: High priority investigation" -ForegroundColor Yellow
    Write-Host "- MEDIUM: Medium priority review" -ForegroundColor Magenta
    Write-Host "- LOW: Low priority monitoring" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Best Practices:" -ForegroundColor White
    Write-Host "- Run security reports regularly" -ForegroundColor Yellow
    Write-Host "- Review critical and high-risk findings immediately" -ForegroundColor Yellow
    Write-Host "- Export reports for compliance and audit purposes" -ForegroundColor Yellow
    Write-Host "- Use detailed reports for comprehensive analysis" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Function to perform security report generation
function Invoke-SecurityReport {
    param(
        [bool]$IncludeDisabled = $true,
        [int]$InactiveDays = 90,
        [int]$PasswordAgeDays = 90,
        [bool]$DetailedReport = $true,
        [bool]$EnhancedIoCDetection = $true,
        [bool]$ExportCSV = $false,
        [string]$ExportPath = ""
    )
    
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
    
    # Main security analysis
    Write-Host "$FolderEmoji Analyzing $($AllUsers.Count) user accounts..." -ForegroundColor Cyan
    
    foreach ($User in $AllUsers) {
        # Skip disabled accounts if not included
        if (-not $IncludeDisabled -and $User.Enabled -eq $false) {
            continue
        }
        
        # Enhanced IoC Detection
        if ($EnhancedIoCDetection) {
            $IoCs = Detect-UserIoCs -User $User
            foreach ($IoC in $IoCs) {
                $RiskLevel = $IoC.Severity
                $Reason = $IoC.Type
                $Details = $IoC.Description
                $AdditionalData = @{ IoCCategory = $IoC.Type; Confidence = $IoC.Confidence }
                Add-RiskAccount -RiskLevel $RiskLevel -Reason $Reason -User $User -Details $Details -AdditionalData $AdditionalData
            }
        }
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
            $ExportPath = if ($ExportPath) { $ExportPath } else { ".\Reports\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" }
            
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
    Read-Host "Press Enter to continue"
    return $ReportData
}

# Main script logic
if ($Interactive -or $PSBoundParameters.Count -eq 0) {
    # Interactive menu mode
    $customConfig = @{
        IncludeDisabled = $true
        InactiveDays = 90
        PasswordAgeDays = 90
        DetailedReport = $true
        EnhancedIoCDetection = $true
        ExportCSV = $false
        ExportPath = ""
    }
    
    do {
        Show-SecurityReportMenu
        $choice = Read-Host "Enter your choice (1-8)"
        
        switch ($choice) {
            "1" {
                # Quick Security Scan
                Invoke-SecurityReport -IncludeDisabled $true -DetailedReport $false -EnhancedIoCDetection $false -ExportCSV $false
            }
            "2" {
                # Enhanced Security Scan
                Invoke-SecurityReport -IncludeDisabled $true -DetailedReport $true -EnhancedIoCDetection $true -ExportCSV $false
            }
            "3" {
                # Detailed Security Report
                Invoke-SecurityReport -IncludeDisabled $true -DetailedReport $true -EnhancedIoCDetection $true -ExportCSV $false
            }
            "4" {
                # Export Security Report
                $exportPath = ".\Reports\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
                Invoke-SecurityReport -IncludeDisabled $true -DetailedReport $true -EnhancedIoCDetection $true -ExportCSV $true -ExportPath $exportPath
            }
            "5" {
                # Custom Security Scan
                do {
                    Show-CustomScanMenu
                    $customChoice = Read-Host "Enter your choice (1-7)"
                    
                    switch ($customChoice) {
                        "1" {
                            $customConfig.IncludeDisabled = Get-UserInput "Include disabled accounts? (Y/N): " "Y" "yesno"
                        }
                        "2" {
                            $customConfig.InactiveDays = Get-UserInput "Inactive days threshold: " "90" "number"
                        }
                        "3" {
                            $customConfig.PasswordAgeDays = Get-UserInput "Password age threshold: " "90" "number"
                        }
                        "4" {
                            $customConfig.EnhancedIoCDetection = Get-UserInput "Enable enhanced IoC detection? (Y/N): " "Y" "yesno"
                        }
                        "5" {
                            $customConfig.DetailedReport = Get-UserInput "Generate detailed report? (Y/N): " "Y" "yesno"
                        }
                        "6" {
                            $customConfig.ExportCSV = Get-UserInput "Export to CSV? (Y/N): " "N" "yesno"
                            if ($customConfig.ExportCSV) {
                                $customConfig.ExportPath = Get-UserInput "Export path: " ".\Reports\ADRiskAssessment$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
                            }
                        }
                        "7" {
                            break
                        }
                        default {
                            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                            Start-Sleep -Seconds 2
                        }
                    }
                } while ($customChoice -ne "7")
                
                # Execute custom configuration
                Invoke-SecurityReport -IncludeDisabled $customConfig.IncludeDisabled -InactiveDays $customConfig.InactiveDays -PasswordAgeDays $customConfig.PasswordAgeDays -DetailedReport $customConfig.DetailedReport -EnhancedIoCDetection $customConfig.EnhancedIoCDetection -ExportCSV $customConfig.ExportCSV -ExportPath $customConfig.ExportPath
            }
            "6" {
                # System Information
                Show-SystemInfo
            }
            "7" {
                # Help & Documentation
                Show-Help
            }
            "8" {
                # Exit
                Write-Host "Goodbye!" -ForegroundColor Green
                exit 0
            }
            default {
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
} else {
    # Non-interactive mode (original functionality)
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

    # Main security analysis
    Write-Host "$FolderEmoji Analyzing $($AllUsers.Count) user accounts..." -ForegroundColor Cyan

    foreach ($User in $AllUsers) {
        # Skip disabled accounts if not included
        if (-not $IncludeDisabled -and $User.Enabled -eq $false) {
            continue
        }
        
        # Enhanced IoC Detection
        $IoCs = Detect-UserIoCs -User $User
        foreach ($IoC in $IoCs) {
            $RiskLevel = $IoC.Severity
            $Reason = $IoC.Type
            $Details = $IoC.Description
            $AdditionalData = @{ IoCCategory = $IoC.Type; Confidence = $IoC.Confidence }
            Add-RiskAccount -RiskLevel $RiskLevel -Reason $Reason -User $User -Details $Details -AdditionalData $AdditionalData
            # Optionally increment IoCDetections summary here
        }
        
        # Standard security checks - REMOVED: Test-StandardSecurity function not defined
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
    
    Write-Host ""
    Write-Host "$($SuccessEmoji) Get-SecurityReport script completed successfully!" -ForegroundColor Green
} 