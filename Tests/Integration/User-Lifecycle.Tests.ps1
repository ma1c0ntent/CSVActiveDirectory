# User-Lifecycle.Tests.ps1
# Integration tests for user lifecycle operations

Describe "User Lifecycle Integration" {
    BeforeAll {
        # Import the module
        Import-Module $PSScriptRoot\..\..\CSVActiveDirectory.psd1 -Force
    }
    
    Context "Complete User Lifecycle" {
        It "Should handle full user lifecycle (create, retrieve, disable, enable, remove)" {
            # Step 1: Create new user
            $NewUser = New-ADUser -SamAccountName "lifecycletest" -FirstName "Lifecycle" -LastName "Test" -EmailAddress "lifecycletest@example.com" -Department "Security" -Title "Developer"
            $NewUser | Should Not BeNullOrEmpty
            $NewUser.Enabled | Should Be "TRUE"
            
            # Step 2: Verify user exists and can be retrieved
            $RetrievedUser = Get-ADUser -Identity "lifecycletest" -Properties *
            $RetrievedUser | Should Not BeNullOrEmpty
            $RetrievedUser.DisplayName | Should Be "Lifecycle Test"
            $RetrievedUser.Title | Should Be "Developer"
            $RetrievedUser.Department | Should Be "Security"
            
            # Step 3: Disable account
            Disable-ADAccount -Identity "lifecycletest"
            $DisabledUser = Get-ADUser -Identity "lifecycletest" -Properties *
            $DisabledUser.Enabled | Should Be "FALSE"
            
            # Step 4: Re-enable account
            Enable-ADAccount -Identity "lifecycletest"
            $ReEnabledUser = Get-ADUser -Identity "lifecycletest" -Properties *
            $ReEnabledUser.Enabled | Should Be "TRUE"
            
            # Step 5: Remove user
            Remove-ADUser -Identity "lifecycletest" -Confirm:$false
            
            # Step 6: Verify user no longer exists
            $RemovedUser = Get-ADUser -Identity "lifecycletest" -ErrorAction SilentlyContinue
            $RemovedUser | Should BeNullOrEmpty
        }

        It "Should handle multiple users in parallel" {
            # Create multiple users
            $Users = @()
            for ($i = 1; $i -le 3; $i++) {
                $User = New-ADUser -SamAccountName "paralleltest$i" -FirstName "Parallel$i" -LastName "Test" -EmailAddress "paralleltest$i@example.com"
                $Users += $User
            }
            
            # Verify all users were created
            $Users.Count | Should Be 3
            
            # Verify all users can be retrieved
            foreach ($User in $Users) {
                $RetrievedUser = Get-ADUser -Identity $User.SamAccountName -Properties *
                $RetrievedUser | Should Not BeNullOrEmpty
            }
            
            # Disable all users
            foreach ($User in $Users) {
                Disable-ADAccount -Identity $User.SamAccountName
                $DisabledUser = Get-ADUser -Identity $User.SamAccountName -Properties *
                $DisabledUser.Enabled | Should Be "FALSE"
            }
            
            # Re-enable all users
            foreach ($User in $Users) {
                Enable-ADAccount -Identity $User.SamAccountName
                $EnabledUser = Get-ADUser -Identity $User.SamAccountName -Properties *
                $EnabledUser.Enabled | Should Be "TRUE"
            }
            
            # Remove all users
            foreach ($User in $Users) {
                Remove-ADUser -Identity $User.SamAccountName -Confirm:$false
                $RemovedUser = Get-ADUser -Identity $User.SamAccountName -ErrorAction SilentlyContinue
                $RemovedUser | Should BeNullOrEmpty
            }
        }
    }

    Context "User Search and Filtering" {
        BeforeEach {
            # Create test users with different departments
            New-ADUser -SamAccountName "searchtest1" -FirstName "Search1" -LastName "Test" -EmailAddress "searchtest1@example.com" -Department "Security" | Out-Null
            New-ADUser -SamAccountName "searchtest2" -FirstName "Search2" -LastName "Test" -EmailAddress "searchtest2@example.com" -Department "HR" | Out-Null
            New-ADUser -SamAccountName "searchtest3" -FirstName "Search3" -LastName "Test" -EmailAddress "searchtest3@example.com" -Department "Security" | Out-Null
        }

        AfterEach {
            # Clean up test users
            @("searchtest1", "searchtest2", "searchtest3") | ForEach-Object {
                $User = Get-ADUser -Identity $_ -ErrorAction SilentlyContinue
                if ($User) {
                    Remove-ADUser -Identity $_ -Confirm:$false
                }
            }
        }

        It "Should find users by department filter" {
            $SecurityUsers = Get-ADUser -Filter "Department -eq 'Security'" -Properties *
            $SecurityUsers.Count | Should BeGreaterThan 0
            
            foreach ($User in $SecurityUsers) {
                $User.Department | Should Be "Security"
            }
        }

        It "Should find specific user by Identity" {
            $User = Get-ADUser -Identity "searchtest1" -Properties *
            $User | Should Not BeNullOrEmpty
            $User.SamAccountName | Should Be "searchtest1"
        }

        It "Should handle wildcard searches" {
            $SearchUsers = Get-ADUser -Identity "searchtest*" -Properties *
            $SearchUsers.Count | Should Be 3
            
            foreach ($User in $SearchUsers) {
                $User.SamAccountName | Should Match "searchtest"
            }
        }
    }

    Context "Data Integrity" {
        It "Should maintain data integrity across operations" {
            # Create user with specific data
            $OriginalUser = New-ADUser -SamAccountName "integritytest" -FirstName "Integrity" -LastName "Test" -EmailAddress "integritytest@example.com" -Department "Security" -Title "Analyst"
            
            # Verify original data
            $OriginalUser | Should Not BeNullOrEmpty
            $OriginalUser.FirstName | Should Be "Integrity"
            $OriginalUser.LastName | Should Be "Test"
            $OriginalUser.Department | Should Be "Security"
            $OriginalUser.Title | Should Be "Analyst"
            
            # Retrieve and verify data integrity
            $RetrievedUser = Get-ADUser -Identity "integritytest" -Properties *
            $RetrievedUser | Should Not BeNullOrEmpty
            $RetrievedUser.FirstName | Should Be "Integrity"
            $RetrievedUser.LastName | Should Be "Test"
            $RetrievedUser.Department | Should Be "Security"
            $RetrievedUser.Title | Should Be "Analyst"
            
            # Clean up
            Remove-ADUser -Identity "integritytest" -Confirm:$false
        }
    }

    Context "Account Status Changes" {
        BeforeEach {
            # Create test user
            $OriginalUser = New-ADUser -SamAccountName "statustest" -FirstName "Status" -LastName "Test" -EmailAddress "statustest@example.com" -Department "Security" -Title "Analyst"
            $OriginalUser | Should Not BeNullOrEmpty
        }

        AfterEach {
            # Clean up test user
            $User = Get-ADUser -Identity "statustest" -ErrorAction SilentlyContinue
            if ($User) {
                Remove-ADUser -Identity "statustest" -Confirm:$false
            }
        }

        It "Should properly track account status changes" {
            # Verify original state
            $OriginalUser.Title | Should Be "Analyst"
            $OriginalUser.Enabled | Should Be "TRUE"
            
            # Disable account
            Disable-ADAccount -Identity "statustest"
            $DisabledUser = Get-ADUser -Identity "statustest" -Properties *
            $DisabledUser.Enabled | Should Be "FALSE"
            
            # Re-enable account
            Enable-ADAccount -Identity "statustest"
            $ReEnabledUser = Get-ADUser -Identity "statustest" -Properties *
            $ReEnabledUser.Enabled | Should Be "TRUE"
            
            # Verify final state
            $RetrievedUser = Get-ADUser -Identity "statustest" -Properties *
            $RetrievedUser.Title | Should Be "Analyst"
        }
    }
} 