# Cybersecurity and Incident Response Scenarios

This document outlines the enhanced cybersecurity scenarios implemented in the `Create-150UserDatabase.ps1` script for Active Directory user account risk assessment.

## Overview

The enhanced database generation script creates 150 users with approximately 30% risky users, incorporating real-world cybersecurity and incident response patterns commonly seen in enterprise environments.

## Critical Risk Scenarios

### 1. Privileged Account Compromise
- **Pattern**: Domain Admin accounts with high failed password attempts
- **Indicators**: 8+ failed password attempts, no lockout
- **Response**: Immediate investigation and account lockdown
- **Real-world**: Common in credential stuffing attacks

### 2. Service Account Abuse
- **Pattern**: Service accounts (svc_*) that are enabled but never used
- **Indicators**: Enabled service accounts with 0 logon count
- **Response**: Immediate disablement and investigation
- **Real-world**: Attackers often target service accounts for persistence

### 3. Lateral Movement Indicator
- **Pattern**: High logon activity across multiple systems
- **Indicators**: 500+ logon count with recent activity
- **Response**: Immediate containment and investigation
- **Real-world**: Indicates potential lateral movement in network

### 4. Data Exfiltration Pattern
- **Pattern**: Data analyst accounts with excessive logon activity
- **Indicators**: 1000+ logon count, recent activity
- **Response**: Immediate investigation of data access patterns
- **Real-world**: Common in data theft incidents

## High Risk Scenarios

### 1. Privilege Escalation Attempt
- **Pattern**: Junior admin accounts with multiple failed password attempts
- **Indicators**: 6+ failed attempts, no lockout
- **Response**: Investigation within 24 hours
- **Real-world**: Attackers attempting to gain elevated privileges

### 2. Suspicious Login Pattern
- **Pattern**: After-hours login activity
- **Indicators**: Recent logins during non-business hours
- **Response**: Investigation within 24 hours
- **Real-world**: Potential unauthorized access

### 3. Account Sharing Detection
- **Pattern**: Shared accounts with excessive logon activity
- **Indicators**: 800+ logon count, no failed attempts
- **Response**: Investigation within 24 hours
- **Real-world**: Violation of security policies

### 4. Old Password - Critical Role
- **Pattern**: Security managers with old passwords
- **Indicators**: 300+ days since password change
- **Response**: Investigation within 24 hours
- **Real-world**: High-risk accounts with outdated credentials

### 5. Inactive Privileged Account
- **Pattern**: Senior admin accounts with no recent activity
- **Indicators**: 180+ days inactive, still enabled
- **Response**: Investigation within 24 hours
- **Real-world**: Potential dormant attack vectors

## Medium Risk Scenarios

### 1. Credential Dumping Target
- **Pattern**: Help desk accounts with moderate activity
- **Indicators**: 50+ logon count, 2+ failed attempts
- **Response**: Investigation within 1 week
- **Real-world**: Common target for credential harvesting

### 2. Phishing Victim Pattern
- **Pattern**: Accounts with recent failed password attempts
- **Indicators**: 4+ failed attempts, recent activity
- **Response**: Investigation within 1 week
- **Real-world**: Potential phishing attack victim

### 3. Insider Threat Indicator
- **Pattern**: Finance analyst accounts with high activity
- **Indicators**: 300+ logon count, no failed attempts
- **Response**: Investigation within 1 week
- **Real-world**: Potential insider threat activity

### 4. Account Reconnaissance
- **Pattern**: New employee accounts with minimal activity
- **Indicators**: 10+ logon count, 1 failed attempt
- **Response**: Investigation within 1 week
- **Real-world**: Attackers testing account access

### 5. Malware Infection Pattern
- **Pattern**: Accounts with moderate activity and recent logins
- **Indicators**: 150+ logon count, recent activity
- **Response**: Investigation within 1 week
- **Real-world**: Potential malware-infected accounts

## Low Risk Scenarios

### 1. Weak Password Policy
- **Pattern**: Regular users with failed password attempts
- **Indicators**: 1 failed attempt, regular user role
- **Response**: Monitor quarterly
- **Real-world**: Weak password practices

### 2. Unusual Login Time
- **Pattern**: Weekend or after-hours login activity
- **Indicators**: 20+ logon count, unusual timing
- **Response**: Monitor quarterly
- **Real-world**: Potential unauthorized access

### 3. Department Mismatch
- **Pattern**: IT admin accounts in non-IT departments
- **Indicators**: Role/department mismatch
- **Response**: Monitor quarterly
- **Real-world**: Potential privilege escalation

## Incident Response Integration

### Detection Capabilities
- **Real-time monitoring**: Failed password attempts, lockouts
- **Behavioral analysis**: Unusual login patterns, activity spikes
- **Privilege monitoring**: Elevated access patterns
- **Temporal analysis**: After-hours activity detection

### Response Procedures
1. **Critical risks**: Immediate containment and investigation
2. **High risks**: 24-hour response window
3. **Medium risks**: 1-week investigation timeline
4. **Low risks**: Quarterly monitoring and review

### Investigation Workflows
- **Account analysis**: Review login history and patterns
- **Network forensics**: Correlate with network logs
- **User interviews**: Validate legitimate activity
- **Remediation**: Account lockdown, password resets, access reviews

## Database Statistics

### Risk Distribution
- **Total Users**: 150
- **Safe Users**: 105 (70%)
- **Risky Users**: 45 (30%)
- **Critical Risks**: 14 accounts (Privilege escalation, Service account abuse, Suspicious naming)
- **High Risks**: 40 accounts (Suspicious auth patterns, Off-hours activity, Lateral movement)
- **Medium Risks**: 59 accounts (Reconnaissance, Insider threats, Credential dumping, Account manipulation)
- **Low Risks**: 14 accounts (Weak passwords, Department mismatches, Unusual login times)

### Department Distribution
- **IT**: 31 accounts (highest risk)
- **HR**: 19 accounts
- **Finance**: 15 accounts
- **Legal**: 13 accounts
- **Sales**: 13 accounts
- **Security**: 13 accounts
- **Operations**: 12 accounts
- **Accounting**: 10 accounts
- **Marketing**: 10 accounts
- **Engineering**: 7 accounts

## Usage Instructions

1. **Run the script**: `.\Scripts\Create-150UserDatabase.ps1`
2. **Review the output**: Check risk statistics and recommendations
3. **Test with security tools**: Use `Get-SecurityReport.ps1`
4. **Analyze patterns**: Review the generated risk scenarios
5. **Customize scenarios**: Modify the `$RiskScenarios` array as needed

## Customization

### Adding New Scenarios
```powershell
@{ 
    Type = "CRITICAL|HIGH|MEDIUM|LOW"
    Name = "Scenario Name"
    Count = 5
    BadPasswordCount = 6
    LogonCount = 200
    Title = "Specific Title"
    Department = "Specific Department"
}
```

### Modifying Risk Thresholds
- Adjust `$RiskPercentage` parameter
- Modify detection logic in risk calculation section
- Update scenario counts in `$RiskScenarios` array

## Security Considerations

- **Data privacy**: Generated data is fictional and for testing only
- **Environment isolation**: Use in controlled testing environments
- **Access controls**: Limit access to security testing personnel
- **Documentation**: Maintain records of all testing scenarios

## Future Enhancements

- **Machine learning patterns**: Add AI-driven anomaly detection
- **Threat intelligence**: Integrate with threat feeds
- **Automated response**: Implement automated containment procedures
- **Advanced analytics**: Add behavioral analysis capabilities 