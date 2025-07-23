# Enable-Disable-ADAccount.Tests.ps1
# Tests for Enable-ADAccount and Disable-ADAccount functions

Describe "Enable-ADAccount" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "Parameter Validation" {
        It "Should accept Identity parameter" {
            # Create a test user first
            $TestUser = New-ADUser -SamAccountName "enabletest1" -FirstName "Enable" -LastName "Test" -EmailAddress "enabletest1@example.com"
            
            { Enable-ADAccount -Identity "enabletest1" } | Should Not Throw
            
            # Clean up
            Remove-ADUser -Identity "enabletest1" -Confirm:$false
        }

        It "Should require Identity parameter" {
            { Enable-ADAccount } | Should Throw
        }

        It "Should handle null Identity" {
            { Enable-ADAccount -Identity $null } | Should Throw
        }
    }

    Context "Functionality" {
        BeforeEach {
            # Create a test user
            $TestUser = New-ADUser -SamAccountName "enabletest2" -FirstName "Enable" -LastName "Test" -EmailAddress "enabletest2@example.com"
        }

        AfterEach {
            # Clean up test user
            $TestUser = Get-ADUser -Identity "enabletest2" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "enabletest2" -Confirm:$false
            }
        }

        It "Should enable a disabled account" {
            # First disable the account
            Disable-ADAccount -Identity "enabletest2"
            
            $User = Get-ADUser -Identity "enabletest2" -Properties *
            $User.Enabled | Should Be "FALSE"
            
            $Result = Enable-ADAccount -Identity "enabletest2"
            $Result | Should Not BeNullOrEmpty
            
            $UserAfter = Get-ADUser -Identity "enabletest2" -Properties *
            $UserAfter.Enabled | Should Be "TRUE"
        }

        It "Should enable an already enabled account" {
            $User = Get-ADUser -Identity "enabletest2" -Properties *
            $User.Enabled | Should Be "TRUE"
            
            $Result = Enable-ADAccount -Identity "enabletest2"
            $Result | Should Not BeNullOrEmpty
            
            $UserAfter = Get-ADUser -Identity "enabletest2" -Properties *
            $UserAfter.Enabled | Should Be "TRUE"
        }

        It "Should handle non-existent user gracefully" {
            { Enable-ADAccount -Identity "nonexistentuser" } | Should Not Throw
        }

        It "Should return confirmation when account is enabled" {
            $Result = Enable-ADAccount -Identity "enabletest2"
            $Result | Should Not BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "Should handle empty Identity" {
            { Enable-ADAccount -Identity "" } | Should Throw
        }
    }
}

Describe "Disable-ADAccount" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "Parameter Validation" {
        It "Should accept Identity parameter" {
            # Create a test user first
            $TestUser = New-ADUser -SamAccountName "disabletest1" -FirstName "Disable" -LastName "Test" -EmailAddress "disabletest1@example.com"
            
            { Disable-ADAccount -Identity "disabletest1" } | Should Not Throw
            
            # Clean up
            Remove-ADUser -Identity "disabletest1" -Confirm:$false
        }

        It "Should require Identity parameter" {
            { Disable-ADAccount } | Should Throw
        }

        It "Should handle null Identity" {
            { Disable-ADAccount -Identity $null } | Should Throw
        }
    }

    Context "Functionality" {
        BeforeEach {
            # Create a test user
            $TestUser = New-ADUser -SamAccountName "disabletest2" -FirstName "Disable" -LastName "Test" -EmailAddress "disabletest2@example.com"
        }

        AfterEach {
            # Clean up test user
            $TestUser = Get-ADUser -Identity "disabletest2" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "disabletest2" -Confirm:$false
            }
        }

        It "Should disable an enabled account" {
            $User = Get-ADUser -Identity "disabletest2" -Properties *
            $User.Enabled | Should Be "TRUE"
            
            $Result = Disable-ADAccount -Identity "disabletest2"
            $Result | Should Not BeNullOrEmpty
            
            $UserAfter = Get-ADUser -Identity "disabletest2" -Properties *
            $UserAfter.Enabled | Should Be "FALSE"
        }

        It "Should handle non-existent user gracefully" {
            { Disable-ADAccount -Identity "nonexistentuser" } | Should Not Throw
        }

        It "Should return confirmation when account is disabled" {
            $Result = Disable-ADAccount -Identity "disabletest2"
            $Result | Should Not BeNullOrEmpty
        }
    }

    Context "Error Handling" {
        It "Should handle empty Identity" {
            { Disable-ADAccount -Identity "" } | Should Throw
        }
    }
}

Describe "Enable-Disable Integration" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "State Management" {
        BeforeEach {
            # Create a test user
            $TestUser = New-ADUser -SamAccountName "statetest" -FirstName "State" -LastName "Test" -EmailAddress "statetest@example.com"
        }

        AfterEach {
            # Clean up test user
            $TestUser = Get-ADUser -Identity "statetest" -ErrorAction SilentlyContinue
            if ($TestUser) {
                Remove-ADUser -Identity "statetest" -Confirm:$false
            }
        }

        It "Should maintain correct state through enable/disable cycles" {
            # Initial state should be enabled
            $User = Get-ADUser -Identity "statetest" -Properties *
            $User.Enabled | Should Be "TRUE"
            
            # Disable the account
            Disable-ADAccount -Identity "statetest"
            $UserAfterDisable = Get-ADUser -Identity "statetest" -Properties *
            $UserAfterDisable.Enabled | Should Be "FALSE"
            
            # Re-enable the account
            Enable-ADAccount -Identity "statetest"
            $UserAfterEnable = Get-ADUser -Identity "statetest" -Properties *
            $UserAfterEnable.Enabled | Should Be "TRUE"
            
            # Verify final state
            $OriginalUser = Get-ADUser -Identity "statetest" -Properties *
            $OriginalUser.Enabled | Should Be "TRUE"
        }

        It "Should handle multiple state changes" {
            # Test multiple enable/disable cycles
            for ($i = 1; $i -le 3; $i++) {
                Disable-ADAccount -Identity "statetest"
                $UserAfterToggle = Get-ADUser -Identity "statetest" -Properties *
                $UserAfterToggle.Enabled | Should Be "FALSE"
                
                Enable-ADAccount -Identity "statetest"
                $UserAfterToggle = Get-ADUser -Identity "statetest" -Properties *
                $UserAfterToggle.Enabled | Should Be "TRUE"
            }
        }
    }
} 