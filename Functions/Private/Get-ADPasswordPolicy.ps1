Function Get-ADPasswordPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Section = "PasswordPolicy"
    )
    
    $Config = Get-ADConfig -Section $Section
    
    Write-Host "Password Policy Settings:" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    $Config | Get-Member -MemberType NoteProperty | ForEach-Object {
        $PropertyName = $_.Name
        $PropertyValue = $Config.$PropertyName
        
        switch ($PropertyName) {
            "RequireComplexity" { $DisplayName = "Complexity Required" }
            "RequireUppercase" { $DisplayName = "Uppercase Required" }
            "RequireLowercase" { $DisplayName = "Lowercase Required" }
            "RequireNumbers" { $DisplayName = "Numbers Required" }
            "RequireSpecialCharacters" { $DisplayName = "Special Characters Required" }
            "PasswordHistoryCount" { $DisplayName = "Password History Count" }
            "MinimumPasswordAge" { $DisplayName = "Minimum Password Age (days)" }
            "MaximumPasswordAge" { $DisplayName = "Maximum Password Age (days)" }
            "LockoutThreshold" { $DisplayName = "Account Lockout Threshold" }
            "LockoutDuration" { $DisplayName = "Account Lockout Duration (minutes)" }
            default { $DisplayName = $PropertyName }
        }
        
        Write-Host "  $DisplayName`: $PropertyValue" -ForegroundColor White
    }
} 
