Function Set-ADAccountPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0,
        HelpMessage = "Enter the SamAccountName of the user"
        )]
        [string[]]$Identity,
        
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$NewPassword,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force,
        
        [Parameter(Mandatory = $false)]
        [switch]$ChangePasswordAtLogon
    )
    
    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv"
        $Config = Get-ADConfig -Section "PasswordPolicy"
        $datetime = Get-Date
        $date = $datetime.ToShortDateString()
        $time = $datetime.ToShortTimeString()
    }
    
    Process {
        foreach ($User in $Identity) {
            $FoundUser = $database | Where-Object { $_.SamAccountName -in $User }
            
            if ($FoundUser) {
                # Convert SecureString to plain text for validation
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword)
                $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                
                # Validate password complexity
                $ValidationResult = Test-ADPasswordComplexity -Password $PlainPassword -Config $Config
                
                if ($ValidationResult.IsValid -or $Force) {
                    if (-not $ValidationResult.IsValid) {
                        Write-Warning "Password complexity requirements not met, but continuing due to -Force"
                        Write-Host "Issues found:" -ForegroundColor Yellow
                        foreach ($Issue in $ValidationResult.Issues) {
                            Write-Host "  - $Issue" -ForegroundColor Yellow
                        }
                    }
                    
                    # Hash the password (simulating AD NTLM hash)
                    $PasswordHash = ConvertTo-ADPasswordHash -Password $PlainPassword
                    
                    # Update user password (simulating password change)
                    $FoundUser.PasswordLastSet = "$date $time"
                    
                    Write-Verbose "Password updated for user $($FoundUser.SamAccountName)"
                    Show-ADStatus -Type "Success" -Message "Password updated for $($FoundUser.DisplayName)"
                } else {
                    Write-Error "Password complexity requirements not met:"
                    foreach ($Issue in $ValidationResult.Issues) {
                        Write-Host "  - $Issue" -ForegroundColor Red
                    }
                }
                
                # Clear the plain text password from memory
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            } else {
                Write-Warning "User $User not found"
            }
        }
    }
    
    End {
        $database | Export-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv" -NoTypeInformation
    }
}

 
