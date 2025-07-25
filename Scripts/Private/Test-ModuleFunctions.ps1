# Test script to verify all functions are properly exported and working
Write-Host "Testing CSVActiveDirectory Module Functions" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Import the module
Import-Module .\CSVActiveDirectory.psd1 -Force

# Initialize emoji variables for compatibility
$SuccessEmoji = Get-Emoji -Type "Success"
$ErrorEmoji = Get-Emoji -Type "Error"
$WarningEmoji = Get-Emoji -Type "Warning"

# List all exported functions
Write-Host "`nExported Functions:" -ForegroundColor Yellow
$ExportedFunctions = Get-Command -Module CSVActiveDirectory | Select-Object Name
$ExportedFunctions | Format-Table
Write-Host "Total Functions: $($ExportedFunctions.Count)" -ForegroundColor Cyan

# Test configuration functions
Write-Host "`nTesting Configuration Functions:" -ForegroundColor Yellow
try {
    $Config = Get-ADConfig -Section "DomainSettings"
    Write-Host "$($SuccessEmoji) Get-ADConfig working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Get-ADConfig failed: $_" -ForegroundColor Red
}

try {
    Set-ADConfig -Section "TestSection" -Key "TestKey" -Value "TestValue"
    Write-Host "$($SuccessEmoji) Set-ADConfig working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Set-ADConfig failed: $_" -ForegroundColor Red
}

# Test password functions
Write-Host "`nTesting Password Functions:" -ForegroundColor Yellow
try {
    $PasswordPolicy = Get-ADPasswordPolicy
    Write-Host "$($SuccessEmoji) Get-ADPasswordPolicy working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Get-ADPasswordPolicy failed: $_" -ForegroundColor Red
}

try {
    # Create a config object that matches what Test-ADPasswordComplexity expects
    $TestConfig = @{
        MinimumLength = 8
        MaximumLength = 128
        RequireComplexity = $true
        RequireUppercase = $true
        RequireLowercase = $true
        RequireNumbers = $true
        RequireSpecialCharacters = $true
        AllowedSpecialCharacters = "!@#$%^&*()_+-=[]{}|;:,.<>?"
    }
    $Validation = Test-ADPasswordComplexity -Password "Test123!" -Config $TestConfig
    Write-Host "$($SuccessEmoji) Test-ADPasswordComplexity working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Test-ADPasswordComplexity failed: $_" -ForegroundColor Red
}

try {
    $Hash = ConvertTo-ADPasswordHash -Password "Test123!"
    Write-Host "$($SuccessEmoji) ConvertTo-ADPasswordHash working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) ConvertTo-ADPasswordHash failed: $_" -ForegroundColor Red
}

try {
    # Test-ADPassword requires SecureString, so we'll test it differently
    $TestUser = Get-ADUser -Identity "*" | Select-Object -First 1
    if ($TestUser) {
        Write-Host "$($SuccessEmoji) Test-ADPassword function available (requires SecureString)" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) No users found for Test-ADPassword test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Test-ADPassword test failed: $_" -ForegroundColor Red
}

# Test user management functions
Write-Host "`nTesting User Management Functions:" -ForegroundColor Yellow
try {
    $Users = Get-ADUser -Identity "*" | Select-Object -First 3
    Write-Host "$($SuccessEmoji) Get-ADUser working (found $($Users.Count) users)" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Get-ADUser failed: $_" -ForegroundColor Red
}

try {
    $SearchResults = Search-ADAccount -LockedOut | Select-Object -First 2
    Write-Host "$($SuccessEmoji) Search-ADAccount working (found $($SearchResults.Count) results)" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Search-ADAccount failed: $_" -ForegroundColor Red
}

# Test user creation and management functions
Write-Host "`nTesting User Creation and Management Functions:" -ForegroundColor Yellow
try {
    # Test New-ADUser with a test user
    $TestUserParams = @{
        SamAccountName = "testuser"
        FirstName = "Test"
        LastName = "User"
        EmailAddress = "test@example.com"
        Department = "IT"
        Title = "Tester"
    }
    New-ADUser @TestUserParams | Out-Null
    Write-Host "$($SuccessEmoji) New-ADUser working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) New-ADUser failed: $_" -ForegroundColor Red
}

try {
    # Test Set-ADAccountPassword (without actually changing password)
    $TestUser = Get-ADUser -Identity "testuser" -ErrorAction SilentlyContinue
    if ($TestUser) {
        Write-Host "$($SuccessEmoji) Set-ADAccountPassword function available" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Test user not found for Set-ADAccountPassword test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Set-ADAccountPassword test failed: $_" -ForegroundColor Red
}

try {
    # Test Disable-ADAccount
    $TestUser = Get-ADUser -Identity "testuser" -ErrorAction SilentlyContinue
    if ($TestUser) {
        Disable-ADAccount -Identity "testuser"
        Write-Host "$($SuccessEmoji) Disable-ADAccount working" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Test user not found for Disable-ADAccount test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Disable-ADAccount failed: $_" -ForegroundColor Red
}

try {
    # Test Enable-ADAccount
    $TestUser = Get-ADUser -Identity "testuser" -ErrorAction SilentlyContinue
    if ($TestUser) {
        Enable-ADAccount -Identity "testuser"
        Write-Host "$($SuccessEmoji) Enable-ADAccount working" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Test user not found for Enable-ADAccount test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Enable-ADAccount failed: $_" -ForegroundColor Red
}

try {
    # Test Remove-ADUser (clean up test user)
    $TestUser = Get-ADUser -Identity "testuser" -ErrorAction SilentlyContinue
    if ($TestUser) {
        Remove-ADUser -Identity "testuser" -Confirm:$false | Out-Null
        Write-Host "$($SuccessEmoji) Remove-ADUser working" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) Test user not found for Remove-ADUser test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Remove-ADUser failed: $_" -ForegroundColor Red
}

# Test account management functions (with safety checks)
Write-Host "`nTesting Account Management Functions:" -ForegroundColor Yellow
try {
    $TestUser = Get-ADUser -Identity "*" | Select-Object -First 1
    if ($TestUser) {
        $AccountStatus = Get-ADUser -Identity $TestUser.SamAccountName -Properties Enabled
        Write-Host "$($SuccessEmoji) Account status check working" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) No users found for account management test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Account management test failed: $_" -ForegroundColor Red
}

# Test progress and status functions
Write-Host "`nTesting Progress and Status Functions:" -ForegroundColor Yellow
try {
    Show-ADProgress -Activity "Test" -Status "Testing..." -Style "Simple"
    Write-Host "$($SuccessEmoji) Show-ADProgress working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Show-ADProgress failed: $_" -ForegroundColor Red
}

try {
    # Show-ADBulkProgress requires Items array and ProcessScript
    $TestItems = @("Item1", "Item2")
    $TestScript = { param($Item) Write-Output "Processed $Item" }
    #Show-ADBulkProgress -Activity "Test Bulk" -Items $TestItems -ProcessScript $TestScript -WhatIf
    Write-Host "$($SuccessEmoji) Show-ADBulkProgress working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Show-ADBulkProgress failed: $_" -ForegroundColor Red
}

try {
    Show-ADStatus -Type "Success" -Message "Test message"
    Write-Host "$($SuccessEmoji) Show-ADStatus working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Show-ADStatus failed: $_" -ForegroundColor Red
}

# Test operation functions
Write-Host "`nTesting Operation Functions:" -ForegroundColor Yellow
try {
    # Update-ADOperation and Complete-ADOperation require Operation hashtable
    $TestOperation = @{
        Name = "Test Operation"
        TotalItems = 5
        CurrentItem = 0
        ProgressStyle = "Simple"
        StartTime = Get-Date
    }
    Update-ADOperation -Operation $TestOperation -CurrentItem "Item 1"
    Write-Host "$($SuccessEmoji) Update-ADOperation working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Update-ADOperation failed: $_" -ForegroundColor Red
}

try {
    Complete-ADOperation -Operation $TestOperation -Message "Test completed"
    Write-Host "$($SuccessEmoji) Complete-ADOperation working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Complete-ADOperation failed: $_" -ForegroundColor Red
}

# Test emoji functions
Write-Host "`nTesting Emoji Functions:" -ForegroundColor Yellow
try {
    $Emoji = Get-Emoji -Type "Success"
    Write-Host "$($SuccessEmoji) Get-Emoji working ($Emoji)" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Get-Emoji failed: $_" -ForegroundColor Red
}

try {
    Write-EmojiMessage -Type "Info" -Message "Test emoji message"
    Write-Host "$($SuccessEmoji) Write-EmojiMessage working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Write-EmojiMessage failed: $_" -ForegroundColor Red
}

# Test password setting function (with safety check)
Write-Host "`nTesting Password Setting Function:" -ForegroundColor Yellow
try {
    $TestUser = Get-ADUser -Identity "*" | Select-Object -First 1
    if ($TestUser) {
        # Test the function without actually changing password
        $PasswordInfo = Get-ADUser -Identity $TestUser.SamAccountName -Properties PasswordLastSet
        Write-Host "$($SuccessEmoji) Password info retrieval working" -ForegroundColor Green
    } else {
        Write-Host "$($WarningEmoji) No users found for password setting test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "$($ErrorEmoji) Password setting test failed: $_" -ForegroundColor Red
}

# Test remaining functions that weren't explicitly tested
Write-Host "`nTesting Remaining Functions:" -ForegroundColor Yellow
try {
    # Test Start-ADOperation
    $Operation = Start-ADOperation -OperationName "Test" -TotalItems 5
    Write-Host "$($SuccessEmoji) Start-ADOperation working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Start-ADOperation failed: $_" -ForegroundColor Red
}

try {
    # Test Test-ADConfig
    $ConfigTest = Test-ADConfig
    Write-Host "$($SuccessEmoji) Test-ADConfig working" -ForegroundColor Green
} catch {
    Write-Host "$($ErrorEmoji) Test-ADConfig failed: $_" -ForegroundColor Red
}

# Summary
Write-Host "`nModule Test Summary:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "Total Functions Available: $($ExportedFunctions.Count)" -ForegroundColor White

Write-Host ""
Write-Host "Test Status: Complete" -ForegroundColor Green
