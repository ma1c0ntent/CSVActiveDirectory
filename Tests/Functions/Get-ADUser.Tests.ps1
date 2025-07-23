# Get-ADUser.Tests.ps1
# Tests folder - Pester test for Get-ADUser function

Describe "Get-ADUser" {
    BeforeAll {
        # Import the module
        Import-Module $PSScriptRoot\..\..\CSVActiveDirectory.psd1 -Force
    }
    
    Context "Parameter Validation" {
        It "Should accept Identity parameter" {
            { Get-ADUser -Identity "testuser" } | Should Not Throw
        }
        
        It "Should accept Filter parameter" {
            { Get-ADUser -Filter "SamAccountName -eq 'testuser'" } | Should Not Throw
        }
        
        It "Should require parameters" {
            # The function should throw ParameterBindingException when no parameters provided
            try {
                Get-ADUser -ErrorAction Stop
                $false | Should Be $true  # This should not be reached
            }
            catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingException"
            }
        }
    }
    
    Context "Functionality" {
        It "Should return user when valid Identity provided" {
            $result = Get-ADUser -Identity "mbryan"
            $result | Should Not BeNullOrEmpty
            $result.SamAccountName | Should Be "mbryan"
        }
        
        It "Should return null when user not found" {
            $result = Get-ADUser -Identity "nonexistentuser"
            $result | Should BeNullOrEmpty
        }
        
        It "Should return multiple users when Filter provided" {
            $result = Get-ADUser -Filter "Department -eq 'Security'"
            $result | Should Not BeNullOrEmpty
            $result.Count | Should BeGreaterThan 0
        }
    }
    
    Context "Error Handling" {
        It "Should handle null Identity gracefully" {
            # The function should throw ParameterBindingValidationException for null Identity
            try {
                Get-ADUser -Identity $null -ErrorAction Stop
                $false | Should Be $true  # This should not be reached
            }
            catch {
                $_.Exception.GetType().Name | Should Be "ParameterBindingValidationException"
            }
        }
        
        It "Should handle invalid Filter gracefully" {
            $result = Get-ADUser -Filter "InvalidFilter"
            $result | Should BeNullOrEmpty
        }
    }
} 