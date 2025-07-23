# Module.Tests.ps1
# Tests folder - Integration tests for the entire module

Describe "CSVActiveDirectory Module Integration" {
    BeforeAll {
        # Import the module
        Import-Module $PSScriptRoot\..\..\CSVActiveDirectory.psd1 -Force
    }
    
    Context "Module Loading" {
        It "Should import all expected functions" {
            $functions = Get-Command -Module CSVActiveDirectory
            $functions.Count | Should BeGreaterThan 10
            
            # Check for key functions using a different approach
            $functionNames = @($functions | ForEach-Object { $_.Name })
            $functionNames -contains "Get-ADUser" | Should Be $true
            $functionNames -contains "New-ADUser" | Should Be $true
            $functionNames -contains "Get-ADConfig" | Should Be $true
        }
        
        It "Should have proper module metadata" {
            $module = Get-Module CSVActiveDirectory
            $module.Version | Should Not BeNullOrEmpty
            $module.Description | Should Not BeNullOrEmpty
        }
    }
    
    Context "Configuration Management" {
        It "Should load configuration successfully" {
            $config = Get-ADConfig -ShowAll
            $config | Should Not BeNullOrEmpty
            $config.DomainSettings | Should Not BeNullOrEmpty
        }
        
        It "Should validate configuration" {
            $result = Test-ADConfig
            $result | Should Be $true
        }
    }
    
    Context "Database Operations" {
        It "Should read database successfully" {
            $users = Get-ADUser -Filter "Department -eq 'Security'"
            $users | Should Not BeNullOrEmpty
        }
        
        It "Should handle database errors gracefully" {
            # This would test error scenarios
            { Get-ADUser -Identity "invaliduser" } | Should Not Throw
        }
    }
    
    Context "Password Management" {
        It "Should validate password complexity" {
            $policy = Get-ADConfig -Section "PasswordPolicy"
            $result = Test-ADPasswordComplexity -Password "TestPass123!" -Config $policy
            $result.IsValid | Should Be $true
        }
        
        It "Should reject weak passwords" {
            $policy = Get-ADConfig -Section "PasswordPolicy"
            $result = Test-ADPasswordComplexity -Password "weak" -Config $policy
            $result.IsValid | Should Be $false
        }
    }
    
    Context "Progress and Status" {
        It "Should display progress indicators" {
            { Show-ADProgress -Activity "Test" -Completed } | Should Not Throw
        }
        
        It "Should display status messages" {
            { Show-ADStatus -Type "Info" -Message "Test message" } | Should Not Throw
        }
    }
} 