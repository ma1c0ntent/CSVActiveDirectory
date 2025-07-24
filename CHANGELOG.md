# Changelog

All notable changes to the CSVActiveDirectory module will be documented in this file.

## [1.3.0] - 2025-07-23

### Fixed
- **Install Script Bug**: Fixed `-SkipSecurityTest` parameter not working correctly in `install.ps1`
  - Added `-SkipSecurityTest` parameter to `Create-Users.ps1` script
  - Implemented proper parameter splatting for reliable parameter passing between scripts
  - Fixed switch parameter handling to prevent security report from running when skipped
  - Added conditional logic to respect the skip parameter in database creation process

### Added
- **PowerShell 5.1 & 7+ Compatibility**: Comprehensive emoji support across PowerShell versions
  - **Modern Unicode Emoji Method**: Implemented `[char]::ConvertFromUtf32()` for reliable emoji display
  - **Centralized Emoji Function**: `Get-Emoji` function provides consistent emoji display across versions
  - **Automatic Version Detection**: Scripts automatically detect PowerShell version and use appropriate emoji method
  - **ASCII Fallbacks**: Graceful fallback to ASCII alternatives when Unicode emojis aren't supported
  - **Updated All Scripts**: All scripts now use centralized emoji function instead of hardcoded Unicode

### Enhanced
- **Get-IOCs HTML Report**: Major enhancements to HTML report functionality
  - **Clickable IoC Items**: Individual IoC indicators are now clickable to reveal detailed breakdowns
  - **Collapsible Categories**: IoC category cards can be expanded/collapsed with smooth animations
  - **Detailed Log Breakdowns**: Click on individual indicators to see logs explaining why each is flagged as an IoC
  - **Enhanced JavaScript**: Smooth expand/collapse animations with proper event handling
  - **Improved CSS Grid Layout**: All user info cards now display in a single row for better layout
  - **Confidence Level Fix**: Capped confidence increments at 100% to prevent unrealistic values
  - **Better User Experience**: Default collapsed state with quick summaries and smooth transitions

### Technical Improvements
- **Emoji Compatibility**: All scripts updated to use `Get-Emoji` function for consistent display
  - Updated: `install.ps1`, `Get-IOCs.ps1`, `Get-SecurityReport.ps1`, `Create-Users.ps1`, `Queries.ps1`, `Show-ADStatus.ps1`
  - Replaced hardcoded Unicode emojis with function calls
  - Added bullet point support with ASCII dash alternatives for PowerShell 5.1
- **Parameter Passing**: Improved reliability of switch parameter passing between scripts
- **Error Handling**: Enhanced compatibility with PowerShell 5.1 syntax (replaced null coalescing operator `??`)
- **Performance**: Fixed `Measure-Object` property errors in PowerShell 5.1

### Documentation
- **Updated Installation Guide**: Clarified `-SkipSecurityTest` parameter usage
- **Enhanced Examples**: Updated demo scripts to show emoji compatibility
- **Improved User Feedback**: Clear messages when skipping operations

## [1.2.0] - 2025-07-22

### Added
- **Professional HTML Reports**: New HTML export functionality for IoC analysis reports
- **Enhanced IoC Analysis**: Individual user threat analysis with detailed detection patterns
- **Modern UI Design**: Professional styling with gradient headers and color-coded severity levels
- **Responsive Layout**: HTML reports work on different screen sizes and devices
- **Detailed Threat Analysis**: Comprehensive IoC detection with individual indicators and attack types
- **Actionable Recommendations**: Prioritized response actions based on threat severity
- **Setup Documentation**: Comprehensive setup guide in Docs/SETUP.md emphasizing user creation requirement after cloning
- **Installation Warnings**: Clear messaging about database population requirement in install.ps1

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