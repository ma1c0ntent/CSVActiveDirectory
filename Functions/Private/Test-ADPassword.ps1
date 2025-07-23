Function Test-ADPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SamAccountName,
        
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$Password
    )
    
    $database = Import-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv"
    $User = $database | Where-Object { $_.SamAccountName -eq $SamAccountName }
    
    if ($User) {
        # Convert SecureString to plain text
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        # Generate hash for comparison
        $InputHash = ConvertTo-ADPasswordHash -Password $PlainPassword
        
        # Clear plain text from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        
        if ($User.PasswordHash -eq $InputHash) {
            return $true
        } else {
            return $false
        }
    } else {
        Write-Warning "User $SamAccountName not found"
        return $false
    }
} 
