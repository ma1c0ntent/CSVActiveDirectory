# New-ADUser Tests
# Tests for the New-ADUser function

Describe "New-ADUser" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "Parameter Validation" {
        It "Should accept required parameters" {
            { New-ADUser -SamAccountName "testuser" -FirstName "Test" -LastName "User" -EmailAddress "test@example.com" } | Should Not Throw
        }

        It "Should require FirstName parameter" {
            { New-ADUser -SamAccountName "testuser" -LastName "User" -EmailAddress "test@example.com" } | Should Throw
        }

        It "Should require LastName parameter" {
            { New-ADUser -SamAccountName "testuser" -FirstName "Test" -EmailAddress "test@example.com" } | Should Throw
        }

        It "Should require EmailAddress parameter" {
            { New-ADUser -SamAccountName "testuser" -FirstName "Test" -LastName "User" } | Should Throw
        }
    }

    Context "Functionality" {
        BeforeEach {
            # Clean up any existing test user
            $TestUser = Get-ADUser -Identity "testuser123" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "testuser123" -Force
            }
        }

        AfterEach {
            # Clean up test user
            $TestUser = Get-ADUser -Identity "testuser123" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "testuser123" -Force
            }
        }

        It "Should create a new user successfully" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result | Should Not BeNullOrEmpty
            $Result.SamAccountName | Should Be "testuser123"
            $Result.FirstName | Should Be "Test"
            $Result.LastName | Should Be "User"
            $Result.EmailAddress | Should Be "test123@example.com"
            $Result.Enabled | Should Be "TRUE"
        }

        It "Should generate DisplayName from FirstName and LastName" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.DisplayName | Should Be "Test User"
        }

        It "Should generate DistinguishedName" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.DistinguishedName | Should Not BeNullOrEmpty
            $Result.DistinguishedName | Should Match "CN=User,Test"
        }

        It "Should generate UserPrincipalName" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.UserPrincipalName | Should Be "testuser123@adnauseumgaming.com"
        }

        It "Should generate SID" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.SID | Should Not BeNullOrEmpty
            $Result.SID | Should Match "S-1-5-21-"
        }

        It "Should set default values" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.PrimaryGroupID | Should Be "513"
            $Result.PasswordNeverExpires | Should Be "FALSE"
            $Result.CannotChangePassword | Should Be "FALSE"
            $Result.SmartCardRequired | Should Be "FALSE"
            $Result.Company | Should Be "AdNauseum Gaming"
        }

        It "Should set Created and Modified dates" {
            $Result = New-ADUser -SamAccountName "testuser123" -FirstName "Test" -LastName "User" -EmailAddress "test123@example.com"
            
            $Result.Created | Should Not BeNullOrEmpty
            $Result.Modified | Should Not BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "Should handle duplicate SamAccountName by creating unique name" {
            # Create first user
            New-ADUser -SamAccountName "duplicateuser" -FirstName "First" -LastName "User" -EmailAddress "first@example.com" | Out-Null
            
            # Try to create duplicate - should create unique name instead of throwing
            { New-ADUser -SamAccountName "duplicateuser" -FirstName "Second" -LastName "User" -EmailAddress "second@example.com" } | Should Not Throw
            
            # Clean up
            Remove-ADUser -Identity "duplicateuser" -Force
            Remove-ADUser -Identity "duplicateuser*" -Force
        }

        It "Should handle invalid email format" {
            { New-ADUser -SamAccountName "testuser" -FirstName "Test" -LastName "User" -EmailAddress "invalid-email" } | Should Throw
        }

        It "Should handle null parameters" {
            { New-ADUser -SamAccountName $null -FirstName "Test" -LastName "User" -EmailAddress "test@example.com" } | Should Throw
        }
    }

    Context "Optional Parameters" {
        BeforeEach {
            # Clean up any existing test user
            $TestUser = Get-ADUser -Identity "testuser456" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "testuser456" -Force
            }
        }

        AfterEach {
            # Clean up test user
            $TestUser = Get-ADUser -Identity "testuser456" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "testuser456" -Force
            }
        }

        It "Should accept optional parameters" {
            $Result = New-ADUser -SamAccountName "testuser456" -FirstName "Test" -LastName "User" -EmailAddress "test456@example.com" -Title "Developer" -Department "Security"
            
            $Result.Title | Should Be "Developer"
            $Result.Department | Should Be "Security"
        }

        It "Should use default department when not specified" {
            $Result = New-ADUser -SamAccountName "testuser456" -FirstName "Test" -LastName "User" -EmailAddress "test456@example.com"
            
            $Result.Department | Should Be "Security"
        }
    }
} 