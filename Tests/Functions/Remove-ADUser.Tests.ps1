# Remove-ADUser Tests
# Tests for the Remove-ADUser function

Describe "Remove-ADUser" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "Parameter Validation" {
        It "Should accept Identity parameter" {
            # Create a test user first
            $TestUser = New-ADUser -SamAccountName "removetest1" -FirstName "Remove" -LastName "Test" -EmailAddress "removetest1@example.com"
            
            { Remove-ADUser -Identity "removetest1" -Confirm:$false } | Should Not Throw
            
            # Verify user was removed
            $RemovedUser = Get-ADUser -Identity "removetest1" -ErrorAction SilentlyContinue
            $RemovedUser | Should BeNullOrEmpty
        }

        It "Should require Identity parameter" {
            { Remove-ADUser } | Should Throw
        }

        It "Should handle null Identity" {
            { Remove-ADUser -Identity $null } | Should Throw
        }
    }

    Context "Functionality" {
        BeforeEach {
            # Create a test user for each test
            $TestUser = New-ADUser -SamAccountName "removetest2" -FirstName "Remove" -LastName "Test" -EmailAddress "removetest2@example.com"
        }

        It "Should remove existing user successfully" {
            # Verify user exists
            $ExistingUser = Get-ADUser -Identity "removetest2"
            $ExistingUser | Should Not BeNullOrEmpty
            
            # Remove user
            Remove-ADUser -Identity "removetest2" -Confirm:$false
            
            # Verify user was removed
            $RemovedUser = Get-ADUser -Identity "removetest2" -ErrorAction SilentlyContinue
            $RemovedUser | Should BeNullOrEmpty
        }

        It "Should handle non-existent user gracefully" {
            { Remove-ADUser -Identity "nonexistentuser" -Confirm:$false } | Should Not Throw
        }

        It "Should return confirmation when user is removed" {
            $Result = Remove-ADUser -Identity "removetest2" -Confirm:$false
            $Result | Should Not BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "Should handle empty Identity" {
            { Remove-ADUser -Identity "" } | Should Throw
        }

        It "Should handle invalid Identity format" {
            { Remove-ADUser -Identity "invalid@user" -Confirm:$false } | Should Not Throw
        }
    }

    Context "Integration with Get-ADUser" {
        BeforeEach {
            # Create a test user
            $TestUser = New-ADUser -SamAccountName "integrationtest" -FirstName "Integration" -LastName "Test" -EmailAddress "integrationtest@example.com"
        }

        AfterEach {
            # Clean up in case test fails
            $TestUser = Get-ADUser -Identity "integrationtest" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "integrationtest" -Confirm:$false
            }
        }

        It "Should remove user that can be retrieved by Get-ADUser" {
            # Verify user exists via Get-ADUser
            $UserBefore = Get-ADUser -Identity "integrationtest"
            $UserBefore | Should Not BeNullOrEmpty
            
            # Remove user
            Remove-ADUser -Identity "integrationtest" -Confirm:$false
            
            # Verify user no longer exists via Get-ADUser
            $UserAfter = Get-ADUser -Identity "integrationtest" -ErrorAction SilentlyContinue
            $UserAfter | Should BeNullOrEmpty
        }
    }
} 