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
                If ($_ -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
                    return $true
                }
                Else {
                    throw "Email: $emailAddress address is not valid"
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
        
        [Parameter(Mandatory = $false, HelpMessage = "Enter the department: HR, Security, Accounting, Marketing, Sales")]
        [ValidateSet("HR", "Security", "Accounting", "Marketing", "Sales")]
        [string]$Department,
        
        [Parameter(Mandatory = $false)]
        [string]$JobTitle,

        [Parameter(Mandatory = $false)]
        [string]$Guid = [Guid]::NewGuid().ToString(),

        [Parameter(Mandatory = $false)]
        [string]$Enabled = "TRUE"
    )

    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\Database\database.csv"
        
        If ($database | Where-Object { $_.EmpID -eq $EmpID -and $_.SamAccountName -match $SamAccountName }) {
            Write-Verbose "$FirstName $LastName already exists, skipping"
            Continue
        }
        
        ElseIf ( $database | Where-Object { $_.SamAccountName -eq $SamAccountName -and $_.EmpID -ne $EmpID }) {
            Write-Warning "$SamAccountName for $FirstName $LastName already exists, creating unique name"
            $num = $(Get-Random -Minimum 1 -Maximum 9001)
            $SamAccountName = $SamAccountName + $num
            $EmailAddress = $EmailAddress.Replace("@", "$num@")
            Write-Verbose "Changed to $SamAccountName"
            Write-Verbose "Email Address changed to $EmailAddress"
        }
        
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
            'Department' = $Department
            'Guid' = $Guid
            'Created' = "$date $time"
            'Modified' = "$date $time"
            'Enabled' = $Enabled
        }
    }
    End {
        $NewUser | Export-Csv -Path "$PSScriptRoot\..\Database\database.csv" -Append -NoTypeInformation
    }
}
