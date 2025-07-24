# Export Guide for Security Reports

## Overview

The CSVActiveDirectory module supports multiple export formats for security reports and IoC detection results:

1. **CSV Export** - For data analysis and SIEM integration
2. **HTML Export** - For professional reporting and stakeholder presentations

This guide covers both export formats and their use cases.

## Export Formats

### CSV Export (Data Analysis)
**Script**: `Get-SecurityReport.ps1`

#### Default Export (Recommended)
```powershell
-EnhancedIoCDetection
```
**Default Location**: `%USERPROFILE%\Documents\ADSecurityReport\ADRiskAssessmentYYYYMMDD-HHMMSS.csv`

#### Custom Export Path
```powershell
-ExportCSV "path\to\filename.csv"
```

#### Complete Export with Enhanced IoC Detection
```powershell
-EnhancedIoCDetection -ExportCSV "path\to\filename.csv"
```

### HTML Export (Professional Reports)
**Script**: `Get-IOCs.ps1`

#### Basic HTML Report
```powershell
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport
```
**Default Location**: `%USERPROFILE%\Documents\IoCReports\IoC_username_YYYYMMDD-HHMMSS.html`

#### Custom Export Path
```powershell
.\Scripts\Get-IOCs.ps1 -Username "username" -ExportReport -ExportPath "Reports"
```

#### Professional Report Example
```powershell
.\Scripts\Get-IOCs.ps1 -Username "suspicious_user" -ExportReport -ExportPath "SecurityReports"
```

## Export Examples

### CSV Export Examples

#### 1. Default Export (Recommended)
```powershell
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection
```
**Automatically saves to**: `%USERPROFILE%\Documents\ADSecurityReport\ADRiskAssessmentYYYYMMDD-HHMMSS.csv`

#### 2. Custom Path Export
```powershell
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection -ExportCSV "Reports\SecurityReport_IoC.csv"
```

#### 3. Timestamped Export
```powershell
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection -ExportCSV "Reports\SecurityReport_$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
```

#### 4. Custom Parameters with Export
```powershell
.\Scripts\Get-SecurityReport.ps1 -EnhancedIoCDetection -InactiveDays 60 -PasswordAgeDays 45 -ExportCSV "Reports\CustomSecurityReport.csv"
```

### HTML Export Examples

#### 1. Basic HTML Report
```powershell
.\Scripts\Get-IOCs.ps1 -Username "jmorales" -ExportReport
```
**Generates**: Professional HTML report with detailed IoC analysis

#### 2. Custom Directory Export
```powershell
.\Scripts\Get-IOCs.ps1 -Username "suspicious_user" -ExportReport -ExportPath "SecurityReports"
```

#### 3. Incident Response Report
```powershell
.\Scripts\Get-IOCs.ps1 -Username "compromised_account" -ExportReport -ExportPath "IncidentResponse\Reports"
```

#### 4. Management Presentation
```powershell
.\Scripts\Get-IOCs.ps1 -Username "high_risk_user" -ExportReport -ExportPath "Management\Presentations"
```

## Export Features

### CSV Export Features

#### Automatic Directory Creation
- Creates `%USERPROFILE%\Documents\ADSecurityReport\` directory if it doesn't exist
- No manual setup required

#### Clear Export Messaging
The script provides detailed feedback during export:
```
=== EXPORTING SECURITY REPORT ===
Creating directory: C:\Users\username\Documents\ADSecurityReport
Exporting report to CSV...

✅ SECURITY REPORT EXPORTED SUCCESSFULLY
📁 Location: C:\Users\username\Documents\ADSecurityReport\ADRiskAssessment20250722-174024.csv
📊 Total Records: 113
📈 Risk Breakdown:
   • Critical Risks: 14
   • High Risks: 40
   • Medium Risks: 59
   • Low Risks: 0
📋 Summary Report: C:\Users\username\Documents\ADSecurityReport\ADRiskAssessment20250722-174024_Summary.csv
```

### HTML Export Features

#### Professional Design
- **Modern styling** with gradient headers and professional typography
- **Color-coded severity levels** (Red=Critical, Orange=High, Yellow=Medium, Blue=Low)
- **Responsive layout** for different screen sizes
- **Self-contained HTML** with embedded CSS

#### Report Sections
1. **User Information** - Grid layout with account details
2. **Overall Assessment** - Summary statistics with visual indicators
3. **IoC Detections** - Detailed threat analysis with individual indicators
4. **Recommended Response** - Prioritized action items

#### Export Messaging
```
✅ IoC Report exported successfully!
📁 Location: test\IoC_jmorales_20250722-212310.html

📊 Report Summary:
   • Total IoC Detections: 1
   • Critical Detections: 0
   • High Detections: 6
   • Medium Detections: 0
```

## Export Files Generated

### CSV Export Files

#### 1. Main Security Report CSV
**File**: `SecurityReport_YYYYMMDD-HHMMSS.csv`

**Columns**:
- `RiskLevel` - CRITICAL, HIGH, MEDIUM, LOW
- `SamAccountName` - User account name
- `DisplayName` - Full display name
- `Department` - User department
- `Title` - User job title
- `Reason` - Specific risk reason
- `Details` - Detailed description of the risk
- `Enabled` - Account enabled status
- `LastLogon` - Last logon timestamp
- `PasswordLastSet` - Password last set timestamp
- `LogonCount` - Number of logons
- `BadPasswordCount` - Failed password attempts
- `LockoutTime` - Account lockout timestamp
- `Created` - Account creation date
- `Modified` - Account modification date
- `ScanTime` - Report generation timestamp
- `IoCDetection` - Enhanced or Standard detection
- `IoCCategory` - Specific IoC category (Enhanced detection only)

#### 2. Summary Report CSV (Enhanced IoC Only)
**File**: `SecurityReport_YYYYMMDD-HHMMSS_Summary.csv`

**Columns**:

### HTML Export Files

#### 1. IoC Analysis Report HTML
**File**: `IoC_username_YYYYMMDD-HHMMSS.html`

**Features**:
- **Self-contained HTML** with embedded CSS
- **Professional styling** with gradient headers
- **Color-coded severity indicators**
- **Responsive design** for different screen sizes
- **Detailed threat analysis** with individual indicators
- **Actionable recommendations** with priority levels

**File Naming Convention**:
```
IoC_username_YYYYMMDD-HHMMSS.html
```
Example: `IoC_jmorales_20250722-212310.html`

**Report Sections**:
1. **User Information** - Account details in organized grid
2. **Overall Assessment** - Summary statistics with visual indicators
3. **IoC Detections** - Detailed threat analysis with attack types
4. **Recommended Response** - Prioritized action items
- `Category` - IoC Detection, Risk Summary, Statistics
- `Type` - Specific detection type or metric
- `Count` - Number of occurrences
- `RiskLevel` - Risk level or N/A
- `Description` - Description of the metric

## CSV Structure Examples

### Main Report CSV Sample
```csv
"RiskLevel","SamAccountName","DisplayName","Department","Title","Reason","Details","Enabled","LastLogon","PasswordLastSet","LogonCount","BadPasswordCount","LockoutTime","Created","Modified","ScanTime","IoCDetection","IoCCategory"
"CRITICAL","cclark","Christine Clark","IT","Domain Admin","High Failed Password Attempts","Account has 8 failed password attempts but is not locked","TRUE","7/21/2025 5:13 PM","6/24/2025 5:13 PM","706","8","",,,"7/22/2025 5:35:59 PM","Enhanced","Other"
"HIGH","cclark","Christine Clark","IT","Domain Admin","High Activity Recent Logon","High-activity account (706 logons) with recent activity","TRUE","7/21/2025 5:13 PM","6/24/2025 5:13 PM","706","8","",,,"7/22/2025 5:35:59 PM","Enhanced","LateralMovement"
"MEDIUM","mroberts","Martha Roberts","IT","Domain Admin","Unusual Activity Pattern","High-activity account with failed password attempts","TRUE","7/16/2025 5:13 PM","7/19/2025 5:13 PM","259","8","",,,"7/22/2025 5:35:59 PM","Enhanced","CredentialDumping"
```

### IoC Categories Explained

The `IoCCategory` column provides specific categorization for each risk:

#### **🔴 CRITICAL RISKS**
- **PrivilegeEscalation** - Privileged account password changes, service accounts with admin rights
- **Reconnaissance** - Suspicious account naming patterns
- **Other** - Standard critical risks (failed password attempts, etc.)

#### **🟡 HIGH RISKS**
- **SuspiciousAuth** - Failed attempts followed by successful logon
- **ServiceAccountAbuse** - Service accounts active during off-hours
- **LateralMovement** - High-activity accounts with recent logons
- **Other** - Standard high risks

#### **🟣 MEDIUM RISKS**
- **Reconnaissance** - New accounts with suspicious naming patterns
- **InsiderThreat** - Administrative roles in non-IT departments
- **CredentialDumping** - High-activity accounts with failed attempts
- **AccountManipulation** - Recently modified account attributes
- **Other** - Standard medium risks

### Summary Report CSV Sample
```csv
"Category","Type","Count","RiskLevel","Description"
"IoC Detection","PrivilegeEscalation","4","N/A","Enhanced IoC detection pattern"
"IoC Detection","SuspiciousAuth","11","N/A","Enhanced IoC detection pattern"
"IoC Detection","LateralMovement","29","N/A","Enhanced IoC detection pattern"
"Risk Summary","Critical Risks","14","CRITICAL","Immediate action required"
"Risk Summary","High Risks","40","HIGH","Investigate within 24 hours"
"Statistics","Total Users","150","N/A","Total users scanned"
```

## Use Cases

### 1. Security Analysis
- Import CSV into Excel for detailed analysis
- Filter by risk level, department, or specific IoC types
- Create pivot tables for trend analysis
- Generate charts and graphs for reporting

### 2. SIEM Integration
- Import CSV data into SIEM systems
- Create custom dashboards
- Set up automated alerts based on CSV data
- Correlate with other security events

### 3. Compliance Reporting
- Generate monthly security reports
- Track risk trends over time
- Document security findings for audits
- Create executive summaries

### 4. Incident Response
- Export specific risk levels for investigation
- Filter by department or user type
- Track remediation progress
- Document incident details

## Excel Analysis Tips

### 1. Import and Format
```powershell
# Import CSV into Excel
Import-Csv "Reports\SecurityReport.csv" | Export-Excel -Path "SecurityAnalysis.xlsx"
```

### 2. Filter by Risk Level
```powershell
# Filter critical risks only
Import-Csv "Reports\SecurityReport.csv" | Where-Object { $_.RiskLevel -eq "CRITICAL" }
```

### 3. Department Analysis
```powershell
# Group by department
Import-Csv "Reports\SecurityReport.csv" | Group-Object Department | Sort-Object Count -Descending
```

### 4. IoC Analysis
```powershell
# Filter by IoC detection
Import-Csv "Reports\SecurityReport.csv" | Where-Object { $_.IoCDetection -eq "Enhanced" }

# Filter by specific IoC category
Import-Csv "Reports\SecurityReport.csv" | Where-Object { $_.IoCCategory -eq "PrivilegeEscalation" }

# Group by IoC category
Import-Csv "Reports\SecurityReport.csv" | Group-Object IoCCategory | Sort-Object Count -Descending
```

## PowerShell Analysis Examples

### 1. Risk Level Summary
```powershell
$Report = Import-Csv "Reports\SecurityReport.csv"
$Report | Group-Object RiskLevel | Format-Table Name, Count -AutoSize
```

### 2. Department Risk Analysis
```powershell
$Report = Import-Csv "Reports\SecurityReport.csv"
$Report | Group-Object Department | Sort-Object Count -Descending | Format-Table Name, Count -AutoSize
```

### 3. IoC Detection Summary
```powershell
$Report = Import-Csv "Reports\SecurityReport.csv"
$Report | Where-Object { $_.IoCDetection -eq "Enhanced" } | Group-Object Reason | Format-Table Name, Count -AutoSize

# IoC Category Analysis
$Report | Where-Object { $_.IoCCategory -ne "" } | Group-Object IoCCategory | Sort-Object Count -Descending | Format-Table Name, Count -AutoSize
```

### 4. High-Risk Account Analysis
```powershell
$Report = Import-Csv "Reports\SecurityReport.csv"
$Report | Where-Object { $_.RiskLevel -in @("CRITICAL", "HIGH") } | Select-Object SamAccountName, DisplayName, Department, Reason, Details

# Critical IoC Analysis
$Report | Where-Object { $_.IoCCategory -eq "PrivilegeEscalation" } | Select-Object SamAccountName, DisplayName, Department, Reason, IoCCategory
```

## Integration with Other Tools

### 1. Power BI
- Import CSV files into Power BI
- Create interactive dashboards
- Set up automatic refresh schedules
- Share reports with stakeholders

### 2. Tableau
- Connect CSV files to Tableau
- Create visualizations
- Build interactive dashboards
- Export to various formats

### 3. Splunk
- Import CSV data into Splunk
- Create custom dashboards
- Set up alerts and notifications
- Correlate with other data sources

### 4. ELK Stack
- Import CSV into Elasticsearch
- Create Kibana dashboards
- Set up Logstash pipelines
- Configure alerts

## Best Practices

### 1. File Naming
- Use descriptive names with timestamps
- Include risk level or IoC type in filename
- Organize files in appropriate directories
- Use consistent naming conventions

### 2. Data Retention
- Establish retention policies for CSV files
- Archive old reports appropriately
- Maintain audit trails
- Ensure data security

### 3. Automation
- Schedule regular exports
- Automate file cleanup
- Set up automated analysis
- Create automated alerts

### 4. Documentation
- Document export procedures
- Maintain analysis templates
- Create standard reports
- Update procedures regularly

## Troubleshooting

### Common Issues

1. **File Not Found**
   - Ensure directory exists
   - Check file permissions
   - Verify path is correct

2. **Encoding Issues**
   - Use UTF8 encoding
   - Check for special characters
   - Verify CSV format

3. **Large File Sizes**
   - Filter data before export
   - Use compression if needed
   - Consider splitting exports

4. **Performance Issues**
   - Optimize export parameters
   - Use appropriate file locations
   - Consider batch processing

## Conclusion

CSV export functionality provides powerful capabilities for:
- **Data Analysis**: Import into Excel, Power BI, or other tools
- **Reporting**: Generate custom reports and dashboards
- **Integration**: Connect with SIEM and other security tools
- **Compliance**: Document security findings and trends
- **Automation**: Set up automated analysis and alerting

The export feature enhances the security reporting capabilities by making the data easily accessible for further analysis and integration with existing security tools and processes. 