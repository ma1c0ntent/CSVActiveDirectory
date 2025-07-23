# Configuration Management Tests
# Tests for Get-ADConfig, Set-ADConfig, and Test-ADConfig functions

Describe "Configuration Management" {
    BeforeAll {
        Import-Module .\CSVActiveDirectory.psd1 -Force
    }

    Context "Get-ADConfig" {
        It "Should retrieve configuration successfully" {
            $Config = Get-ADConfig
            $Config | Should Not BeNullOrEmpty
        }

        It "Should retrieve specific section" {
            $PasswordPolicy = Get-ADConfig -Section "PasswordPolicy"
            $PasswordPolicy | Should Not BeNullOrEmpty
            $PasswordPolicy.MinimumLength | Should Not BeNullOrEmpty
        }

        It "Should handle non-existent section gracefully" {
            $NonExistentConfig = Get-ADConfig -Section "NonExistentSection"
            $NonExistentConfig | Should BeNullOrEmpty
        }

        It "Should return all sections when no section specified" {
            $AllConfig = Get-ADConfig
            $AllConfig | Should Not BeNullOrEmpty
            $AllConfig.PSObject.Properties.Name | Should Contain "PasswordPolicy"
        }
    }

    Context "Set-ADConfig" {
        BeforeEach {
            # Backup current config
            $OriginalConfig = Get-ADConfig
        }

        AfterEach {
            # Restore original config
            if ($OriginalConfig) {
                Set-ADConfig -Config $OriginalConfig
            }
        }

        It "Should update configuration successfully" {
            $CurrentConfig = Get-ADConfig
            $NewPasswordPolicy = @{
                MinimumLength = 10
                MaximumLength = 128
                RequireUppercase = $true
                RequireLowercase = $true
                RequireNumbers = $true
                RequireSpecialCharacters = $true
            }
            
            $CurrentConfig.PasswordPolicy = $NewPasswordPolicy
            Set-ADConfig -Config $CurrentConfig
            
            $UpdatedConfig = Get-ADConfig -Section "PasswordPolicy"
            $UpdatedConfig.MinimumLength | Should Be 10
        }

        It "Should handle null configuration" {
            { Set-ADConfig -Config $null } | Should Throw
        }

        It "Should validate configuration structure" {
            $InvalidConfig = @{
                InvalidSection = @{
                    InvalidProperty = "value"
                }
            }
            
            { Set-ADConfig -Config $InvalidConfig } | Should Not Throw
        }
    }

    Context "Test-ADConfig" {
        It "Should validate valid configuration" {
            $Config = Get-ADConfig
            $Result = Test-ADConfig -Config $Config
            $Result.IsValid | Should Be $true
        }

        It "Should detect invalid configuration" {
            $InvalidConfig = @{
                PasswordPolicy = @{
                    MinimumLength = -1  # Invalid value
                }
            }
            
            $Result = Test-ADConfig -Config $InvalidConfig
            $Result.IsValid | Should Be $false
            $Result.Issues.Count | Should BeGreaterThan 0
        }

        It "Should handle null configuration" {
            $Result = Test-ADConfig -Config $null
            $Result.IsValid | Should Be $false
        }

        It "Should validate password policy requirements" {
            $ValidConfig = @{
                PasswordPolicy = @{
                    MinimumLength = 8
                    MaximumLength = 128
                    RequireUppercase = $true
                    RequireLowercase = $true
                    RequireNumbers = $true
                    RequireSpecialCharacters = $true
                }
            }
            
            $Result = Test-ADConfig -Config $ValidConfig
            $Result.IsValid | Should Be $true
        }
    }

    Context "Configuration Integration" {
        It "Should handle complete configuration workflow: Get → Modify → Test → Set" {
            # Step 1: Get current configuration
            $OriginalConfig = Get-ADConfig
            $OriginalConfig | Should Not BeNullOrEmpty
            
            # Step 2: Modify configuration
            $ModifiedConfig = $OriginalConfig.Clone()
            $ModifiedConfig.PasswordPolicy.MinimumLength = 12
            
            # Step 3: Test modified configuration
            $TestResult = Test-ADConfig -Config $ModifiedConfig
            $TestResult.IsValid | Should Be $true
            
            # Step 4: Set modified configuration
            Set-ADConfig -Config $ModifiedConfig
            
            # Step 5: Verify changes
            $UpdatedConfig = Get-ADConfig -Section "PasswordPolicy"
            $UpdatedConfig.MinimumLength | Should Be 12
            
            # Step 6: Restore original configuration
            Set-ADConfig -Config $OriginalConfig
        }

        It "Should maintain configuration persistence" {
            $Config = Get-ADConfig
            $OriginalMinLength = $Config.PasswordPolicy.MinimumLength
            
            # Change configuration
            $Config.PasswordPolicy.MinimumLength = 15
            Set-ADConfig -Config $Config
            
            # Reload module to test persistence
            Remove-Module CSVActiveDirectory -Force -ErrorAction SilentlyContinue
            Import-Module .\CSVActiveDirectory.psd1 -Force
            
            # Verify configuration persisted
            $ReloadedConfig = Get-ADConfig -Section "PasswordPolicy"
            $ReloadedConfig.MinimumLength | Should Be 15
            
            # Restore original
            $Config.PasswordPolicy.MinimumLength = $OriginalMinLength
            Set-ADConfig -Config $Config
        }
    }

    Context "Configuration Validation" {
        It "Should validate password policy constraints" {
            $InvalidConfigs = @(
                @{ MinimumLength = -1 },
                @{ MaximumLength = 0 },
                @{ MinimumLength = 20; MaximumLength = 10 },
                @{ RequireUppercase = "invalid" }
            )
            
            foreach ($InvalidPolicy in $InvalidConfigs) {
                $TestConfig = @{
                    PasswordPolicy = $InvalidPolicy
                }
                
                $Result = Test-ADConfig -Config $TestConfig
                $Result.IsValid | Should Be $false
            }
        }

        It "Should accept valid password policy values" {
            $ValidConfig = @{
                PasswordPolicy = @{
                    MinimumLength = 8
                    MaximumLength = 128
                    RequireUppercase = $true
                    RequireLowercase = $true
                    RequireNumbers = $true
                    RequireSpecialCharacters = $true
                }
            }
            
            $Result = Test-ADConfig -Config $ValidConfig
            $Result.IsValid | Should Be $true
        }
    }
} 