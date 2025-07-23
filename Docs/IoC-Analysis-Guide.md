# IoC Analysis Guide

## Overview

The `Get-IOCs.ps1` script provides detailed threat analysis for individual Active Directory users, detecting various Indicators of Compromise (IoCs) and generating professional HTML reports for security teams.

## Features

### 🔍 **Individual User Analysis**
- **Targeted Analysis**: Focus on specific user accounts
- **Detailed IoC Detection**: Multiple threat pattern recognition
- **Professional HTML Reports**: Modern, visually appealing output
- **Real-time Assessment**: Immediate threat evaluation

### 📊 **Comprehensive IoC Detection**

#### **🔴 CRITICAL RISKS**
- **Privilege Escalation**: Admin accounts with recent password changes
- **Credential Dumping**: Excessive failed password attempts
- **Golden Ticket Attacks**: Administrative privilege abuse

#### **🟡 HIGH RISKS**
- **Lateral Movement**: High logon activity suggesting network traversal
- **Suspicious Authentication**: Failed attempts followed by successful logon
- **Account Manipulation**: Recent account modifications

#### **🟣 MEDIUM RISKS**
- **Service Account Abuse**: Service accounts with unusual activity
- **Reconnaissance**: New accounts with suspicious naming patterns
- **Insider Threat**: Administrative roles in non-IT departments

## Usage

### Basic IoC Analysis
```powershell
.\Scripts\Get-IOCs.ps1 -Username "username"
```

### Detailed Analysis with HTML Export
```powershell
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport -ExportPath "Reports"
```

### Custom Export Path
```powershell
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport -ExportPath "C:\SecurityReports"
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Username` | string | Yes | - | Target user account name |
| `Detailed` | switch | No | $true | Enable detailed analysis |
| `ExportReport` | switch | No | $false | Generate HTML report |
| `ExportPath` | string | No | `$env:USERPROFILE\Documents\IoCReports` | Export directory |

## HTML Report Features

### 🎨 **Professional Design**
- **Modern styling** with gradient headers
- **Color-coded severity levels** (Red=Critical, Orange=High, Yellow=Medium, Blue=Low)
- **Responsive layout** for different screen sizes
- **Professional typography** using system fonts

### 📋 **Report Sections**

#### **1. User Information**
- Username, Display Name, Department, Title
- Account Status (Enabled/Disabled)
- Clear, organized grid layout

#### **2. Overall Assessment**
- **Summary Statistics**: Severity, Confidence, Detection Count
- **Attack Patterns**: Identified threat categories
- **Visual indicators** with color-coded severity

#### **3. IoC Detections**
- **Detailed threat analysis** for each detection
- **Attack types** and descriptions
- **Individual indicators** with specific details
- **Confidence levels** for each detection

#### **4. Recommended Response**
- **Prioritized action items** based on severity
- **Clear next steps** for security teams
- **Color-coded recommendations** matching severity levels

### 📁 **File Naming Convention**
```
IoC_username_YYYYMMDD-HHMMSS.html
```
Example: `IoC_jmorales_20250722-212310.html`

## IoC Detection Logic

### Privilege Escalation Detection
```powershell
if ($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*") {
    if ($DaysSincePasswordSet -le 7) {
        # Flag as CRITICAL risk
    }
}
```

### Lateral Movement Detection
```powershell
if ($User.LogonCount -ge 200) {
    if ($DaysSinceLogon -le 7) {
        # Flag as HIGH risk
    }
}
```

### Credential Dumping Detection
```powershell
if ($User.BadPasswordCount -ge 5) {
    # Flag as CRITICAL risk
}
```

## Report Examples

### Console Output
```
=== IoC ANALYSIS FOR USER: jmorales ===

=== IoC ANALYSIS REPORT ===
User: jmorales
Display Name: Jacqueline Morales
Department: Marketing
Title: Marketing Specialist
Enabled: TRUE

=== OVERALL ASSESSMENT ===
Severity: HIGH
Confidence: 95%
Attack Patterns: Lateral Movement

=== IoC DETECTIONS ===
[HIGH] Lateral Movement
  Attack Type: Lateral Movement / Network Traversal
  Confidence: 95%
  Description: Excessive logon activity suggests network traversal
  Indicators:
    • High logon count (226)
    • Recent high-activity logon (4 days ago)

=== RECOMMENDED RESPONSE ===
• URGENT: Investigate user account activity
• HIGH: Reset user password
• MEDIUM: Monitor account for suspicious activity
```

### HTML Report Features
- **Professional styling** with gradient headers
- **Color-coded severity badges**
- **Organized sections** with clear visual hierarchy
- **Detailed indicators** for each IoC detection
- **Actionable recommendations** with priority levels

## Response Guidelines

### Critical Risks (Immediate Response)
1. **Disable user account** if compromise is confirmed
2. **Reset all domain admin passwords** if privilege escalation detected
3. **Audit all systems** accessed by the account
4. **Check for additional compromised accounts**

### High Risks (24-hour Response)
1. **Investigate user account activity**
2. **Reset user password**
3. **Monitor account for suspicious activity**
4. **Review authentication patterns**

### Medium Risks (1-week Response)
1. **Review account permissions**
2. **Monitor for unusual activity**
3. **Verify account creation legitimacy**
4. **Update access policies**

## Integration with Security Tools

### SIEM Integration
```powershell
# Export for SIEM analysis
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport -ExportPath "SIEM\Reports"
```

### Incident Response
```powershell
# Generate report for incident response
.\Scripts\Get-IOCs.ps1 -Username "compromised_user" -ExportReport -ExportPath "IncidentResponse"
```

### Compliance Reporting
```powershell
# Create compliance documentation
.\Scripts\Get-IOCs.ps1 -Username "audit_user" -ExportReport -ExportPath "Compliance\Reports"
```

## Best Practices

### 1. Regular Monitoring
- Run IoC analysis **daily** for high-risk accounts
- Run IoC analysis **weekly** for standard accounts
- **Review and tune** detection thresholds regularly

### 2. False Positive Management
- **Whitelist legitimate patterns** (e.g., scheduled service accounts)
- **Adjust thresholds** based on environment characteristics
- **Document exceptions** for audit purposes

### 3. Response Automation
- **Automate critical IoC responses** where possible
- **Create playbooks** for each IoC type
- **Integrate with incident response** workflows

### 4. Continuous Improvement
- **Track IoC effectiveness** over time
- **Update detection patterns** based on new threats
- **Share findings** with security community

## Troubleshooting

### Common Issues

#### 1. User Not Found
```
Error: User 'username' not found or cannot be accessed.
```
**Solution**: Verify username spelling and Active Directory connectivity

#### 2. Export Path Issues
```
Error: Failed to export IoC report
```
**Solution**: Ensure export directory has write permissions

#### 3. Module Dependencies
```
Warning: Active Directory module not available
```
**Solution**: Install RSAT tools or use CSV simulation module

### Performance Optimization
- **Limit concurrent analyses** for large environments
- **Use specific usernames** rather than bulk analysis
- **Schedule reports** during off-peak hours

## Advanced Configuration

### Custom Detection Thresholds
```powershell
# Modify detection logic in Get-IOCs.ps1
$LogonCountThreshold = 200  # Default: 200
$BadPasswordThreshold = 5   # Default: 5
$PasswordAgeThreshold = 7   # Default: 7 days
```

### Custom Export Styling
```powershell
# Modify HTML template in Export-IoCReport function
$SeverityColor = switch ($Analysis.Severity) {
    "CRITICAL" { "#dc3545" }
    "HIGH" { "#fd7e14" }
    "MEDIUM" { "#ffc107" }
    "LOW" { "#17a2b8" }
}
```

## Conclusion

The IoC analysis functionality provides comprehensive threat detection for individual Active Directory users with professional HTML reporting capabilities. By implementing these features, organizations can:

1. **Detect threats earlier** in the attack lifecycle
2. **Generate professional reports** for stakeholders
3. **Improve response times** with detailed analysis
4. **Enhance security posture** through proactive monitoring

Regular review and tuning of IoC patterns ensures they remain effective against evolving threats while providing clear, actionable intelligence for security teams. 