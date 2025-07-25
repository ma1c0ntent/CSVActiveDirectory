# Create-Users.ps1
# Generate a database of users with comprehensive cybersecurity risk scenarios
# Enhanced for incident response and security analysis
# Supports customizable user count with default of 150 users
# Ensures at least one user per IoC category for comprehensive testing

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\..\Data\Database\Database.csv",
    
    [Parameter(Mandatory=$false)]
    [int]$UserCount = 30,  # Increased minimum to accommodate all IoC categories
    
    [Parameter(Mandatory=$false)]
    [double]$RiskPercentage = 30.0,
    
    [Parameter(Mandatory=$false)]
    [switch]$BackupExisting = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipSecurityTest = $false
)

Write-Host "=== CREATING ENHANCED $UserCount-USER DATABASE ===" -ForegroundColor Cyan
Write-Host "Target Risk Percentage: $RiskPercentage%" -ForegroundColor Yellow
Write-Host "Enhanced with cybersecurity and incident response scenarios" -ForegroundColor Green
Write-Host "Ensuring at least one user per IoC category for comprehensive testing" -ForegroundColor Magenta
Write-Host ""

# Import required modules
try {
    Import-Module ..\..\CSVActiveDirectory.psd1 -Force
}
catch {
    Write-Error "Failed to import CSVActiveDirectory module"
    exit 1
}

# Import shared detection logic for consistent risk calculation
. "..\..\Functions\Private\Detect-UserIoCs.ps1"

# Initialize emoji variables for compatibility
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"
$InfoEmoji = Get-Emoji -Type "Info"
$SearchEmoji = Get-Emoji -Type "Search"
$TargetEmoji = Get-Emoji -Type "Target"
$LightningEmoji = Get-Emoji -Type "Lightning"
$BulbEmoji = Get-Emoji -Type "Bulb"

# Helper function to generate manager assignments
Function Get-ManagerAssignment {
    param(
        [string]$Department,
        [string]$Title,
        [array]$ExistingUsers
    )
    
    # Define department managers
    $DepartmentManagers = @{
        "IT" = @("mthomas", "jwilson", "rrodriguez")
        "Finance" = @("scooper", "jclark", "mallen")
        "HR" = @("rphillips", "ljenkins", "dnguyen")
        "Legal" = @("sjenkins", "lcook", "jmitchell")
        "Marketing" = @("scooper325", "ladams", "jclark")
        "Engineering" = @("enelson", "sbutler", "nlee")
        "Sales" = @("dcampbell", "mfoster", "gdiaz")
        "Accounting" = @("aanderson", "scox", "dhall")
        "Operations" = @("sbutler601", "jclark498", "nross")
        "Security" = @("ggreen", "awalker", "rhill")
    }
    
    # 80% chance of having a manager
    $random = Get-Random -Minimum 1 -Maximum 100
    if ($random -le 80) {
        # Get department managers for this department
        $managers = $DepartmentManagers[$Department]
        if ($managers -and $managers.Count -gt 0) {
            # Select a random manager from the department
            $selectedManager = $managers | Get-Random
            
            # Ensure the manager exists in the user list (or will exist)
            if ($ExistingUsers -or $selectedManager -in @("mthomas", "jwilson", "rrodriguez", "scooper", "jclark", "mallen", "rphillips", "ljenkins", "dnguyen", "sjenkins", "lcook", "jmitchell", "scooper325", "ladams", "enelson", "sbutler", "nlee", "dcampbell", "mfoster", "gdiaz", "aanderson", "scox", "dhall", "sbutler601", "jclark498", "nross", "ggreen", "awalker", "rhill")) {
                return $selectedManager
            }
        }
    }
    
    # 20% chance of no manager (or if no department managers available)
    return ""
}

# Backup existing database if requested
if ($BackupExisting -and (Test-Path "..\..\Data\Database\Database.csv")) {
    Write-Host "Creating backup using new single archive system..." -ForegroundColor Green
    
    # Import the backup function
    try {
        . $PSScriptRoot/Backup-Database.ps1
        
        # Create backup using the new system
        $BackupResult = Backup-Database -DatabasePath "..\..\Data\Database\Database.csv" -BackupFolder "..\..\Data\Database\Backups" -BackupArchiveName "DatabaseBackups.zip"
        
        if ($BackupResult) {
            Write-Host "Successfully created backup using single archive system" -ForegroundColor Green
        } else {
            Write-Host "Backup creation failed" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Could not create backup using new system: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Falling back to legacy backup method..." -ForegroundColor Yellow
        
        # Fallback to legacy method
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $BackupPath = "..\..\Data\Database\Database.backup.$timestamp.csv"
$ZipPath = "..\..\Data\Database\Database.backup.$timestamp.zip"
        
        # Create regular backup
        Copy-Item "..\..\Data\Database\Database.csv" $BackupPath
        Write-Host "Backed up existing database to: $BackupPath" -ForegroundColor Green
        
        # Create zipped backup
        try {
            Compress-Archive -Path $BackupPath -DestinationPath $ZipPath -Force
            Write-Host "Created zipped backup: $ZipPath" -ForegroundColor Green
            
            # Remove the unzipped backup file to save space
            Remove-Item $BackupPath -Force
            Write-Host "Removed unzipped backup file to save space" -ForegroundColor Yellow
        }
        catch {
            Write-Host "Could not create zipped backup (PowerShell version may not support Compress-Archive)" -ForegroundColor Yellow
            Write-Host "Keeping unzipped backup: $BackupPath" -ForegroundColor Yellow
        }
    }
}



# Sample data arrays
$FirstNames = @(
    "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", "William", "Elizabeth",
    "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Christopher", "Karen",
    "Charles", "Nancy", "Daniel", "Lisa", "Matthew", "Betty", "Anthony", "Helen", "Mark", "Sandra",
    "Donald", "Donna", "Steven", "Carol", "Paul", "Ruth", "Andrew", "Julie", "Joshua", "Joyce",
    "Kenneth", "Diane", "Kevin", "Virginia", "Brian", "Victoria", "George", "Kelly", "Edward", "Lauren",
    "Ronald", "Christine", "Timothy", "Joan", "Jason", "Evelyn", "Jeffrey", "Judith", "Ryan", "Megan",
    "Jacob", "Cheryl", "Gary", "Andrea", "Nicholas", "Hannah", "Eric", "Jacqueline", "Jonathan", "Martha",
    "Stephen", "Gloria", "Larry", "Teresa", "Justin", "Ann", "Scott", "Sara", "Brandon", "Jean",
    "Benjamin", "Alice", "Samuel", "Madison", "Frank", "Emma", "Gregory", "Julia", "Raymond", "Grace",
    "Alexander", "Judy", "Patrick", "Sophia", "Jack", "Isabella", "Dennis", "Olivia", "Jerry", "Ava",
    "Tyler", "Mia", "Aaron", "Emily", "Jose", "Abigail", "Adam", "Madison", "Nathan", "Charlotte",
    "Henry", "Harper", "Douglas", "Evelyn", "Peter", "Avery", "Zachary", "Sofia", "Kyle", "Elizabeth",
    "Walter", "Aria", "Ethan", "Scarlett", "Jeremy", "Victoria", "Harold", "Grace", "Carl", "Chloe",
    "Keith", "Camila", "Roger", "Penelope", "Gerald", "Layla", "Ethan", "Riley", "Mason", "Nora"
)

$LastNames = @(
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
    "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
    "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts",
    "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes",
    "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper",
    "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Torres",
    "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett",
    "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson",
    "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell"
)

$Titles = @(
    "Software Engineer", "Systems Administrator", "Network Engineer", "Security Analyst", "DevOps Engineer",
    "Database Administrator", "IT Manager", "System Analyst", "Technical Lead", "Cloud Engineer",
    "Cybersecurity Engineer", "Data Analyst", "Business Analyst", "Project Manager", "Product Manager",
    "Sales Representative", "Account Executive", "Sales Manager", "Marketing Specialist", "Digital Marketing Manager",
    "HR Specialist", "Recruiter", "HR Manager", "Benefits Coordinator", "Training Coordinator",
    "Financial Analyst", "Accountant", "Controller", "Treasury Analyst", "Investment Manager",
    "Legal Counsel", "Contract Manager", "Compliance Officer", "Risk Manager", "Legal Assistant",
    "Operations Manager", "Process Manager", "Business Development Manager", "Operations Analyst", "Supply Chain Manager"
)

$Departments = @(
    "IT", "Engineering", "Sales", "Marketing", "HR", "Finance", "Legal", "Operations", "Security", "Accounting"
)

$Buildings = @(
    "Building A, Floor 1", "Building A, Floor 2", "Building B, Floor 1", "Building B, Floor 2",
    "Building C, Floor 1", "Building C, Floor 2", "Building D, Floor 1", "Building D, Floor 2",
    "Building E, Floor 1", "Building E, Floor 2", "Building F, Floor 1", "Building F, Floor 2",
    "Building G, Floor 1", "Building G, Floor 2", "Building H, Floor 1", "Building H, Floor 2",
    "Building I, Floor 1", "Building I, Floor 2", "Building I, Floor 3", "Building J, Floor 1",
    "Building J, Floor 2", "Building K, Floor 1", "Building K, Floor 2", "Building L, Floor 1"
)

# Define all IoC categories that need at least one representative
$IoCCategories = @(
    "PrivilegeEscalation",      # For testing elevated privileges
    "AccountAnomaly",           # For testing suspicious account behavior
    "BruteForce",               # For testing password attacks
    "AuthenticationAnomaly",    # For testing suspicious auth patterns
    "OffHoursActivity",         # For testing after-hours activity
    "HighActivity",             # For testing excessive logon activity
    "LateralMovement",          # For testing lateral movement indicators
    "NewAccount",               # For testing recently created accounts
    "RoleMismatch",             # For testing role-department mismatches
    "ActivityAnomaly",          # For testing unusual activity patterns
    "AccountModification",      # For testing recently modified accounts
    "WeakPassword",             # For testing weak password indicators
    "DepartmentMismatch",       # For testing department mismatches
    "AccountLockout",           # For testing Search-ADAccount -LockedOut
    "AccountDisabled",          # For testing Search-ADAccount -AccountDisabled
    "PasswordExpired",          # For testing Search-ADAccount -PasswordExpired
    "PasswordNeverExpires",     # For testing Search-ADAccount -PasswordNeverExpires
    "AccountInactive",          # For testing Search-ADAccount -AccountInactive
    "AccountExpired",           # For testing Search-ADAccount -AccountExpired
    "AccountExpiring"           # For testing Search-ADAccount -AccountExpiring
)

# Enhanced risk scenarios with guaranteed IoC category coverage
$RiskScenarios = @(
    # CRITICAL RISK SCENARIOS
    @{ Type = "CRITICAL"; Name = "Privileged Account Password Change"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Domain Admin"; Department = "IT"; IoCCategory = "PrivilegeEscalation" },
    @{ Type = "CRITICAL"; Name = "Service Account with Admin Rights"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Service Account"; Department = "IT"; IoCCategory = "PrivilegeEscalation" },
    @{ Type = "CRITICAL"; Name = "Suspicious Account Naming"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountAnomaly" },
    @{ Type = "CRITICAL"; Name = "High Failed Password Attempts"; Count = 1; BadPasswordCount = 10; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "BruteForce" },
    
    # HIGH RISK SCENARIOS
    @{ Type = "HIGH"; Name = "Suspicious Authentication Pattern"; Count = 1; LogonCount = 300; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AuthenticationAnomaly" },
    @{ Type = "HIGH"; Name = "Service Account Off-Hours Activity"; Count = 1; LogonCount = 50; Enabled = "TRUE"; Title = "Service Account"; Department = "IT"; IoCCategory = "OffHoursActivity" },
    @{ Type = "HIGH"; Name = "High Activity Recent Logon"; Count = 1; LogonCount = 600; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "HighActivity" },
    @{ Type = "HIGH"; Name = "Lateral Movement Indicators"; Count = 1; LogonCount = 800; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "LateralMovement" },
    
    # MEDIUM RISK SCENARIOS
    @{ Type = "MEDIUM"; Name = "New Suspicious Account"; Count = 1; LogonCount = 10; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "NewAccount" },
    @{ Type = "MEDIUM"; Name = "Role-Department Mismatch"; Count = 1; LogonCount = 100; Enabled = "TRUE"; Title = "System Admin"; Department = "Sales"; IoCCategory = "RoleMismatch" },
    @{ Type = "MEDIUM"; Name = "Unusual Activity Pattern"; Count = 1; LogonCount = 250; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "ActivityAnomaly" },
    @{ Type = "MEDIUM"; Name = "Recently Modified Account"; Count = 1; LogonCount = 200; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountModification" },
    @{ Type = "MEDIUM"; Name = "Moderate Failed Password Attempts"; Count = 1; BadPasswordCount = 5; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "BruteForce" },
    
    # LOW RISK SCENARIOS
    @{ Type = "LOW"; Name = "Weak Password Indicators"; Count = 1; BadPasswordCount = 2; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "WeakPassword" },
    @{ Type = "LOW"; Name = "Department Mismatch"; Count = 1; BadPasswordCount = 1; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "DepartmentMismatch" },
    @{ Type = "LOW"; Name = "Unusual Login Time"; Count = 1; LogonCount = 20; Enabled = "TRUE"; LastLogon = "Weekend"; IoCCategory = "OffHoursActivity" },
    
    # SEARCH-ADACCOUNT SPECIFIC SCENARIOS
    @{ Type = "LOCKED"; Name = "Locked Out Account"; Count = 1; BadPasswordCount = 5; LockoutTime = "LOCKED"; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountLockout" },
    @{ Type = "DISABLED"; Name = "Disabled Account"; Count = 1; BadPasswordCount = 0; Enabled = "FALSE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountDisabled" },
    @{ Type = "PASSWORD_EXPIRED"; Name = "Expired Password Account"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "PasswordExpired"; PasswordLastSet = "OLD" },
    @{ Type = "PASSWORD_NEVER_EXPIRES"; Name = "Password Never Expires"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "PasswordNeverExpires"; PasswordNeverExpires = "TRUE" },
    @{ Type = "INACTIVE"; Name = "Inactive Account"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountInactive"; LastLogonDate = "OLD" },
    @{ Type = "EXPIRED"; Name = "Expired Account"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountExpired"; AccountExpirationDate = "EXPIRED" },
    @{ Type = "EXPIRING"; Name = "Expiring Account"; Count = 1; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountExpiring"; AccountExpirationDate = "EXPIRING" }
)

# Calculate minimum user count to ensure at least one per IoC category
$MinimumUserCount = $RiskScenarios.Count + 5  # Add 5 safe users as baseline
if ($UserCount -lt $MinimumUserCount) {
    Write-Host "$WarningEmoji User count $UserCount is below minimum required ($MinimumUserCount) for all IoC categories" -ForegroundColor Yellow
    Write-Host "Increasing user count to $MinimumUserCount to ensure comprehensive testing" -ForegroundColor Yellow
    $UserCount = $MinimumUserCount
}

# Calculate user distribution with IoC-aware targeting
$TotalUsers = $UserCount
$SafeUsers = [math]::Round($TotalUsers * (1 - $RiskPercentage / 100))
$RiskUsers = $TotalUsers - $SafeUsers

# Adjust risk user count based on IoC detection sensitivity
# Since IoC detection is broad, we need to be more conservative
$AdjustedRiskUsers = [math]::Round($RiskUsers * 0.7)  # Reduce by 30% to account for broad detection
$AdjustedSafeUsers = $TotalUsers - $AdjustedRiskUsers

Write-Host "$InfoEmoji User Distribution:" -ForegroundColor Cyan
Write-Host "  Safe Users: $SafeUsers (Adjusted: $AdjustedSafeUsers)" -ForegroundColor Green
Write-Host "  Risk Users: $RiskUsers (Adjusted: $AdjustedRiskUsers)" -ForegroundColor Yellow
Write-Host "  Total Users: $TotalUsers" -ForegroundColor White
Write-Host "  IoC Categories: $($IoCCategories.Count)" -ForegroundColor Magenta
Write-Host "  Note: Risk user count adjusted to account for broad IoC detection" -ForegroundColor Cyan
Write-Host ""



# Generate users
$Users = @()
$UserCounter = 1
$CreatedCategories = @()

# Generate safe users first (baseline)
for ($i = 1; $i -le $AdjustedSafeUsers; $i++) {
    $FirstName = $FirstNames | Get-Random
    $LastName = $LastNames | Get-Random
    $DisplayName = "$FirstName $LastName"
    $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
    
    # Ensure unique SamAccountName
    while ($Users.SamAccountName -contains $SamAccountName) {
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName + (Get-Random -Minimum 1 -Maximum 999)).ToLower()
    }
    
    $Title = $Titles | Get-Random
    $Department = $Departments | Get-Random
    $Building = $Buildings | Get-Random
    
    # Generate safe user data
    $Created = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("M/d/yyyy h:mm tt")
    $Modified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
    $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
    $LogonCount = Get-Random -Minimum 50 -Maximum 500
    $BadPasswordCount = Get-Random -Minimum 0 -Maximum 2
    $LockoutTime = ""
    $Enabled = "TRUE"
    
    $User = [PSCustomObject]@{
        FirstName = $FirstName
        LastName = $LastName
        DisplayName = $DisplayName
        SamAccountName = $SamAccountName
        DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=adnauseumgaming,DC=com"
        EmailAddress = "$SamAccountName@adnauseumgaming.com"
        EmpID = (Get-Random -Minimum 1000 -Maximum 9999).ToString()
        Title = $Title
        Department = $Department
        Guid = [System.Guid]::NewGuid().ToString()
        Created = $Created
        Modified = $Modified
        Enabled = $Enabled
        UserPrincipalName = "$SamAccountName@adnauseumgaming.com"
        SID = "S-1-5-21-1234567890-1234567890-1234567890-1000"
        PrimaryGroupID = "513"
        PasswordLastSet = $PasswordLastSet
        LastLogonDate = $LastLogonDate
        AccountExpirationDate = ""
        LockoutTime = if ($LockoutTime -eq "LOCKED") { (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt") } else { "" }
        LockedOut = if ($LockoutTime -ne "") { "TRUE" } else { "FALSE" }
        LogonCount = if ($LogonCount) { $LogonCount.ToString() } else { "0" }
        BadPasswordCount = if ($BadPasswordCount) { $BadPasswordCount.ToString() } else { "0" }
        PasswordNeverExpires = "FALSE"
        CannotChangePassword = "FALSE"
        SmartCardRequired = "FALSE"
        Manager = if ($Department -and $Title) { Get-ManagerAssignment -Department $Department -Title $Title -ExistingUsers $Users } else { "" }
        Office = $Building
        PhoneNumber = "555-1000"
        Mobile = "555-2000"
        Company = "AdNauseum Gaming"
    }

    $Users += $User
    $UserCounter++
}

# Generate guaranteed IoC category users (ensuring at least one per category)
Write-Host "$TargetEmoji Generating guaranteed IoC category users..." -ForegroundColor Cyan
$CreatedCategories = @()

# First pass: Create one user for each unique IoC category
$UniqueIoCCategories = $RiskScenarios.IoCCategory | Sort-Object | Get-Unique
Write-Host "Ensuring coverage for $($UniqueIoCCategories.Count) unique IoC categories..." -ForegroundColor Cyan

foreach ($Category in $UniqueIoCCategories) {
    # Find the first scenario for this category
    $Scenario = $RiskScenarios | Where-Object { $_.IoCCategory -eq $Category } | Select-Object -First 1
    
    if ($Users.Count -ge $TotalUsers) { 
        Write-Host "$WarningEmoji Reached user limit, cannot create all IoC categories" -ForegroundColor Yellow
        break 
    }
    
    # Limit IoC category users to prevent over-targeting
    $CurrentRiskUsers = ($Users | Where-Object { 
        $IoCDetections = Detect-UserIoCs -User $_
        $IoCDetections.Count -gt 0 
    }).Count
    
    if ($CurrentRiskUsers -ge $AdjustedRiskUsers) {
        Write-Host "$WarningEmoji Reached adjusted risk user limit ($AdjustedRiskUsers), stopping IoC category creation" -ForegroundColor Yellow
        break
    }
    
    $FirstName = $FirstNames | Get-Random
    $LastName = $LastNames | Get-Random
    $DisplayName = "$FirstName $LastName"
    
    # Handle special SamAccountName patterns
    if ($Scenario.SamAccountName -like "svc_*") {
        $SamAccountName = "svc_" + ($FirstName.Substring(0,1) + $LastName).ToLower()
    } else {
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
    }
    
    # Ensure unique SamAccountName
    while ($Users.SamAccountName -contains $SamAccountName) {
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName + (Get-Random -Minimum 1 -Maximum 999)).ToLower()
    }
    
    $Title = if ($Scenario.Title) { $Scenario.Title } else { $Titles | Get-Random }
    $Department = if ($Scenario.Department) { $Scenario.Department } else { $Departments | Get-Random }
    $Building = $Buildings | Get-Random
    
    # Generate user data based on scenario
    $Created = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("M/d/yyyy h:mm tt")
    $Modified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
    $Enabled = $Scenario.Enabled
    $BadPasswordCount = $Scenario.BadPasswordCount
    $LogonCount = if ($Scenario.LogonCount) { $Scenario.LogonCount } else { Get-Random -Minimum 10 -Maximum 200 }
    
    # Handle special Search-ADAccount scenarios
    switch ($Scenario.Type) {
        "LOCKED" {
            $LockoutTime = (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "DISABLED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "PASSWORD_EXPIRED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 90 -Maximum 120)).ToString("M/d/yyyy h:mm tt")  # Old password
        }
        "PASSWORD_NEVER_EXPIRES" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "INACTIVE" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 60 -Maximum 90)).ToString("M/d/yyyy h:mm tt")  # Old logon
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "EXPIRED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $AccountExpirationDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")  # Expired
        }
        "EXPIRING" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $AccountExpirationDate = (Get-Date).AddDays((Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")  # Expiring soon
        }
        default {
            # Handle different risk scenarios aligned with IoC categories
            switch ($Scenario.Type) {
                "CRITICAL" {
                    if ($Scenario.Name -like "*Privileged Account Password Change*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")  # Recent password change
                        $LogonCount = Get-Random -Minimum 200 -Maximum 800
                    } elseif ($Scenario.Name -like "*Service Account with Admin*") {
                        $LastLogonDate = ""
                        $LogonCount = 0
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                    } elseif ($Scenario.Name -like "*Suspicious Account Naming*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 200
                    } elseif ($Scenario.Name -like "*High Failed Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 100 -Maximum 400
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "HIGH" {
                    if ($Scenario.Name -like "*Suspicious Auth Pattern*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")  # Recent successful logon
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 150 -Maximum 400
                    } elseif ($Scenario.Name -like "*Service Account Off-Hours*") {
                        $LastLogonDate = (Get-Date).AddHours(-(Get-Random -Minimum 2 -Maximum 12)).ToString("M/d/yyyy h:mm tt")  # After hours activity
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 30 -Maximum 100
                    } elseif ($Scenario.Name -like "*High Activity Recent Logon*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 400 -Maximum 800
                    } elseif ($Scenario.Name -like "*Lateral Movement*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 600 -Maximum 1200
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "MEDIUM" {
                    if ($Scenario.Name -like "*New Suspicious Account*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")  # Recently created
                        $LogonCount = Get-Random -Minimum 5 -Maximum 20
                    } elseif ($Scenario.Name -like "*Role-Department Mismatch*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 200
                    } elseif ($Scenario.Name -like "*Unusual Activity Pattern*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 150 -Maximum 400
                    } elseif ($Scenario.Name -like "*Recently Modified Account*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 100 -Maximum 300
                    } elseif ($Scenario.Name -like "*Moderate Failed Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 150
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "LOW" {
                    if ($Scenario.Name -like "*Weak Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 20 -Maximum 100
                    } elseif ($Scenario.Name -like "*Department Mismatch*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 20 -Maximum 100
                    } elseif ($Scenario.Name -like "*Unusual Login Time*") {
                        $LastLogonDate = (Get-Date).AddDays(-1).AddHours(-(Get-Random -Minimum 18 -Maximum 23)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 10 -Maximum 50
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
            }
        }
    }
    
    $User = [PSCustomObject]@{
        FirstName = $FirstName
        LastName = $LastName
        DisplayName = $DisplayName
        SamAccountName = $SamAccountName
        DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=adnauseumgaming,DC=com"
        EmailAddress = "$SamAccountName@adnauseumgaming.com"
        EmpID = (Get-Random -Minimum 1000 -Maximum 9999).ToString()
        Title = $Title
        Department = $Department
        Guid = [System.Guid]::NewGuid().ToString()
        Created = $Created
        Modified = $Modified
        Enabled = $Enabled
        UserPrincipalName = "$SamAccountName@adnauseumgaming.com"
        SID = "S-1-5-21-1234567890-1234567890-1234567890-1000"
        PrimaryGroupID = "513"
        PasswordLastSet = $PasswordLastSet
        LastLogonDate = $LastLogonDate
        AccountExpirationDate = if ($AccountExpirationDate) { $AccountExpirationDate } else { "" }
        LockoutTime = if ($LockoutTime -eq "LOCKED") { (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt") } else { "" }
        LockedOut = if ($LockoutTime -ne "") { "TRUE" } else { "FALSE" }
        LogonCount = if ($LogonCount) { $LogonCount.ToString() } else { "0" }
        BadPasswordCount = if ($BadPasswordCount) { $BadPasswordCount.ToString() } else { "0" }
        PasswordNeverExpires = if ($Scenario.PasswordNeverExpires -eq "TRUE") { "TRUE" } else { "FALSE" }
        CannotChangePassword = "FALSE"
        SmartCardRequired = "FALSE"
        Manager = if ($Department -and $Title) { Get-ManagerAssignment -Department $Department -Title $Title -ExistingUsers $Users } else { "" }
        Office = $Building
        PhoneNumber = "555-1000"
        Mobile = "555-2000"
        Company = "AdNauseum Gaming"
    }
    
    $Users += $User
    $UserCounter++
    $CreatedCategories += $Scenario.IoCCategory
    
    Write-Host "  Created: $($Scenario.Name) - $($Scenario.IoCCategory)" -ForegroundColor Green
}

# Second pass: Create additional users for remaining scenarios if there's room
Write-Host ""
Write-Host "Creating additional users for remaining scenarios..." -ForegroundColor Cyan
foreach ($Scenario in $RiskScenarios) {
    if ($Users.Count -ge $TotalUsers) { break }
    
    # Skip if we already have enough users for this category
    $CategoryCount = ($CreatedCategories | Where-Object { $_ -eq $Scenario.IoCCategory }).Count
    if ($CategoryCount -ge 2) { continue }  # Limit to 2 users per category to ensure variety
    
    $FirstName = $FirstNames | Get-Random
    $LastName = $LastNames | Get-Random
    $DisplayName = "$FirstName $LastName"
    
    # Handle special SamAccountName patterns
    if ($Scenario.SamAccountName -like "svc_*") {
        $SamAccountName = "svc_" + ($FirstName.Substring(0,1) + $LastName).ToLower()
    } else {
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
    }
    
    # Ensure unique SamAccountName
    while ($Users.SamAccountName -contains $SamAccountName) {
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName + (Get-Random -Minimum 1 -Maximum 999)).ToLower()
    }
    
    $Title = if ($Scenario.Title) { $Scenario.Title } else { $Titles | Get-Random }
    $Department = if ($Scenario.Department) { $Scenario.Department } else { $Departments | Get-Random }
    $Building = $Buildings | Get-Random
    
    # Generate user data based on scenario (reuse the same logic as above)
    $Created = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("M/d/yyyy h:mm tt")
    $Modified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
    $Enabled = $Scenario.Enabled
    $BadPasswordCount = $Scenario.BadPasswordCount
    $LogonCount = if ($Scenario.LogonCount) { $Scenario.LogonCount } else { Get-Random -Minimum 10 -Maximum 200 }
    
    # Handle special Search-ADAccount scenarios (reuse the same logic)
    switch ($Scenario.Type) {
        "LOCKED" {
            $LockoutTime = (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "DISABLED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "PASSWORD_EXPIRED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 90 -Maximum 120)).ToString("M/d/yyyy h:mm tt")
        }
        "PASSWORD_NEVER_EXPIRES" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "INACTIVE" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 60 -Maximum 90)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
        "EXPIRED" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $AccountExpirationDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
        }
        "EXPIRING" {
            $LockoutTime = ""
            $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $AccountExpirationDate = (Get-Date).AddDays((Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
        }
        default {
            # Handle different risk scenarios (reuse the same logic)
            switch ($Scenario.Type) {
                "CRITICAL" {
                    if ($Scenario.Name -like "*Privileged Account Password Change*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 200 -Maximum 800
                    } elseif ($Scenario.Name -like "*Service Account with Admin*") {
                        $LastLogonDate = ""
                        $LogonCount = 0
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                    } elseif ($Scenario.Name -like "*Suspicious Account Naming*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 200
                    } elseif ($Scenario.Name -like "*High Failed Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 100 -Maximum 400
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "HIGH" {
                    if ($Scenario.Name -like "*Suspicious Auth Pattern*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 150 -Maximum 400
                    } elseif ($Scenario.Name -like "*Service Account Off-Hours*") {
                        $LastLogonDate = (Get-Date).AddHours(-(Get-Random -Minimum 2 -Maximum 12)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 30 -Maximum 100
                    } elseif ($Scenario.Name -like "*High Activity Recent Logon*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 400 -Maximum 800
                    } elseif ($Scenario.Name -like "*Lateral Movement*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 600 -Maximum 1200
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "MEDIUM" {
                    if ($Scenario.Name -like "*New Suspicious Account*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 5 -Maximum 20
                    } elseif ($Scenario.Name -like "*Role-Department Mismatch*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 200
                    } elseif ($Scenario.Name -like "*Unusual Activity Pattern*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 150 -Maximum 400
                    } elseif ($Scenario.Name -like "*Recently Modified Account*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 100 -Maximum 300
                    } elseif ($Scenario.Name -like "*Moderate Failed Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 50 -Maximum 150
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
                "LOW" {
                    if ($Scenario.Name -like "*Weak Password*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 20 -Maximum 100
                    } elseif ($Scenario.Name -like "*Department Mismatch*") {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 20 -Maximum 100
                    } elseif ($Scenario.Name -like "*Unusual Login Time*") {
                        $LastLogonDate = (Get-Date).AddDays(-1).AddHours(-(Get-Random -Minimum 18 -Maximum 23)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                        $LogonCount = Get-Random -Minimum 10 -Maximum 50
                    } else {
                        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    }
                }
            }
        }
    }
    
    $User = [PSCustomObject]@{
        FirstName = $FirstName
        LastName = $LastName
        DisplayName = $DisplayName
        SamAccountName = $SamAccountName
        DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=adnauseumgaming,DC=com"
        EmailAddress = "$SamAccountName@adnauseumgaming.com"
        EmpID = (Get-Random -Minimum 1000 -Maximum 9999).ToString()
        Title = $Title
        Department = $Department
        Guid = [System.Guid]::NewGuid().ToString()
        Created = $Created
        Modified = $Modified
        Enabled = $Enabled
        UserPrincipalName = "$SamAccountName@adnauseumgaming.com"
        SID = "S-1-5-21-1234567890-1234567890-1234567890-1000"
        PrimaryGroupID = "513"
        PasswordLastSet = $PasswordLastSet
        LastLogonDate = $LastLogonDate
        AccountExpirationDate = if ($AccountExpirationDate) { $AccountExpirationDate } else { "" }
        LockoutTime = if ($LockoutTime -eq "LOCKED") { (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt") } else { "" }
        LockedOut = if ($LockoutTime -ne "") { "TRUE" } else { "FALSE" }
        LogonCount = if ($LogonCount) { $LogonCount.ToString() } else { "0" }
        BadPasswordCount = if ($BadPasswordCount) { $BadPasswordCount.ToString() } else { "0" }
        PasswordNeverExpires = if ($Scenario.PasswordNeverExpires -eq "TRUE") { "TRUE" } else { "FALSE" }
        CannotChangePassword = "FALSE"
        SmartCardRequired = "FALSE"
        Manager = if ($Department -and $Title) { Get-ManagerAssignment -Department $Department -Title $Title -ExistingUsers $Users } else { "" }
        Office = $Building
        PhoneNumber = "555-1000"
        Mobile = "555-2000"
        Company = "AdNauseum Gaming"
    }
    
    $Users += $User
    $UserCounter++
    $CreatedCategories += $Scenario.IoCCategory
    
    Write-Host "  Created additional: $($Scenario.Name) - $($Scenario.IoCCategory)" -ForegroundColor Green
}

# Show IoC category coverage summary
Write-Host ""
Write-Host "=== IoC CATEGORY COVERAGE SUMMARY ===" -ForegroundColor Cyan
$UniqueCategories = $CreatedCategories | Sort-Object | Get-Unique
Write-Host "Created $($UniqueCategories.Count) unique IoC categories:" -ForegroundColor Green
foreach ($Category in $UniqueCategories) {
    $Count = ($CreatedCategories | Where-Object { $_ -eq $Category }).Count
    Write-Host "  $Category`: $Count user(s)" -ForegroundColor White
}

# Check for missing categories
$MissingCategories = $IoCCategories | Where-Object { $UniqueCategories -notcontains $_ }
if ($MissingCategories.Count -gt 0) {
    Write-Host ""
    Write-Host "$WarningEmoji Missing IoC categories:" -ForegroundColor Yellow
    foreach ($Category in $MissingCategories) {
        Write-Host "  $Category" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "$SuccessEmoji All IoC categories covered!" -ForegroundColor Green
}

# Ensure we have exactly the requested number of users
if ($Users.Count -lt $TotalUsers) {
    # Add remaining users as safe users
    Write-Host ""
    Write-Host "Adding $($TotalUsers - $Users.Count) additional safe users..." -ForegroundColor Cyan
    for ($i = $Users.Count + 1; $i -le $TotalUsers; $i++) {
        $FirstName = $FirstNames | Get-Random
        $LastName = $LastNames | Get-Random
        $DisplayName = "$FirstName $LastName"
        $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
        
        while ($Users.SamAccountName -contains $SamAccountName) {
            $SamAccountName = ($FirstName.Substring(0,1) + $LastName + (Get-Random -Minimum 1 -Maximum 999)).ToLower()
        }
        
        $Title = $Titles | Get-Random
        $Department = $Departments | Get-Random
        $Building = $Buildings | Get-Random
        
        $Created = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("M/d/yyyy h:mm tt")
        $Modified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
        $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        $LastLogonDate = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
        $LogonCount = Get-Random -Minimum 50 -Maximum 500
        $BadPasswordCount = Get-Random -Minimum 0 -Maximum 2
        
        $User = [PSCustomObject]@{
            FirstName = $FirstName
            LastName = $LastName
            DisplayName = $DisplayName
            SamAccountName = $SamAccountName
            DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=adnauseumgaming,DC=com"
            EmailAddress = "$SamAccountName@adnauseumgaming.com"
            EmpID = (Get-Random -Minimum 1000 -Maximum 9999).ToString()
            Title = $Title
            Department = $Department
            Guid = [System.Guid]::NewGuid().ToString()
            Created = $Created
            Modified = $Modified
            Enabled = "TRUE"
            UserPrincipalName = "$SamAccountName@adnauseumgaming.com"
            SID = "S-1-5-21-1234567890-1234567890-1234567890-1000"
            PrimaryGroupID = "513"
            PasswordLastSet = $PasswordLastSet
            LastLogonDate = $LastLogonDate
            AccountExpirationDate = ""
            LockoutTime = ""
            LockedOut = "FALSE"
            LogonCount = if ($LogonCount) { $LogonCount.ToString() } else { "0" }
            BadPasswordCount = if ($BadPasswordCount) { $BadPasswordCount.ToString() } else { "0" }
            PasswordNeverExpires = "FALSE"
            CannotChangePassword = "FALSE"
            SmartCardRequired = "FALSE"
            Manager = if ($Department -and $Title) { Get-ManagerAssignment -Department $Department -Title $Title -ExistingUsers $Users } else { "" }
            Office = $Building
            PhoneNumber = "555-1000"
            Mobile = "555-2000"
            Company = "AdNauseum Gaming"
        }
        
        $Users += $User
    }
}

# Add AD-like properties to each user before export
foreach ($User in $Users) {
    $User | Add-Member -NotePropertyName 'whenCreated' -NotePropertyValue $User.Created -Force
    $User | Add-Member -NotePropertyName 'whenChanged' -NotePropertyValue $User.Modified -Force
    $User | Add-Member -NotePropertyName 'pwdLastSet' -NotePropertyValue $User.PasswordLastSet -Force
    $User | Add-Member -NotePropertyName 'accountExpires' -NotePropertyValue $User.AccountExpirationDate -Force
}

# Update the export columns to include the new fields at the end
$ExportColumns = @("FirstName","LastName","DisplayName","SamAccountName","DistinguishedName","EmailAddress","EmpID","Title","Department","Guid","Created","Modified","Enabled","UserPrincipalName","SID","PrimaryGroupID","PasswordLastSet","LastLogonDate","AccountExpirationDate","LockoutTime","LockedOut","LogonCount","BadPasswordCount","PasswordNeverExpires","CannotChangePassword","SmartCardRequired","Manager","Office","PhoneNumber","Mobile","Company","whenCreated","whenChanged","pwdLastSet","accountExpires")

# Export to CSV
try {
    # Ensure directory exists
    $Directory = Split-Path $OutputPath -Parent
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    $Users | Select-Object $ExportColumns | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Enhanced database created successfully!" -ForegroundColor Green
    Write-Host "Output file: $OutputPath" -ForegroundColor Green
    Write-Host "Total users: $($Users.Count)" -ForegroundColor Green
    
    # Calculate actual risk percentage using the same logic as Get-SecurityReport.ps1
    $RiskyCount = 0
    $CriticalCount = 0
    $HighCount = 0
    $MediumCount = 0
    $LowCount = 0
    
    # Use the same detection logic as Get-SecurityReport.ps1
    foreach ($User in $Users) {
        $IoCDetections = Detect-UserIoCs -User $User
        
        if ($IoCDetections.Count -gt 0) {
            $RiskyCount++
            
            # Categorize based on IoC severity
            $HasCritical = $IoCDetections | Where-Object { $_.Severity -eq "CRITICAL" }
            $HasHigh = $IoCDetections | Where-Object { $_.Severity -eq "HIGH" }
            $HasMedium = $IoCDetections | Where-Object { $_.Severity -eq "MEDIUM" }
            $HasLow = $IoCDetections | Where-Object { $_.Severity -eq "LOW" }
            
            if ($HasCritical) { $CriticalCount++ }
            elseif ($HasHigh) { $HighCount++ }
            elseif ($HasMedium) { $MediumCount++ }
            elseif ($HasLow) { $LowCount++ }
        }
    }
    
    # Apply risk percentage adjustment if needed
    $TargetRiskyCount = [math]::Round($Users.Count * ($RiskPercentage / 100))
    if ($RiskyCount -gt $TargetRiskyCount) {
        Write-Host "Note: Actual risk count ($RiskyCount) exceeds target ($TargetRiskyCount)" -ForegroundColor Yellow
        Write-Host "Consider adjusting IoC detection sensitivity or user generation parameters" -ForegroundColor Yellow
    }
    
    $ActualRiskPercentage = [math]::Round(($RiskyCount / $Users.Count) * 100, 2)
    
    Write-Host ""
    Write-Host "=== ENHANCED RISK STATISTICS ===" -ForegroundColor Cyan
    Write-Host "Total Users: $($Users.Count)" -ForegroundColor White
    Write-Host "Risky Users: $RiskyCount" -ForegroundColor Yellow
    Write-Host "Actual Risk Percentage: $ActualRiskPercentage%" -ForegroundColor Yellow
    Write-Host "Critical Risks: $CriticalCount" -ForegroundColor Red
    Write-Host "High Risks: $HighCount" -ForegroundColor Yellow
    Write-Host "Medium Risks: $MediumCount" -ForegroundColor Magenta
    Write-Host "Low Risks: $LowCount" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Note: Risk calculation now uses the same IoC detection logic as Get-SecurityReport.ps1" -ForegroundColor Cyan
    Write-Host "This ensures consistent risk percentages between user creation and security reports." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Target Risk Percentage: $RiskPercentage%" -ForegroundColor White
    Write-Host "Actual Risk Percentage: $ActualRiskPercentage%" -ForegroundColor Yellow
    if ($ActualRiskPercentage -ne $RiskPercentage) {
        $Difference = $ActualRiskPercentage - $RiskPercentage
        $DifferenceText = if ($Difference -gt 0) { "+$Difference%" } else { "$Difference%" }
        Write-Host "Difference: $DifferenceText" -ForegroundColor $(if ($Difference -gt 0) { "Yellow" } else { "Green" })
        Write-Host "Note: Actual percentage may differ due to IoC detection precision and user distribution." -ForegroundColor Cyan
    }
    
    # Test the database with security report (if not skipped)
    if (-not $SkipSecurityTest) {
        Write-Host ""
        Write-Host "Testing enhanced database with security report..." -ForegroundColor Cyan
        & "..\Scripts\Public\Get-SecurityReport.ps1" -DetailedReport
    } else {
        Write-Host ""
        Write-Host "Skipping security report test (use -SkipSecurityTest to skip)" -ForegroundColor Yellow
    }
    
}
catch {
    Write-Error "Failed to create enhanced database: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Host "=== ENHANCED DATABASE CREATION COMPLETE ===" -ForegroundColor Green
Write-Host "Enhanced with comprehensive cybersecurity scenarios aligned with IoC categories:" -ForegroundColor Cyan
Write-Host "$($ErrorEmoji) Critical: Privilege escalation, Service account abuse, Suspicious naming" -ForegroundColor Red
Write-Host "$($WarningEmoji) High: Suspicious auth patterns, Off-hours activity, Lateral movement" -ForegroundColor Yellow
Write-Host "$($InfoEmoji) Medium: Reconnaissance, Insider threats, Credential dumping, Account manipulation" -ForegroundColor Magenta
Write-Host "$($BulbEmoji) Low: Weak passwords, Department mismatches, Unusual login times" -ForegroundColor DarkCyan 
