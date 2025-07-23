Function Test-ADPasswordComplexity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Password,
        
        [Parameter(Mandatory = $true)]
        [object]$Config
    )
    
    $Issues = @()
    $IsValid = $true
    
    # Handle empty or null passwords
    if ([string]::IsNullOrEmpty($Password)) {
        $Issues += "Password cannot be empty or null"
        $IsValid = $false
        return @{
            IsValid = $IsValid
            Issues = $Issues
        }
    }
    
    # Check minimum length
    if ($Password.Length -lt $Config.MinimumLength) {
        $Issues += "Password must be at least $($Config.MinimumLength) characters long"
        $IsValid = $false
    }
    
    # Check maximum length
    if ($Password.Length -gt $Config.MaximumLength) {
        $Issues += "Password cannot exceed $($Config.MaximumLength) characters"
        $IsValid = $false
    }
    
    if ($Config.RequireComplexity) {
        # Check for uppercase letters
        if ($Config.RequireUppercase -and -not ($Password -cmatch '[A-Z]')) {
            $Issues += "Password must contain at least one uppercase letter"
            $IsValid = $false
        }
        
        # Check for lowercase letters
        if ($Config.RequireLowercase -and -not ($Password -cmatch '[a-z]')) {
            $Issues += "Password must contain at least one lowercase letter"
            $IsValid = $false
        }
        
        # Check for numbers
        if ($Config.RequireNumbers -and -not ($Password -match '\d')) {
            $Issues += "Password must contain at least one number"
            $IsValid = $false
        }
        
        # Check for special characters
        if ($Config.RequireSpecialCharacters) {
            $SpecialChars = if ($Config.AllowedSpecialCharacters) { 
                $Config.AllowedSpecialCharacters.ToCharArray() 
            } else { 
                "!@#$%^&*()_+-=[]{}|;:,.<>?".ToCharArray() 
            }
            $HasSpecialChar = $false
            foreach ($Char in $SpecialChars) {
                if ($Password.Contains($Char)) {
                    $HasSpecialChar = $true
                    break
                }
            }
            if (-not $HasSpecialChar) {
                $Issues += "Password must contain at least one special character"
                $IsValid = $false
            }
        }
    }
    
    return @{
        IsValid = $IsValid
        Issues = $Issues
    }
} 
