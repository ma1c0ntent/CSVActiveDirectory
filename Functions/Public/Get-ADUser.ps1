Function Get-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName = "Identity",
        ValueFromPipeline = $true,
        Position = 0,
        HelpMessage = "Enter the SamAccountName of the user"
        )]
        [string[]]$Identity,

        [Parameter(Mandatory = $true,
        ParameterSetName = "Filter")]
        [string]$Filter,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Properties
    )
    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv"
    }
    Process {
        If ($PSCmdlet.ParameterSetName -eq "Filter") {

            If ($Filter -eq "*") {
                if ($Properties) {
                    $users = $database | Select-Object -Property $Properties
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUserExtended")
                    }
                    return $users
                } else {
                    $users = $database | Select-Object FirstName, LastName, DisplayName, SamAccountName
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    return $users
                }
            }
            Else {
                $param1, $param2, $param3 = $filter.Split(' ')
                $Expression = "`$database | Where-Object { `$_.$param1 $param2 $param3}"
                $results = Invoke-Expression -Command $Expression
                if ($Properties) {
                    $users = $results | Select-Object -Property $Properties
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUserExtended")
                    }
                    return $users
                } else {
                    $users = $results | Select-Object FirstName, LastName, DisplayName, SamAccountName
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    return $users
                }
                Break
            }
        }
        Else {
            If ($Identity -and (-not($Properties))) {
                
                If ($Identity -eq "*") {
                    $users = $database | Select-Object FirstName, LastName, DisplayName, SamAccountName
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    return $users
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -match $Identity }
                If ($FoundUser) {
                    $User = [PSCustomObject] @{
                        'FirstName' = $FoundUser.'FirstName'
                        'LastName'  = $FoundUser.'LastName'
                        'DisplayName' = $FoundUser.'DisplayName'
                        'SamAccountName' = $FoundUser.'SamAccountName'
                    }
                    $User.PSTypeNames.Insert(0, "ADUser")
                    return $User
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
            ElseIf (($Identity -and $Properties)) {
                If ($Identity -eq "*") {
                    $users = $database | Select-Object -Property $Properties
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUserExtended")
                    }
                    return $users
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -in $Identity }
                If ($FoundUser) {
                    $users = $FoundUser | Select-Object -Property $Properties
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUserExtended")
                    }
                    return $users
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
        }
    }
}
