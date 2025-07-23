# Changelog

All notable changes to the CSVActiveDirectory module will be documented in this file.

## [1.2.0] - 2025-07-22

### Added
- **Professional HTML Reports**: New HTML export functionality for IoC analysis reports
- **Enhanced IoC Analysis**: Individual user threat analysis with detailed detection patterns
- **Modern UI Design**: Professional styling with gradient headers and color-coded severity levels
- **Responsive Layout**: HTML reports work on different screen sizes and devices
- **Detailed Threat Analysis**: Comprehensive IoC detection with individual indicators and attack types
- **Actionable Recommendations**: Prioritized response actions based on threat severity
- **Setup Documentation**: Comprehensive setup guide in Docs/SETUP.md emphasizing user creation requirement after cloning
- **Installation Warnings**: Clear messaging about database population requirement in INSTALL.ps1

### Features
- **HTML Report Generation**: Professional reports suitable for management presentations
- **Color-Coded Severity**: Visual indicators for Critical (Red), High (Orange), Medium (Yellow), Low (Blue) risks
- **Comprehensive IoC Detection**: 8 different threat categories with detailed analysis
- **User-Friendly Interface**: Clear account status display (Enabled/Disabled instead of TRUE/FALSE)
- **Self-Contained Reports**: HTML files with embedded CSS for easy sharing
- **Professional Typography**: Modern fonts and styling for executive presentations

### Technical Improvements
- **Enhanced Export Function**: Replaced CSV export with professional HTML reports
- **Improved User Experience**: Clear, human-readable labels and organized sections
- **Better Documentation**: Comprehensive guides for IoC analysis and HTML reporting
- **Streamlined Reports**: Removed accuracy assessment section for more focused content

## [1.1.0] - 2025-07-22

### Added
- **Queries.ps1**: New comprehensive security analysis script with 22 individual query functions
- **Individual Security Queries**: Each query function can be highlighted and run independently
- **Risk-Based Categorization**: 8 Critical, 7 High, and 7 Medium risk query functions
- **Enhanced IoC Detection**: Advanced Indicators of Compromise detection patterns
- **Focused Analysis**: Mini reports for specific security issues
- **Comprehensive Coverage**: All query types from SecurityReport-Enterprise extracted into individual functions

### Features
- **Critical Risk Queries**: Locked but enabled accounts, high failed password attempts, never logged on accounts, unused service accounts, privileged account password changes, expired but enabled accounts, service accounts with admin privileges, suspicious account naming
- **High Risk Queries**: Inactive but enabled accounts, old passwords, high activity locked accounts, suspicious auth patterns, service account off-hours activity, high activity recent logons, accounts expiring soon
- **Medium Risk Queries**: Recently active disabled accounts, moderate failed password attempts, new accounts no activity, new suspicious accounts, role-department mismatches, unusual activity patterns, recently modified accounts
- **Utility Functions**: Invoke-AllQueries for comprehensive analysis, Get-AllUsers for cached performance, Show-QueryResults for consistent formatting
- **Easy Execution**: Commented function calls for quick highlighting and F8 execution

### Technical Improvements
- **Modular Design**: Each query function is self-contained with detailed documentation
- **Performance Optimization**: Cached user retrieval for faster execution
- **Consistent Output**: Standardized result display with color-coded risk levels
- **Professional Structure**: PowerShell help documentation for all functions

## [1.0.0] - 2025-01-14

### Added
- Initial release of CSVActiveDirectory module
- Core AD simulation functions (Get-ADUser, New-ADUser, Remove-ADUser, Enable-ADAccount, Disable-ADAccount)
- JSON-based configuration management
- Password management with complexity validation
- Progress indicators and status messages
- Custom format files for enhanced display
- Bulk operations support
- Professional folder structure with Public/Private function separation

### Features
- **Configuration Management**: JSON-based settings with domain, password policy, and validation rules
- **Password Security**: SHA256 hashing with salt, complexity validation, and policy enforcement
- **Progress Tracking**: Professional progress indicators for long-running operations
- **Status Messages**: Color-coded status messages with icons
- **Enhanced Display**: Custom format files for better user output
- **Bulk Operations**: Support for processing multiple items with error tracking

### Technical Improvements
- Modular function organization (Public/Private)
- Comprehensive error handling
- Input validation and sanitization
- Professional PowerShell module structure
- Extensive documentation and examples

## [0.9.0] - 2025-01-14

### Added
- Basic CSV-based AD simulation
- Core user management functions
- Simple database structure

### Changed
- Initial development version 