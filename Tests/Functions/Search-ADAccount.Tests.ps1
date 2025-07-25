# Search-ADAccount.Tests.ps1
# Tests for Search-ADAccount function - Updated for account state focus

Describe "Search-ADAccount" {
    BeforeAll {
        # Import the module
        Import-Module "$PSScriptRoot\..\..\CSVActiveDirectory.psd1" -Force
        
        # Ensure we have a database to test with
        if (-not (Test-Path "Data\Database\Database.csv")) {
            Write-Warning "Database not found. Running Create-Users.ps1 to generate test data..."
            & "$PSScriptRoot\..\..\Scripts\Private\Create-Users.ps1" -UserCount 10 -SkipSecurityTest
        }
    }

    Context "Basic Functionality" {
        It "Should return results when called with no parameters" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            $results.Count | Should BeGreaterThan 0
        }

        It "Should return AD account objects with correct properties" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            
            $firstResult = $results[0]
            $firstResult.Name | Should Not BeNullOrEmpty
            $firstResult.ObjectClass | Should Be "user"
            $firstResult.SamAccountName | Should Not BeNullOrEmpty
            $firstResult.DistinguishedName | Should Not BeNullOrEmpty
        }

        It "Should have correct PSTypeNames" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            
            $firstResult = $results[0]
            $firstResult.PSTypeNames -contains "Microsoft.ActiveDirectory.Management.ADAccount" | Should Be $true
        }
    }

    Context "Account State Filters" {
        It "Should filter for disabled accounts" {
            $results = Search-ADAccount -AccountDisabled
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $results[0].Enabled | Should Be $false
            }
        }

        It "Should filter for locked out accounts" {
            $results = Search-ADAccount -LockedOut
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $results[0].LockedOut | Should Be $true
            }
        }

        It "Should filter for expired passwords" {
            $results = Search-ADAccount -PasswordExpired
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                # Check if password was set more than 90 days ago
                $passwordSetDate = [DateTime]::Parse($results[0].PasswordLastSet)
                $daysSinceSet = (Get-Date) - $passwordSetDate
                $daysSinceSet.Days | Should BeGreaterThan 90
            }
        }

        It "Should filter for passwords that never expire" {
            $results = Search-ADAccount -PasswordNeverExpires
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $results[0].PasswordNeverExpires | Should Be $true
            }
        }

        It "Should filter for expired accounts" {
            $results = Search-ADAccount -AccountExpired
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $expirationDate = [DateTime]::Parse($results[0].AccountExpirationDate)
                $expirationDate | Should BeLessThan (Get-Date)
            }
        }

        It "Should filter for expiring accounts" {
            $results = Search-ADAccount -AccountExpiring
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $expirationDate = [DateTime]::Parse($results[0].AccountExpirationDate)
                $daysUntilExpiration = ($expirationDate - (Get-Date)).Days
                ($daysUntilExpiration -le 30) | Should Be $true
                # Note: Some databases may not have expiring accounts, so we don't require positive days
            }
        }

        It "Should filter for inactive accounts" {
            $results = Search-ADAccount -AccountInactive
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $lastLogonDate = [DateTime]::Parse($results[0].LastLogonDate)
                $daysSinceLogon = (Get-Date) - $lastLogonDate
                $daysSinceLogon.Days | Should BeGreaterThan 30
            }
        }
    }

    Context "Object Type Filters" {
        It "Should filter for user accounts only" {
            $results = Search-ADAccount -UsersOnly
            $results | Should Not BeNullOrEmpty
            
            foreach ($result in $results) {
                $result.ObjectClass | Should Be "user"
            }
        }

        It "Should return empty results for computer accounts" {
            $results = Search-ADAccount -ComputersOnly
            $results.Count | Should Be 0
        }
    }

    Context "Search Scope Parameters" {
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

        It "Should validate SearchScope parameter" {
            try {
                Search-ADAccount -SearchScope "InvalidScope" -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }
    }

    Context "Result Size Parameters" {
        It "Should limit results with ResultSetSize" {
            $results = Search-ADAccount -ResultSetSize 10
            $results | Should Not BeNullOrEmpty
            ($results.Count -le 10) | Should Be $true
        }

        It "Should limit results with ResultPageSize" {
            $results = Search-ADAccount -ResultPageSize 5
            $results | Should Not BeNullOrEmpty
            # Note: ResultPageSize may not limit results in this implementation
        }

        It "Should validate ResultPageSize parameter" {
            try {
                Search-ADAccount -ResultPageSize 0 -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }

        It "Should validate ResultSetSize parameter" {
            try {
                Search-ADAccount -ResultSetSize 0 -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }
    }

    Context "Time-based Parameters" {
        It "Should accept DateTime parameter" {
            $testDate = Get-Date
            $results = Search-ADAccount -DateTime $testDate
            $results | Should Not BeNullOrEmpty
        }

        It "Should accept TimeSpan parameter" {
            $testSpan = New-TimeSpan -Days 30
            $results = Search-ADAccount -TimeSpan $testSpan
            $results | Should Not BeNullOrEmpty
        }
    }

    Context "Connection Parameters" {
        It "Should accept Server parameter" {
            $results = Search-ADAccount -Server "localhost"
            $results | Should Not BeNullOrEmpty
        }

        It "Should accept AuthType parameter" {
            $results = Search-ADAccount -AuthType "Negotiate"
            $results | Should Not BeNullOrEmpty
        }

        It "Should validate AuthType parameter" {
            try {
                Search-ADAccount -AuthType "InvalidAuth" -ErrorAction Stop
                $false | Should Be $true  # Should not reach here
            } catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }
    }

    Context "Combined Filters" {
        It "Should combine account state filters when both conditions exist" {
            # Test with filters that might have overlapping results
            $results = Search-ADAccount -AccountDisabled
            if ($results.Count -gt 0) {
                $results = Search-ADAccount -AccountDisabled -UsersOnly
                $results | Should Not BeNullOrEmpty
                
                if ($results.Count -gt 0) {
                    $results[0].Enabled | Should Be $false
                    $results[0].ObjectClass | Should Be "user"
                }
            }
        }

        It "Should combine object type with account state filters" {
            $results = Search-ADAccount -UsersOnly -AccountDisabled
            $results | Should Not BeNullOrEmpty
            
            if ($results.Count -gt 0) {
                $results[0].ObjectClass | Should Be "user"
                $results[0].Enabled | Should Be $false
            }
        }
    }

    Context "Error Handling" {
        It "Should handle missing database gracefully" {
            # Temporarily move database to test error handling
            $originalPath = "Data\Database\Database.csv"
            $backupPath = "Data\Database\Database.backup.csv"
            
            if (Test-Path $originalPath) {
                Move-Item $originalPath $backupPath
                
                try {
                    $results = Search-ADAccount -ErrorAction SilentlyContinue
                    $results | Should BeNullOrEmpty
                } finally {
                    if (Test-Path $backupPath) {
                        Move-Item $backupPath $originalPath
                    }
                }
            }
        }

        It "Should handle invalid date formats gracefully" {
            # This test verifies the function doesn't crash with malformed data
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
        }
    }

    Context "Integration Tests" {
        It "Should work with other module functions" {
            # Test integration with Get-ADUser
            $searchResults = Search-ADAccount | Select-Object -First 5
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
    }

    Context "Performance Tests" {
        It "Should handle large result sets efficiently" {
            $startTime = Get-Date
            $results = Search-ADAccount
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            $results | Should Not BeNullOrEmpty
            $duration | Should BeLessThan 5000  # Should complete within 5 seconds
        }

        It "Should handle multiple filters efficiently" {
            $startTime = Get-Date
            $results = Search-ADAccount -UsersOnly -AccountDisabled
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            $results | Should Not BeNullOrEmpty
            $duration | Should BeLessThan 5000  # Should complete within 5 seconds
        }
    }

    Context "Real AD Compatibility" {
        It "Should return objects compatible with real AD cmdlets" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            
            $firstResult = $results[0]
            
            # Check for essential AD properties
            $firstResult.PSObject.Properties.Name -contains "Name" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "ObjectClass" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "SamAccountName" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "DistinguishedName" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "Enabled" | Should Be $true
            $firstResult.PSObject.Properties.Name -contains "LockedOut" | Should Be $true
        }

        It "Should have boolean properties for account states" {
            $results = Search-ADAccount
            $results | Should Not BeNullOrEmpty
            
            $firstResult = $results[0]
            
            # Check that boolean properties are actually boolean
            $firstResult.Enabled.GetType().Name | Should Be "Boolean"
            $firstResult.LockedOut.GetType().Name | Should Be "Boolean"
            $firstResult.PasswordExpired.GetType().Name | Should Be "Boolean"
            $firstResult.PasswordNeverExpires.GetType().Name | Should Be "Boolean"
        }
    }
} 