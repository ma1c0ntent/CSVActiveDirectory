Function New-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match "[a-zA-Z]") {
                    return $true
                }
                Else {
                    throw "First name must only contain alphabetic characters"
                }
            }
        )]
        [string]$FirstName,

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match "[a-zA-Z]") {
                    return $true
                }
                Else {
                    throw "Last name must only contain alphabetic characters"
                }
            }
        )]
        [string]$LastName,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName = "$FirstName $LastName",

        [Parameter(Mandatory = $false)]
        [string]$SamAccountName = $FirstName.Substring(0, 1).ToLower() + $LastName.ToLower(),

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
                    return $true
                }
                Else {
                    throw "Email address is not valid"
                }
            }
        )]
        [string]$EmailAddress,

        [Parameter(Mandatory = $false)]
        [string]$EmpID,
        
        [Parameter(Mandatory = $false, HelpMessage = "Enter the department: HR, Security, Accounting, Marketing, Sales, IT, Engineering, Operations")]
        [ValidateSet("HR", "Security", "Accounting", "Marketing", "Sales", "IT", "Engineering", "Operations")]
        [string]$Department = "Security",
        
        [Parameter(Mandatory = $false)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [string]$Guid = [Guid]::NewGuid().ToString(),

        [Parameter(Mandatory = $false)]
        [string]$Enabled = "TRUE"
    )

    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv"
        
        # Check if user already exists
        If ($database | Where-Object { $_.SamAccountName -eq $SamAccountName }) {
            Write-Warning "$SamAccountName already exists, creating unique name"
            $num = $(Get-Random -Minimum 1 -Maximum 9001)
            $SamAccountName = $SamAccountName + $num
            $EmailAddress = $EmailAddress.Replace("@", "$num@")
            Write-Verbose "Changed to $SamAccountName"
            Write-Verbose "Email Address changed to $EmailAddress"
        }
        
        $datetime = Get-Date
        $date = $datetime.ToString("M/d/yyyy h:mm tt")
        
        $DC1 = $EmailAddress.Split("@")[1].Split(".")[0]
        $DC2 = $EmailAddress.Split("@")[1].Split(".")[1]
        
        $DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=$DC1,DC=$DC2"
        
        # Generate SID
        $SIDNumber = 1000 + $database.Count + 1
        $SID = "S-1-5-21-1234567890-1234567890-1234567890-$SIDNumber"
        
        # Generate UPN
        $UPN = "$SamAccountName@adnauseumgaming.com"
        
        # Determine office location based on department
        $Office = switch ($Department) {
            "Security" { "Building A, Floor 2" }
            "Accounting" { "Building B, Floor 1" }
            "Marketing" { "Building C, Floor 1" }
            "HR" { "Building D, Floor 1" }
            "Sales" { "Building E, Floor 1" }
            "IT" { "Building F, Floor 1" }
            "Engineering" { "Building G, Floor 1" }
            "Operations" { "Building H, Floor 1" }
            default { "Building A, Floor 1" }
        }
        
        # Generate phone numbers
        $PhoneNumber = "555-" + (1000 + $database.Count + 1).ToString("0000")
        $Mobile = "555-" + (2000 + $database.Count + 1).ToString("0000")
        
        # Generate EmpID according to settings.json pattern (XX####)
        if (-not $EmpID) {
            $Letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            $FirstLetter = $Letters[(Get-Random -Minimum 0 -Maximum 26)]
            $SecondLetter = $Letters[(Get-Random -Minimum 0 -Maximum 26)]
            $Numbers = (Get-Random -Minimum 1000 -Maximum 9999).ToString("0000")
            $EmpID = "$FirstLetter$SecondLetter$Numbers"
        }
    }
    
    Process {
        $NewUser = [PSCustomObject] @{
            'FirstName' = $FirstName
            'LastName' = $LastName
            'DisplayName' = $DisplayName
            'SamAccountName' = $SamAccountName.ToLower()
            'DistinguishedName' = $DistinguishedName
            'EmailAddress' = $EmailAddress
            'EmpID' = $EmpID
            'Title' = $Title
            'Department' = $Department
            'Guid' = $Guid
            'Created' = $date
            'Modified' = $date
            'Enabled' = $Enabled
            'UserPrincipalName' = $UPN
            'SID' = $SID
            'PrimaryGroupID' = "513"
            'PasswordLastSet' = $date
            'LastLogonDate' = ""
            'AccountExpirationDate' = ""
            'LockoutTime' = ""
            'LockedOut' = "FALSE"
            'LogonCount' = "0"
            'BadPasswordCount' = "0"
            'PasswordNeverExpires' = "FALSE"
            'CannotChangePassword' = "FALSE"
            'SmartCardRequired' = "FALSE"
            'Manager' = ""
            'Office' = $Office
            'PhoneNumber' = $PhoneNumber
            'Mobile' = $Mobile
            'Company' = "AdNauseum Gaming"
            # AD-like properties
            'whenCreated' = $date
            'whenChanged' = $date
            'pwdLastSet' = $date
            'accountExpires' = ""
        }
    }
    
    End {
        $NewUser | Export-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv" -Append -NoTypeInformation
        $NewUser.PSTypeNames.Insert(0, "ADUser")
        return $NewUser
    }
}
