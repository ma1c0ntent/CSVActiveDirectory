# Test-ADPasswordComplexity.Tests.ps1
# Tests folder - Pester test for Test-ADPasswordComplexity function

Describe "Test-ADPasswordComplexity" {
    BeforeAll {
        # Import the module
        Import-Module $PSScriptRoot\..\..\CSVActiveDirectory.psd1 -Force
        
        # Get password policy for testing
        $script:PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
    }
    
    Context "Password Validation" {
        It "Should accept strong passwords" {
            $result = Test-ADPasswordComplexity -Password "StrongP@ssw0rd123!" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $true
            $result.Issues | Should BeNullOrEmpty
        }
        
        It "Should reject weak passwords" {
            $result = Test-ADPasswordComplexity -Password "weak" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues | Should Not BeNullOrEmpty
        }
        
        It "Should reject passwords without uppercase" {
            $result = Test-ADPasswordComplexity -Password "password123!" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password must contain at least one uppercase letter" | Should Be $true
        }
        
        It "Should reject passwords without lowercase" {
            $result = Test-ADPasswordComplexity -Password "PASSWORD123!" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password must contain at least one lowercase letter" | Should Be $true
        }
        
        It "Should reject passwords without numbers" {
            $result = Test-ADPasswordComplexity -Password "Password!" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password must contain at least one number" | Should Be $true
        }
        
        It "Should reject passwords without special characters" {
            $result = Test-ADPasswordComplexity -Password "Password123" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password must contain at least one special character" | Should Be $true
        }
        
        It "Should reject passwords that are too short" {
            $result = Test-ADPasswordComplexity -Password "Ab1!" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password must be at least 8 characters long" | Should Be $true
        }
        
        It "Should reject passwords that are too long" {
            $longPassword = "A" * 200 + "b1!"
            $result = Test-ADPasswordComplexity -Password $longPassword -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
            $result.Issues -contains "Password cannot exceed 128 characters" | Should Be $true
        }
    }
    
    Context "Edge Cases" {
        It "Should handle empty password" {
            $result = Test-ADPasswordComplexity -Password "" -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
        }
        
        It "Should handle null password" {
            $result = Test-ADPasswordComplexity -Password $null -Config $script:PasswordPolicy
            $result.IsValid | Should Be $false
        }
    }
} 