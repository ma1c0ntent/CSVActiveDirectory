# Create-Users.ps1
# Generate a database of users with comprehensive cybersecurity risk scenarios
# Enhanced for incident response and security analysis
# Supports customizable user count with default of 150 users

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "Data\Database\Database.csv",
    
    [Parameter(Mandatory=$false)]
    [int]$UserCount = 150,
    
    [Parameter(Mandatory=$false)]
    [double]$RiskPercentage = 30.0,
    
    [Parameter(Mandatory=$false)]
    [switch]$BackupExisting = $true
)

Write-Host "=== CREATING ENHANCED $UserCount-USER DATABASE ===" -ForegroundColor Cyan
Write-Host "Target Risk Percentage: $RiskPercentage%" -ForegroundColor Yellow
Write-Host "Enhanced with cybersecurity and incident response scenarios" -ForegroundColor Green
Write-Host ""

# Import required modules
try {
    Import-Module .\CSVActiveDirectory.psd1 -Force
}
catch {
    Write-Error "Failed to import CSVActiveDirectory module"
    exit 1
}

# Backup existing database if requested
if ($BackupExisting -and (Test-Path "Data\Database\Database.csv")) {
    $BackupPath = "Data\Database\Database.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    Copy-Item "Data\Database\Database.csv" $BackupPath
    Write-Host "Backed up existing database to: $BackupPath" -ForegroundColor Green
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

# Calculate number of risky users
$TotalUsers = $UserCount
$RiskyUsers = [math]::Round($TotalUsers * ($RiskPercentage / 100))
$SafeUsers = $TotalUsers - $RiskyUsers

# Helper function to generate account expiration dates
Function Get-AccountExpiration {
    $random = Get-Random -Minimum 1 -Maximum 100
    if ($random -le 15) {
        # 15% chance of expired account (expired in the past)
        return (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
    } elseif ($random -le 25) {
        # 10% chance of account expiring soon (within 30 days)
        $days = Get-Random -Minimum 1 -Maximum 30
        return (Get-Date).AddDays($days).ToString("M/d/yyyy h:mm tt")
    } else {
        # 75% chance of no expiration
        return ""
    }
}

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

Write-Host "Generating $SafeUsers safe users and $RiskyUsers risky users..." -ForegroundColor Green

# Enhanced risk scenarios aligned with comprehensive cybersecurity guide
$RiskScenarios = @(
    # 🔴 CRITICAL RISKS - Immediate response required
    @{ Type = "CRITICAL"; Name = "Privileged Account Password Change"; Count = 4; BadPasswordCount = 8; LockoutTime = ""; Enabled = "TRUE"; Title = "Domain Admin"; Department = "IT"; IoCCategory = "PrivilegeEscalation" },
    @{ Type = "CRITICAL"; Name = "Service Account with Admin Privileges"; Count = 3; SamAccountName = "svc_*"; LogonCount = 0; Enabled = "TRUE"; Title = "Service Account"; Department = "IT"; IoCCategory = "PrivilegeEscalation" },
    @{ Type = "CRITICAL"; Name = "Suspicious Account Naming"; Count = 3; BadPasswordCount = 6; Enabled = "TRUE"; Title = "Administrator"; Department = "IT"; IoCCategory = "Reconnaissance" },
    @{ Type = "CRITICAL"; Name = "High Failed Password Attempts"; Count = 4; BadPasswordCount = 8; LockoutTime = ""; Enabled = "TRUE"; Title = "System Admin"; Department = "IT"; IoCCategory = "Other" },
    
    # 🟡 HIGH RISKS - Investigate within 24 hours
    @{ Type = "HIGH"; Name = "Suspicious Auth Pattern"; Count = 8; BadPasswordCount = 6; LockoutTime = ""; Enabled = "TRUE"; Title = "Junior Admin"; Department = "IT"; IoCCategory = "SuspiciousAuth" },
    @{ Type = "HIGH"; Name = "Service Account Off-Hours Activity"; Count = 6; SamAccountName = "svc_*"; LogonCount = 50; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Service Account"; Department = "IT"; IoCCategory = "ServiceAccountAbuse" },
    @{ Type = "HIGH"; Name = "High Activity Recent Logon"; Count = 20; LogonCount = 500; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Data Analyst"; Department = "Finance"; IoCCategory = "LateralMovement" },
    @{ Type = "HIGH"; Name = "Lateral Movement Indicator"; Count = 8; LogonCount = 800; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Network Admin"; Department = "IT"; IoCCategory = "LateralMovement" },
    
    # 🟣 MEDIUM RISKS - Investigate within 1 week
    @{ Type = "MEDIUM"; Name = "New Suspicious Account"; Count = 6; LogonCount = 10; BadPasswordCount = 1; Enabled = "TRUE"; Title = "New Employee"; Department = "IT"; IoCCategory = "Reconnaissance" },
    @{ Type = "MEDIUM"; Name = "Role-Department Mismatch"; Count = 5; LogonCount = 100; BadPasswordCount = 0; Enabled = "TRUE"; Title = "Administrator"; Department = "Sales"; IoCCategory = "InsiderThreat" },
    @{ Type = "MEDIUM"; Name = "Unusual Activity Pattern"; Count = 15; LogonCount = 200; BadPasswordCount = 3; Enabled = "TRUE"; Title = "Help Desk"; Department = "IT"; IoCCategory = "CredentialDumping" },
    @{ Type = "MEDIUM"; Name = "Recently Modified Account"; Count = 12; LogonCount = 150; BadPasswordCount = 0; Enabled = "TRUE"; Title = "User"; Department = "HR"; IoCCategory = "AccountManipulation" },
    @{ Type = "MEDIUM"; Name = "Moderate Failed Password Attempts"; Count = 8; BadPasswordCount = 4; LockoutTime = ""; Enabled = "TRUE"; Title = "Regular User"; Department = "Marketing"; IoCCategory = "CredentialDumping" },
    
    # 🔵 LOW RISKS - Monitor and investigate as time permits
    @{ Type = "LOW"; Name = "Weak Password Policy"; Count = 3; BadPasswordCount = 1; Enabled = "TRUE"; Title = "Regular User"; Department = "Marketing"; IoCCategory = "Other" },
    @{ Type = "LOW"; Name = "Department Mismatch"; Count = 3; Title = "IT Admin"; Department = "Sales"; IoCCategory = "Other" },
    @{ Type = "LOW"; Name = "Unusual Login Time"; Count = 3; LogonCount = 20; Enabled = "TRUE"; LastLogon = "Weekend"; IoCCategory = "Other" },
    
    # 🔒 LOCKED OUT ACCOUNTS - For testing Search-ADAccount -LockedOut
    @{ Type = "LOCKED"; Name = "Locked Out Account"; Count = 8; BadPasswordCount = 5; LockoutTime = "LOCKED"; Enabled = "TRUE"; Title = "Regular User"; Department = "IT"; IoCCategory = "AccountLockout" },
    @{ Type = "LOCKED"; Name = "Locked Out Admin"; Count = 3; BadPasswordCount = 8; LockoutTime = "LOCKED"; Enabled = "TRUE"; Title = "System Admin"; Department = "IT"; IoCCategory = "AccountLockout" },
    @{ Type = "LOCKED"; Name = "Locked Out Service"; Count = 2; BadPasswordCount = 6; LockoutTime = "LOCKED"; Enabled = "TRUE"; Title = "Service Account"; Department = "IT"; IoCCategory = "AccountLockout" }
)

# Generate users
$Users = @()
$UserCounter = 1

# Generate safe users (70%)
for ($i = 1; $i -le $SafeUsers; $i++) {
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
    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
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
            LastLogon = $LastLogon
            AccountExpires = ""
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

# Generate risky users (30%) with enhanced cybersecurity scenarios
$RiskUserCounter = 0
foreach ($Scenario in $RiskScenarios) {
    for ($i = 1; $i -le $Scenario.Count; $i++) {
        if ($Users.Count -ge $TotalUsers) { break }
        
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
        
        # Generate risky user data based on scenario
        $Created = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("M/d/yyyy h:mm tt")
        $Modified = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
        $Enabled = $Scenario.Enabled
        $BadPasswordCount = $Scenario.BadPasswordCount
        $LockoutTime = if ($Scenario.LockoutTime -and $Scenario.LockoutTime -eq "LOCKED") { (Get-Date).AddMinutes(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt") } else { "" }
        $LogonCount = if ($Scenario.LogonCount) { $Scenario.LogonCount } else { Get-Random -Minimum 10 -Maximum 200 }
        
        # Handle different risk scenarios aligned with IoC categories
        switch ($Scenario.Type) {
            "CRITICAL" {
                if ($Scenario.Name -like "*Privileged Account Password Change*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")  # Recent password change
                    $LogonCount = Get-Random -Minimum 200 -Maximum 800
                } elseif ($Scenario.Name -like "*Service Account with Admin*") {
                    $LastLogon = ""
                    $LogonCount = 0
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                } elseif ($Scenario.Name -like "*Suspicious Account Naming*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 50 -Maximum 200
                } elseif ($Scenario.Name -like "*High Failed Password*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 100 -Maximum 400
                } else {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                }
            }
            "HIGH" {
                if ($Scenario.Name -like "*Suspicious Auth Pattern*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")  # Recent successful logon
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 150 -Maximum 400
                } elseif ($Scenario.Name -like "*Service Account Off-Hours*") {
                    $LastLogon = (Get-Date).AddHours(-(Get-Random -Minimum 2 -Maximum 12)).ToString("M/d/yyyy h:mm tt")  # After hours activity
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 30 -Maximum 100
                } elseif ($Scenario.Name -like "*High Activity Recent Logon*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 400 -Maximum 800
                } elseif ($Scenario.Name -like "*Lateral Movement*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 3)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 600 -Maximum 1200
                } else {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                }
            }
            "MEDIUM" {
                if ($Scenario.Name -like "*New Suspicious Account*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")  # Recently created
                    $LogonCount = Get-Random -Minimum 5 -Maximum 20
                } elseif ($Scenario.Name -like "*Role-Department Mismatch*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 50 -Maximum 200
                } elseif ($Scenario.Name -like "*Unusual Activity Pattern*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 150 -Maximum 400
                } elseif ($Scenario.Name -like "*Recently Modified Account*") {
                    $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
                    $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
                    $LogonCount = Get-Random -Minimum 100 -Maximum 300
                        } elseif ($Scenario.Name -like "*Moderate Failed Password*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 50 -Maximum 150
        } else {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
    }
    "LOW" {
        if ($Scenario.Name -like "*Weak Password*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 20 -Maximum 100
        } elseif ($Scenario.Name -like "*Department Mismatch*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 20 -Maximum 100
        } elseif ($Scenario.Name -like "*Unusual Login Time*") {
            $LastLogon = (Get-Date).AddDays(-1).AddHours(-(Get-Random -Minimum 18 -Maximum 23)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 10 -Maximum 50
        } else {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
        }
    }
    "LOCKED" {
        if ($Scenario.Name -like "*Locked Out Account*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 20 -Maximum 100
        } elseif ($Scenario.Name -like "*Locked Out Admin*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 100 -Maximum 300
        } elseif ($Scenario.Name -like "*Locked Out Service*") {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 30)).ToString("M/d/yyyy h:mm tt")
            $LogonCount = Get-Random -Minimum 10 -Maximum 50
        } else {
            $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
            $PasswordLastSet = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("M/d/yyyy h:mm tt")
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
            LastLogon = $LastLogon
            AccountExpires = ""
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
        $UserCounter++
        $RiskUserCounter++
    }
}

# Ensure we have exactly 150 users
if ($Users.Count -lt $TotalUsers) {
    # Add remaining users as safe users
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
        $LastLogon = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)).ToString("M/d/yyyy h:mm tt")
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
            LastLogon = $LastLogon
            AccountExpires = ""
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
        $UserCounter++
    }
}

# Export to CSV
try {
    # Ensure directory exists
    $Directory = Split-Path $OutputPath -Parent
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    
    $Users | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Enhanced database created successfully!" -ForegroundColor Green
    Write-Host "Output file: $OutputPath" -ForegroundColor Green
    Write-Host "Total users: $($Users.Count)" -ForegroundColor Green
    
    # Calculate enhanced risk statistics aligned with IoC categories
    $RiskyCount = 0
    $CriticalCount = 0
    $HighCount = 0
    $MediumCount = 0
    $LowCount = 0
    
    foreach ($User in $Users) {
        $IsRisky = $false
        
        # Enhanced risk detection patterns aligned with comprehensive cybersecurity guide
        # 🔴 CRITICAL RISKS
        if ($User.BadPasswordCount -ge 8 -and $User.LockoutTime -eq "") { $IsRisky = $true; $CriticalCount++ }
        elseif ($User.SamAccountName -like "svc_*" -and $User.Title -like "*Admin*" -and $User.Enabled -eq "TRUE") { $IsRisky = $true; $CriticalCount++ }
        elseif ($User.Title -like "*Admin*" -and $User.Enabled -eq "TRUE") {
            try {
                $PasswordSetDate = [DateTime]::ParseExact($User.PasswordLastSet, "M/d/yyyy h:mm tt", $null)
                $DaysSincePasswordSet = (Get-Date) - $PasswordSetDate
                if ($DaysSincePasswordSet.Days -le 7) { $IsRisky = $true; $CriticalCount++ }  # Recent password change for admin
            }
            catch { }
        }
        # 🟡 HIGH RISKS
        elseif ($User.BadPasswordCount -ge 3 -and $User.BadPasswordCount -lt 8 -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 1) { $IsRisky = $true; $HighCount++ }  # Suspicious auth pattern
            }
            catch { }
        }
        elseif ($User.SamAccountName -like "svc_*" -and $User.Enabled -eq "TRUE" -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $LogonHour = $LastLogonDate.Hour
                if ($LogonHour -ge 18 -or $LogonHour -le 6) { $IsRisky = $true; $HighCount++ }  # Off-hours activity
            }
            catch { }
        }
        elseif ($User.LogonCount -ge 500 -and $User.LastLogon -ne "") {
            try {
                $LastLogonDate = [DateTime]::ParseExact($User.LastLogon, "M/d/yyyy h:mm tt", $null)
                $DaysSinceLogon = (Get-Date) - $LastLogonDate
                if ($DaysSinceLogon.Days -le 7) { $IsRisky = $true; $HighCount++ }  # High activity recent logon
            }
            catch { }
        }
        # 🟣 MEDIUM RISKS
        elseif ($User.Title -like "*Admin*" -and $User.Department -ne "IT" -and $User.Department -ne "Engineering") { $IsRisky = $true; $MediumCount++ }
        elseif ($User.LogonCount -ge 200 -and $User.BadPasswordCount -ge 2) { $IsRisky = $true; $MediumCount++ }
        elseif ($User.Modified -ne "" -and $User.Enabled -eq "TRUE") {
            try {
                $ModifiedDate = [DateTime]::ParseExact($User.Modified, "M/d/yyyy h:mm tt", $null)
                $DaysSinceModified = (Get-Date) - $ModifiedDate
                if ($DaysSinceModified.Days -le 3) { $IsRisky = $true; $MediumCount++ }  # Recently modified account
            }
            catch { }
        }
        elseif ($User.BadPasswordCount -ge 4 -and $User.BadPasswordCount -lt 6) { $IsRisky = $true; $MediumCount++ }
        # 🔵 LOW RISKS
        elseif ($User.BadPasswordCount -eq 1 -and $User.Enabled -eq "TRUE") { $IsRisky = $true; $LowCount++ }
        
        if ($IsRisky) { $RiskyCount++ }
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
    Write-Host "Low Risks: $LowCount" -ForegroundColor Blue
    
    # Test the database with security report
    Write-Host ""
    Write-Host "Testing enhanced database with security report..." -ForegroundColor Cyan
    & ".\Scripts\Get-ADSecurityReport-Enterprise.ps1" -DetailedReport
    
}
catch {
    Write-Error "Failed to create enhanced database: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Host "=== ENHANCED DATABASE CREATION COMPLETE ===" -ForegroundColor Green
Write-Host "Enhanced with comprehensive cybersecurity scenarios aligned with IoC categories:" -ForegroundColor Cyan
Write-Host "🔴 Critical: Privilege escalation, Service account abuse, Suspicious naming" -ForegroundColor Red
Write-Host "🟡 High: Suspicious auth patterns, Off-hours activity, Lateral movement" -ForegroundColor Yellow
Write-Host "🟣 Medium: Reconnaissance, Insider threats, Credential dumping, Account manipulation" -ForegroundColor Magenta
Write-Host "🔵 Low: Weak passwords, Department mismatches, Unusual login times" -ForegroundColor Blue 
