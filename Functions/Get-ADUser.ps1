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
        [string]$SamAccountName = $FirstName.Substring(0, 1) + $LastName,

        

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match "^\w*\@\w*\.\w*$") {
                    return $true
                }
                Else {
                    throw "Email address is not valid"
                    
                }
            }
        )]
        [string]$EmailAddress,

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match "[a-zA-Z0-9]") {
                    return $true
                }
                Else {
                    throw "Employee ID must only contain alphanumeric characters"
                }
            }
        )]
        [string]$EmpID,
        
        [Parameter(Mandatory = $true, HelpMessage = "Enter the department: HR, Security, Accounting, Marketing, Sales")]
        [ValidateSet("HR", "Security", "Accounting", "Marketing", "Sales")]
        [string]$Department,
        
        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                If ($_ -match '^"' -or $_ -match "^'") {
                    throw "Job Title cannot contain quotes"
                }
                Else {
                    return $true
                }
            }
        )]
        [string]$JobTitle,

        [Parameter(Mandatory = $false)]
        [string]$Guid = [Guid]::NewGuid().ToString(),

        [Parameter(Mandatory = $false)]
        [string]$Enabled = "TRUE"
    )

    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\Database\database.csv"
        $datetime = Get-Date
        $date = $datetime.ToShortDateString()
        $time = $datetime.ToShortTimeString()
        
        $DC1 = $EmailAddress.Split("@")[1].Split(".")[0]
        $DC2 = $EmailAddress.Split("@")[1].Split(".")[1]
        
        $DistinguishedName = "CN=$LastName,$FirstName,OU=Users,OU=$Department,DC=$DC1,DC=$DC2"
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
            'JobTitle' = $JobTitle
            'Guid' = $Guid
            'Created' = "$date $time"
            'Modified' = "$date $time"
            'Enabled' = $Enabled
        }
        $Database += $NewUser
    }
    End {
        $Database | Export-Csv -Path "$PSScriptRoot\..\Database\database.csv" -NoTypeInformation
    }
}
