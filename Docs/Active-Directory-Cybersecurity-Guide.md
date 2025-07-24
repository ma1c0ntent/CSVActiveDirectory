# Active Directory Cybersecurity & IoC Detection Guide

## Overview

This comprehensive guide combines cybersecurity scenarios and enhanced Indicators of Compromise (IoCs) for Active Directory security assessment. It covers both database generation patterns and real-time detection capabilities for enterprise security environments.

## 🎯 Key Components

### 1. Database Generation (`Create-150UserDatabase.ps1`)
- **150 users** with realistic cybersecurity scenarios
- **30% risky users** with various threat patterns
- **Real-world incident response** scenarios

### 2. Enhanced IoC Detection (`Get-SecurityReport.ps1`)
- **Advanced threat detection** patterns
- **Real-time security assessment**
- **CSV export with IoC categorization**

---

## 🔴 CRITICAL RISKS (Immediate Response Required)

### 1. Privilege Escalation Indicators
- **Pattern**: Domain admin accounts with recent password changes
- **Detection**: Admin accounts with password changes within 7 days
- **IoCCategory**: `PrivilegeEscalation`
- **Response**: Immediate investigation of password change legitimacy
- **Real-world**: Common attack vector for lateral movement

### 2. Service Account with Admin Privileges
- **Pattern**: Service accounts with administrative privileges
- **Detection**: Accounts with "svc" prefix and admin titles
- **IoCCategory**: `PrivilegeEscalation`
- **Risk**: Service accounts should not have elevated privileges
- **Response**: Review and remove unnecessary admin rights
- **Real-world**: Attackers often target service accounts for privilege escalation

### 3. Suspicious Account Naming Patterns
- **Pattern**: Accounts with suspicious naming conventions
- **Detection**: Names containing "admin", "administrator", "test", "guest", "temp", "demo", "backup", "service"
- **IoCCategory**: `Reconnaissance`
- **Risk**: Potential reconnaissance or test accounts
- **Response**: Verify account creation legitimacy and intended use
- **Real-world**: Attackers create test accounts to validate access

### 4. High Failed Password Attempts
- **Pattern**: Accounts with 8+ failed password attempts but not locked
- **Detection**: High failed attempts without account lockout
- **IoCCategory**: `Other`
- **Risk**: Potential brute force attacks or credential stuffing
- **Response**: Immediate account lockdown and investigation
- **Real-world**: Common in credential stuffing attacks

---

## 🟡 HIGH RISKS (24-hour Response)

### 1. Suspicious Authentication Patterns
- **Pattern**: Failed logon attempts followed by successful logon
- **Detection**: 3+ failed attempts with successful logon within 1 day
- **IoCCategory**: `SuspiciousAuth`
- **Risk**: Potential credential guessing or brute force attacks
- **Response**: Investigate authentication source and legitimacy
- **Real-world**: Common pattern in credential harvesting attacks

### 2. Service Account Off-Hours Activity
- **Pattern**: Service accounts logging in during non-business hours
- **Detection**: Service accounts active between 6 PM - 6 AM
- **IoCCategory**: `ServiceAccountAbuse`
- **Risk**: Potential unauthorized service account usage
- **Response**: Verify service account activity legitimacy
- **Real-world**: Attackers often use service accounts during off-hours

### 3. Lateral Movement Indicators
- **Pattern**: High-activity accounts with recent logon activity
- **Detection**: Accounts with 500+ logons and recent activity (≤7 days)
- **IoCCategory**: `LateralMovement`
- **Risk**: Potential lateral movement or account abuse
- **Response**: Investigate account usage patterns and access legitimacy
- **Real-world**: Attackers use high-activity accounts to move through the network

### 4. Data Exfiltration Pattern
- **Pattern**: Data analyst accounts with excessive logon activity
- **Detection**: 1000+ logon count, recent activity
- **IoCCategory**: `LateralMovement`
- **Response**: Immediate investigation of data access patterns
- **Real-world**: Common in data theft incidents

---

## 🟣 MEDIUM RISKS (1-week Response)

### 1. Reconnaissance Indicators
- **Pattern**: New accounts with suspicious naming patterns
- **Detection**: Accounts created within 7 days with suspicious names
- **IoCCategory**: `Reconnaissance`
- **Suspicious Patterns**: "test", "admin", "user", "guest", "temp", "demo"
- **Risk**: Potential reconnaissance or test accounts
- **Response**: Verify account creation legitimacy
- **Real-world**: Attackers create test accounts to validate access

### 2. Insider Threat Indicators
- **Pattern**: Administrative roles in non-IT departments
- **Detection**: Admin titles in non-IT/Engineering departments
- **IoCCategory**: `InsiderThreat`
- **Risk**: Potential privilege escalation or role abuse
- **Response**: Review role assignments and access requirements
- **Real-world**: Common indicator of privilege abuse

### 3. Credential Dumping Indicators
- **Pattern**: High-activity accounts with failed password attempts
- **Detection**: Accounts with 200+ logons and 2+ failed attempts
- **IoCCategory**: `CredentialDumping`
- **Risk**: Potential credential harvesting or brute force attacks
- **Response**: Investigate authentication patterns and account security
- **Real-world**: Attackers target high-activity accounts for credential extraction

### 4. Account Manipulation Indicators
- **Pattern**: Recently modified account attributes
- **Detection**: Accounts modified within 3 days
- **IoCCategory**: `AccountManipulation`
- **Risk**: Potential unauthorized account changes
- **Response**: Review account modification history and legitimacy
- **Real-world**: Attackers modify accounts to maintain persistence

### 5. Phishing Victim Pattern
- **Pattern**: Accounts with recent failed password attempts
- **Detection**: 4+ failed attempts, recent activity
- **IoCCategory**: `CredentialDumping`
- **Response**: Investigation within 1 week
- **Real-world**: Potential phishing attack victim

---

## 📊 Database Statistics & Risk Distribution

### Current Risk Distribution
- **Total Users**: 150
- **Safe Users**: 36 (24%)
- **Risky Users**: 114 (76%)
- **Critical Risks**: 14 accounts
- **High Risks**: 40 accounts
- **Medium Risks**: 59 accounts
- **Low Risks**: 0 accounts

### Department Risk Analysis
- **IT**: 30 accounts (highest risk concentration)
- **Sales**: 17 accounts
- **Finance**: 15 accounts
- **Marketing**: 14 accounts
- **HR**: 11 accounts
- **Security**: 9 accounts
- **Accounting**: 7 accounts
- **Legal**: 5 accounts
- **Engineering**: 3 accounts
- **Operations**: 2 accounts

### IoC Detection Summary
- **Privilege Escalation**: 4 indicators
- **Suspicious Authentication**: 11 patterns
- **Service Account Abuse**: 0 instances
- **Lateral Movement**: 29 indicators
- **Reconnaissance**: 0 indicators
- **Credential Dumping**: 22 indicators
- **Account Manipulation**: 18 indicators
- **Insider Threat**: 7 indicators

---

## 🛠️ Implementation & Usage

### Database Generation
```powershell
# Generate 150 users with cybersecurity scenarios
.\Scripts\Create-150UserDatabase.ps1
```

### Enhanced Security Report
```powershell
# Run with enhanced IoC detection
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection

# Export to CSV with IoC categories
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection -ExportCSV "Reports\SecurityReport.csv"
```

### IoC Category Analysis
```powershell
# Filter by specific IoC category
Import-Csv "Reports\SecurityReport.csv" | Where-Object { $_.IoCCategory -eq "PrivilegeEscalation" }

# Group by IoC category
Import-Csv "Reports\SecurityReport.csv" | Group-Object IoCCategory | Sort-Object Count -Descending
```

---

## 🚨 Incident Response Procedures

### Critical Risks (Immediate)
1. **Isolate affected accounts** if compromise is confirmed
2. **Reset passwords** for all affected accounts
3. **Review recent activity** for lateral movement
4. **Update security controls** to prevent recurrence
5. **Notify incident response team** immediately

### High Risks (24 hours)
1. **Investigate authentication patterns**
2. **Review service account usage**
3. **Monitor for additional indicators**
4. **Implement additional logging**
5. **Document findings** for audit trail

### Medium Risks (1 week)
1. **Review role assignments**
2. **Verify account creation legitimacy**
3. **Update access policies**
4. **Implement monitoring controls**
5. **Schedule follow-up review**

---

## 🔧 Customization & Configuration

### Adding New Scenarios
```powershell
# Database generation scenarios
@{ 
    Type = "CRITICAL|HIGH|MEDIUM|LOW"
    Name = "Scenario Name"
    Count = 5
    BadPasswordCount = 6
    LogonCount = 200
    Title = "Specific Title"
    Department = "Specific Department"
}

# IoC detection patterns
# Add to detection logic in Get-SecurityReport.ps1
```

### Modifying Detection Thresholds
- **Password Age**: Modify `$PasswordAgeDays` parameter
- **Inactive Days**: Modify `$InactiveDays` parameter
- **Suspicious Patterns**: Update `$SuspiciousPatterns` array
- **Time Windows**: Adjust hour ranges for off-hours detection
- **Risk Percentage**: Adjust `$RiskPercentage` in database generation

---

## 📈 Advanced Analysis Examples

### Privilege Escalation Analysis
```powershell
$Report = Import-Csv "Reports\SecurityReport.csv"
$Report | Where-Object { $_.IoCCategory -eq "PrivilegeEscalation" } | 
    Select-Object SamAccountName, DisplayName, Department, Reason, IoCCategory
```

### Lateral Movement Detection
```powershell
$Report | Where-Object { $_.IoCCategory -eq "LateralMovement" } | 
    Group-Object Department | Sort-Object Count -Descending
```

### Insider Threat Analysis
```powershell
$Report | Where-Object { $_.IoCCategory -eq "InsiderThreat" } | 
    Select-Object SamAccountName, Department, Title, Reason
```

### Credential Dumping Investigation
```powershell
$Report | Where-Object { $_.IoCCategory -eq "CredentialDumping" } | 
    Sort-Object BadPasswordCount -Descending | 
    Select-Object SamAccountName, BadPasswordCount, LogonCount, Reason
```

---

## 🔮 Future Enhancements

### Advanced Detection Patterns
1. **Golden Ticket Detection**: Kerberos tickets older than 10 hours
2. **Advanced Lateral Movement**: Accounts accessing multiple systems rapidly
3. **Credential Dumping**: Multiple failed attempts from same IP
4. **Data Exfiltration**: High-volume data access patterns
5. **Account Manipulation**: Recently modified account attributes

### Machine Learning Integration
- **Behavioral analysis** capabilities
- **AI-driven anomaly detection**
- **Predictive threat modeling**
- **Automated response procedures**

### Threat Intelligence Integration
- **Threat feed integration**
- **IoC correlation** with external sources
- **Real-time threat updates**
- **Automated threat hunting**

---

## 📋 Best Practices

### 1. Regular Monitoring
- Run IoC detection **daily** for critical environments
- Run IoC detection **weekly** for standard environments
- **Review and tune** detection thresholds regularly
- **Document findings** for continuous improvement

### 2. False Positive Management
- **Whitelist legitimate patterns** (e.g., scheduled service accounts)
- **Adjust thresholds** based on environment characteristics
- **Document exceptions** for audit purposes
- **Regular review** of detection effectiveness

### 3. Response Automation
- **Automate critical IoC responses** where possible
- **Create playbooks** for each IoC type
- **Integrate with incident response** workflows
- **Implement automated containment** procedures

### 4. Continuous Improvement
- **Track IoC effectiveness** over time
- **Update detection patterns** based on new threats
- **Share findings** with security community
- **Regular training** for security teams

---

## 🎯 Conclusion

This comprehensive guide provides:

1. **Realistic cybersecurity scenarios** for testing environments
2. **Advanced IoC detection** for production environments
3. **Clear response procedures** for each threat type
4. **Customizable detection** capabilities
5. **Integration-ready** export formats

By implementing these patterns, organizations can:
- **Detect threats earlier** in the attack lifecycle
- **Reduce false positives** through targeted detection
- **Improve response times** with prioritized alerts
- **Enhance security posture** through proactive monitoring

Regular review and tuning of these patterns ensures they remain effective against evolving threats while minimizing operational overhead. 