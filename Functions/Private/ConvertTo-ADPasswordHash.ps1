Function ConvertTo-ADPasswordHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Password
    )
    
    # Simulate AD NTLM hash (MD4 of Unicode password)
    # In real AD, this would be the actual NTLM hash
    # For simulation purposes, we'll use SHA256 with a salt
    
    $Salt = "ADSimulationSalt"
    $UnicodePassword = [System.Text.Encoding]::Unicode.GetBytes($Password)
    $SaltBytes = [System.Text.Encoding]::UTF8.GetBytes($Salt)
    
    $Combined = $UnicodePassword + $SaltBytes
    $Hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($Combined)
    
    return [Convert]::ToBase64String($Hash)
} 
