Function Get-ADConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path = "$PSScriptRoot\..\..\Data\Config\Settings.json",
        
        [Parameter(Mandatory = $false)]
        [string]$Section,
        
        [Parameter(Mandatory = $false)]
        [string]$Key,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowAll
    )
    
    Begin {
        $ConfigPath = $Path
        if (-not (Test-Path $ConfigPath)) {
            Write-Error "Configuration file not found: $ConfigPath"
            return
        }
    }
    
    Process {
        try {
            $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            
            if ($ShowAll) {
                return $Config
            }
            
            if ($Section -and $Key) {
                # Return specific key from specific section
                if ($Config.$Section.$Key) {
                    return $Config.$Section.$Key
                } else {
                    Write-Warning "Key '$Key' not found in section '$Section'"
                    return $null
                }
            }
            elseif ($Section) {
                # Return entire section
                if ($Config.$Section) {
                    return $Config.$Section
                } else {
                    Write-Warning "Section '$Section' not found"
                    return $null
                }
            }
            else {
                # Return entire config
                return $Config
            }
        }
        catch {
            Write-Error "Error reading configuration: $_"
            return $null
        }
    }
}

Function Set-ADConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path = "$PSScriptRoot\..\..\Data\Config\Settings.json",
        
        [Parameter(Mandatory = $true)]
        [string]$Section,
        
        [Parameter(Mandatory = $true)]
        [string]$Key,
        
        [Parameter(Mandatory = $true)]
        [object]$Value
    )
    
    Begin {
        $ConfigPath = $Path
        if (-not (Test-Path $ConfigPath)) {
            Write-Error "Configuration file not found: $ConfigPath"
            return
        }
    }
    
    Process {
        try {
            $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            
            # Create section if it doesn't exist
            if (-not $Config.$Section) {
                $Config | Add-Member -MemberType NoteProperty -Name $Section -Value @{}
            }
            
            # Set the value
            $Config.$Section.$Key = $Value
            
            # Save back to file
            $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath
            
            Write-Verbose "Configuration updated: $Section.$Key = $Value"
        }
        catch {
            Write-Error "Error updating configuration: $_"
        }
    }
}

Function Test-ADConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path = "$PSScriptRoot\..\..\Data\Config\Settings.json"
    )
    
    Begin {
        $ConfigPath = $Path
        $Issues = @()
    }
    
    Process {
        try {
            $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            
            # Test required sections
            $RequiredSections = @('DomainSettings', 'PasswordPolicy', 'Validation')
            foreach ($Section in $RequiredSections) {
                if (-not $Config.$Section) {
                    $Issues += "Missing required section: $Section"
                }
            }
            
            # Test domain settings
            if ($Config.DomainSettings) {
                if (-not $Config.DomainSettings.DomainName) {
                    $Issues += "Missing DomainName in DomainSettings"
                }
                if (-not $Config.DomainSettings.Departments) {
                    $Issues += "Missing Departments in DomainSettings"
                }
            }
            
            # Test password policy
            if ($Config.PasswordPolicy) {
                if ($Config.PasswordPolicy.MinimumLength -lt 1) {
                    $Issues += "Invalid MinimumLength in PasswordPolicy"
                }
                if ($Config.PasswordPolicy.MaximumLength -lt $Config.PasswordPolicy.MinimumLength) {
                    $Issues += "MaximumLength cannot be less than MinimumLength"
                }
            }
            
            if ($Issues.Count -eq 0) {
                Write-Host "Configuration validation passed" -ForegroundColor Green
                return $true
            } else {
                Write-Host "Configuration validation failed:" -ForegroundColor Red
                foreach ($Issue in $Issues) {
                    Write-Host "  - $Issue" -ForegroundColor Yellow
                }
                return $false
            }
        }
        catch {
            Write-Error "Error validating configuration: $_"
            return $false
        }
    }
} 
