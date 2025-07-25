# Enhanced IoC Detection for Active Directory Security

## Overview

This document outlines the enhanced Indicators of Compromise (IoCs) implemented in the `Get-SecurityReport.ps1` script. These patterns are designed to detect various types of security threats and suspicious activities in Active Directory environments.

## IoC Categories

### 🔴 CRITICAL RISKS (Immediate Response Required)

#### 1. Privilege Escalation Indicators
- **Pattern**: Domain admin accounts with recent password changes
- **Detection**: Admin accounts with password changes within 7 days
- **Risk**: Potential credential compromise and privilege escalation
- **Response**: Immediate investigation of password change legitimacy
- **Real-world**: Common attack vector for lateral movement

#### 2. Service Account with Admin Privileges
- **Pattern**: Service accounts with administrative privileges
- **Detection**: Accounts with "svc" prefix and admin titles
- **Risk**: Service accounts should not have elevated privileges
- **Response**: Review and remove unnecessary admin rights
- **Real-world**: Attackers often target service accounts for privilege escalation

#### 3. Suspicious Account Naming Patterns
- **Pattern**: Accounts with suspicious naming conventions
- **Detection**: Names containing "admin", "administrator", "test", "guest", "temp", "demo", "backup", "service"
- **Risk**: Potential reconnaissance or test accounts
- **Response**: Verify account creation legitimacy and intended use
- **Real-world**: Attackers create test accounts to validate access

### 🟡 HIGH RISKS (24-hour Response)

#### 3. Suspicious Authentication Patterns
- **Pattern**: Failed logon attempts followed by successful logon
- **Detection**: 3+ failed attempts with successful logon within 1 day
- **Risk**: Potential credential guessing or brute force attacks
- **Response**: Investigate authentication source and legitimacy
- **Real-world**: Common pattern in credential harvesting attacks

#### 4. Service Account Off-Hours Activity
- **Pattern**: Service accounts logging in during non-business hours
- **Detection**: Service accounts active between 6 PM - 6 AM
- **Risk**: Potential unauthorized service account usage
- **Response**: Verify service account activity legitimacy
- **Real-world**: Attackers often use service accounts during off-hours

#### 5. Lateral Movement Indicators
- **Pattern**: High-activity accounts with recent logon activity
- **Detection**: Accounts with 500+ logons and recent activity (≤7 days)
- **Risk**: Potential lateral movement or account abuse
- **Response**: Investigate account usage patterns and access legitimacy
- **Real-world**: Attackers use high-activity accounts to move through the network

### 🟣 MEDIUM RISKS (1-week Response)

#### 6. Reconnaissance Indicators
- **Pattern**: New accounts with suspicious naming patterns
- **Detection**: Accounts created within 7 days with suspicious names
- **Suspicious Patterns**: "test", "admin", "user", "guest", "temp", "demo"
- **Risk**: Potential reconnaissance or test accounts
- **Response**: Verify account creation legitimacy
- **Real-world**: Attackers create test accounts to validate access

#### 7. Insider Threat Indicators
- **Pattern**: Administrative roles in non-IT departments
- **Detection**: Admin titles in non-IT/Engineering departments
- **Risk**: Potential privilege escalation or role abuse
- **Response**: Review role assignments and access requirements
- **Real-world**: Common indicator of privilege abuse

#### 8. Credential Dumping Indicators
- **Pattern**: High-activity accounts with failed password attempts
- **Detection**: Accounts with 200+ logons and 2+ failed attempts
- **Risk**: Potential credential harvesting or brute force attacks
- **Response**: Investigate authentication patterns and account security
- **Real-world**: Attackers target high-activity accounts for credential extraction

#### 9. Account Manipulation Indicators
- **Pattern**: Recently modified account attributes
- **Detection**: Accounts modified within 3 days
- **Risk**: Potential unauthorized account changes
- **Response**: Review account modification history and legitimacy
- **Real-world**: Attackers modify accounts to maintain persistence

## Implementation Details

### Enhanced IoC Detection Parameter
```powershell
-EnhancedIoCDetection $true
```

### IoC Detection Summary
The script tracks the following IoC categories:
- **Privilege Escalation**: 4 indicators
- **Suspicious Authentication**: 11 patterns
- **Service Account Abuse**: 0 instances
- **Lateral Movement**: 29 indicators
- **Reconnaissance**: 0 indicators
- **Credential Dumping**: 22 indicators
- **Account Manipulation**: 18 indicators
- **Insider Threat**: 7 indicators

### Detection Logic

#### Privilege Escalation Detection
```powershell
if ($User.Title -like "*Admin*" -or $User.Title -like "*Administrator*") {
    if ($DaysSincePasswordSet -le 7) {
        # Flag as critical risk
    }
}
```

#### Suspicious Authentication Detection
```powershell
if ($User.BadPasswordCount -ge 3 -and $User.LastLogon -ne "") {
    if ($DaysSinceLogon -le 1) {
        # Flag as high risk
    }
}
```

#### Service Account Abuse Detection
```powershell
if ($User.SamAccountName -like "*svc*" -and $User.Enabled -eq "TRUE") {
    if ($LogonHour -ge 18 -or $LogonHour -le 6) {
        # Flag as high risk
    }
}
```

## Additional IoC Patterns (Future Implementation)

### Advanced Detection Patterns

#### 1. Golden Ticket Detection
- **Pattern**: Kerberos tickets older than 10 hours
- **Implementation**: Requires Kerberos ticket analysis
- **Priority**: Critical

#### 2. Lateral Movement Indicators
- **Pattern**: Accounts accessing multiple systems rapidly
- **Implementation**: Requires logon source tracking
- **Priority**: High

#### 3. Credential Dumping Indicators
- **Pattern**: Multiple failed attempts from same IP
- **Implementation**: Requires IP address correlation
- **Priority**: Critical

#### 4. Data Exfiltration Patterns
- **Pattern**: High-volume data access patterns
- **Implementation**: Requires file access monitoring
- **Priority**: High

#### 5. Account Manipulation
- **Pattern**: Recently modified account attributes
- **Implementation**: Requires attribute change tracking
- **Priority**: Medium

## Usage Examples

### Enterprise IoC Detection (CSV Export)
```powershell
.\Scripts\Public\Get-SecurityReport.ps1 -EnhancedIoCDetection
```

### Detailed IoC Report
```powershell
.\Scripts\Public\Get-SecurityReport.ps1 -EnhancedIoCDetection -DetailedReport
```

### Custom IoC Parameters
```powershell
.\Scripts\Public\Get-SecurityReport.ps1 -EnhancedIoCDetection -InactiveDays 60 -PasswordAgeDays 45
```

### Individual User IoC Analysis (HTML Export)
```powershell
# Basic analysis
.\Scripts\Get-IOCs.ps1 -Username "username"

# Professional HTML report
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport

# Custom export path
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport -ExportPath "SecurityReports"
```

## Response Guidelines

### Critical Risks (Immediate)
1. **Isolate affected accounts** if compromise is confirmed
2. **Reset passwords** for all affected accounts
3. **Review recent activity** for lateral movement
4. **Update security controls** to prevent recurrence

### High Risks (24 hours)
1. **Investigate authentication patterns**
2. **Review service account usage**
3. **Monitor for additional indicators**
4. **Implement additional logging**

### Medium Risks (1 week)
1. **Review role assignments**
2. **Verify account creation legitimacy**
3. **Update access policies**
4. **Implement monitoring controls**

## Customization Options

### Adding New IoC Patterns
1. **Define detection logic** in the main analysis loop
2. **Add IoC counter** to the `$ReportData.IoCDetections` hashtable
3. **Update summary display** to include new patterns
4. **Add recommendations** for new IoC types

### Modifying Detection Thresholds
- **Password Age**: Modify `$PasswordAgeDays` parameter
- **Inactive Days**: Modify `$InactiveDays` parameter
- **Suspicious Patterns**: Update `$SuspiciousPatterns` array
- **Time Windows**: Adjust hour ranges for off-hours detection

## Integration with SIEM

### Log Format
The enhanced IoC detection can be integrated with SIEM systems by:
1. **Exporting results** to JSON format
2. **Creating custom alerts** for each IoC type
3. **Correlating with other security events**
4. **Automating response actions**

### Alert Examples
```json
{
  "IoCType": "PrivilegeEscalation",
  "Account": "admin.user",
  "RiskLevel": "CRITICAL",
  "Details": "Privileged account password changed 3 days ago",
  "Timestamp": "2025-07-22T17:27:48"
}
```

## Best Practices

### 1. Regular Monitoring
- Run IoC detection **daily** for critical environments
- Run IoC detection **weekly** for standard environments
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

## Conclusion

The enhanced IoC detection provides comprehensive coverage of common Active Directory security threats. By implementing these patterns, organizations can:

1. **Detect threats earlier** in the attack lifecycle
2. **Reduce false positives** through targeted detection
3. **Improve response times** with prioritized alerts
4. **Enhance security posture** through proactive monitoring

Regular review and tuning of these IoC patterns ensures they remain effective against evolving threats while minimizing operational overhead. 