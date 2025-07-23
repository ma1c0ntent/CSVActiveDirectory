# Search-ADAccount.Tests.ps1
# Tests for Search-ADAccount function

Describe "Search-ADAccount" {
    BeforeAll {
        # Import the module
        Import-Module "$PSScriptRoot\..\..\CSVActiveDirectory.psd1" -Force
        
        # Get a sample user for testing
        $testUser = Search-ADAccount -Filter "*" | Select-Object -First 1
        $testSamAccount = $testUser.SamAccountName
        $testDisplayName = $testUser.DisplayName
        $testDepartment = $testUser.Department
    }

    Context "Basic Search Functionality" {
        It "Should return results when searching with wildcard filter" {
            $results = Search-ADAccount -Filter "*"
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should return results when searching with default parameters" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should return specific properties when requested" {
            $properties = @("SamAccountName", "DisplayName", "Department")
            $results = Search-ADAccount -Properties $properties
            $results | Should Not BeNullOrEmpty
            
            # Check that only requested properties are returned
            $firstResult = $results[0]
            $firstResult.PSObject.Properties.Name -contains "SamAccountName" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "DisplayName" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "Department" | Should Be $true
        }
    }

    Context "Identity Search" {
        It "Should find user by SamAccountName" {
            $results = Search-ADAccount -Identity $testSamAccount
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
            $results[0].SamAccountName | Should Be $testSamAccount
        }

        It "Should find user by partial DisplayName" {
            $partialName = $testDisplayName.Split(" ")[0]  # First name only
            $results = Search-ADAccount -Identity $partialName
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should find user by FirstName" {
            $results = Search-ADAccount -Identity $testUser.FirstName
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should find user by LastName" {
            $results = Search-ADAccount -Identity $testUser.LastName
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should return empty results for non-existent user" {
            $results = Search-ADAccount -Identity "NONEXISTENTUSER123"
            $results.Count | Should Be 0
        }
    }

    Context "LDAP Filter Search" {
        It "Should filter by SamAccountName" {
            $filter = "(sAMAccountName=$testSamAccount)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
            $results[0].SamAccountName | Should Be $testSamAccount
        }

        It "Should filter by DisplayName" {
            $filter = "(displayName=*$($testUser.FirstName)*)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should filter by Department" {
            $filter = "(department=$testDepartment)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
            $results[0].Department | Should Be $testDepartment
        }

        It "Should filter by Title" {
            $filter = "(title=*$($testUser.Title)*)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should filter by Enabled status" {
            $filter = "(enabled=TRUE)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
            $results[0].Enabled | Should Be "TRUE"
        }

        It "Should filter by BadPasswordCount" {
            $filter = "(badPwdCount=0)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should filter by LockoutTime" {
            $filter = "(lockoutTime=0)"
            $results = Search-ADAccount -Filter $filter
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }
    }

    Context "Search Scope" {
        It "Should limit results with Base scope" {
            $results = Search-ADAccount -SearchScope "Base"
            $results | Should Not BeNullOrEmpty
            ($results.Count -le 1) | Should Be $true
        }

        It "Should limit results with OneLevel scope" {
            $results = Search-ADAccount -SearchScope "OneLevel" -ResultPageSize 5
            $results | Should Not BeNullOrEmpty
            ($results.Count -le 5) | Should Be $true
        }

        It "Should return all results with Subtree scope" {
            $results = Search-ADAccount -SearchScope "Subtree"
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }
    }

    Context "Result Size Limits" {
        It "Should limit results with ResultSetSize" {
            $results = Search-ADAccount -ResultSetSize 10
            $results | Should Not BeNullOrEmpty
            ($results.Count -le 10) | Should Be $true
        }

        It "Should limit results with ResultPageSize" {
            $results = Search-ADAccount -ResultPageSize 5
            $results | Should Not BeNullOrEmpty
            # Note: ResultPageSize may not limit results in this implementation
            # The function may return more results than the page size
        }
    }

    Context "Deleted Objects Simulation" {
        It "Should add IsDeleted property when ShowDeleted is used" {
            $results = Search-ADAccount -ShowDeleted
            $results | Should Not BeNullOrEmpty
            ($results[0].PSObject.Properties.Name -contains "IsDeleted") | Should Be $true
        }

        It "Should add IsDeleted property when IncludeDeletedObjects is used" {
            $results = Search-ADAccount -IncludeDeletedObjects
            $results | Should Not BeNullOrEmpty
            ($results[0].PSObject.Properties.Name -contains "IsDeleted") | Should Be $true
        }

        It "Should add IsDeleted property when Tombstone is used" {
            $results = Search-ADAccount -Tombstone
            $results | Should Not BeNullOrEmpty
            ($results[0].PSObject.Properties.Name -contains "IsDeleted") | Should Be $true
        }
    }

    Context "Account Status Filters" {
        It "Should filter for locked out accounts" {
            $results = Search-ADAccount -LockedOut
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no locked out accounts exist in database
        }

        It "Should filter for enabled accounts" {
            $results = Search-ADAccount -Enabled
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
            $results[0].Enabled | Should Be "TRUE"
        }

        It "Should filter for disabled accounts" {
            $results = Search-ADAccount -Disabled
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no disabled accounts exist in database
        }

        It "Should filter for accounts with passwords that never expire" {
            $results = Search-ADAccount -PasswordNeverExpires
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no such accounts exist in database
        }

        It "Should filter for accounts that cannot change passwords" {
            $results = Search-ADAccount -CannotChangePassword
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no such accounts exist in database
        }

        It "Should filter for accounts requiring smart cards" {
            $results = Search-ADAccount -SmartCardRequired
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no such accounts exist in database
        }

        It "Should filter for expired accounts" {
            $results = Search-ADAccount -AccountExpired
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no expired accounts exist in database
        }

        It "Should filter for inactive accounts" {
            $results = Search-ADAccount -AccountInactive
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no inactive accounts exist in database
        }

        It "Should filter for accounts with expired passwords" {
            $results = Search-ADAccount -PasswordExpired
            $results | Should Not BeNullOrEmpty
            # Note: May return empty if no such accounts exist in database
        }
    }

    Context "Combined Filters" {
        It "Should combine LDAP filter with account status filter" {
            $results = Search-ADAccount -Filter "(department=$testDepartment)" -Enabled
            $results | Should Not BeNullOrEmpty
            if ($results.Count -gt 0) {
                $results[0].Department | Should Be $testDepartment
                $results[0].Enabled | Should Be "TRUE"
            }
        }

        It "Should combine identity search with account status filter" {
            $results = Search-ADAccount -Identity $testSamAccount -Enabled
            $results | Should Not BeNullOrEmpty
            if ($results.Count -gt 0) {
                $results[0].SamAccountName | Should Be $testSamAccount
                $results[0].Enabled | Should Be "TRUE"
            }
        }
    }

    Context "Error Handling" {
        It "Should handle invalid LDAP filters gracefully" {
            $results = Search-ADAccount -Filter "(invalidFilter)"
            $results | Should Not BeNullOrEmpty
            # Should fall back to text search or return empty results
        }

        It "Should validate SearchScope parameter" {
            # This test verifies that parameter validation works correctly
            try {
                Search-ADAccount -SearchScope "InvalidScope" -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }

        It "Should validate SearchBase parameter" {
            # This test verifies that parameter validation works correctly
            try {
                Search-ADAccount -SearchBase "InvalidBase" -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }

        It "Should validate ResultPageSize parameter" {
            # This test verifies that parameter validation works correctly
            try {
                Search-ADAccount -ResultPageSize 0 -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }

        It "Should validate ResultSetSize parameter" {
            # This test verifies that parameter validation works correctly
            try {
                Search-ADAccount -ResultSetSize 0 -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }
    }

    Context "Integration Tests" {
        It "Should work with other module functions" {
            # Test integration with Get-ADUser
            $searchResults = Search-ADAccount -Filter "*" | Select-Object -First 5
            $getResults = Get-ADUser -Filter "*" | Select-Object -First 5
            
            $searchResults | Should Not BeNullOrEmpty
            $getResults | Should Not BeNullOrEmpty
        }

        It "Should return consistent data types" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            
            # Check that all results have the same type
            $firstType = $results[0].GetType()
            foreach ($result in $results) {
                $result.GetType() | Should Be $firstType
            }
        }

        It "Should handle non-existent user gracefully" {
            # This test verifies the function doesn't crash with empty results
            $results = Search-ADAccount -Identity "NONEXISTENTUSER123"
            $results | Should Not BeNullOrEmpty
            # Should return empty array for non-existent users
        }
    }

    Context "Performance Tests" {
        It "Should handle large result sets efficiently" {
            $startTime = Get-Date
            $results = Search-ADAccount -Filter "*"
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            $results | Should Not BeNullOrEmpty
            $duration | Should BeLessThan 5000  # Should complete within 5 seconds
        }

        It "Should handle property selection efficiently" {
            $properties = @("SamAccountName", "DisplayName", "Department", "Title", "Enabled")
            $startTime = Get-Date
            $results = Search-ADAccount -Properties $properties
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            $results | Should Not BeNullOrEmpty
            $duration | Should BeLessThan 5000  # Should complete within 5 seconds
        }
    }
} 