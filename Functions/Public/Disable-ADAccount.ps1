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
        $database = Import-Csv -Path "Data\Database\Database.csv"
    }
    Process {
        If ($PSCmdlet.ParameterSetName -eq "Filter") {

            If ($Filter -eq "*") {
                if ($Properties) {
                    $users = $database | Select-Object -Property $Properties
                    $ssers | Select-Object -Property $Properties
                } else {
                    $users = $database | Select-Object DistinguisedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    $Users | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    return
                }
            }
            Else {
                $param1, $param2, $param3 = $filter.Split(' ')
                $Expression = "`$database | Where-Object { `$_.$param1 $param2 $param3}"
                $results = Invoke-Expression -Command $Expression
                if ($Properties) {
                    $users = $results | Select-Object -Property $Properties
                    $users | Select-Object -Property $Properties
                } else {
                    $users = $results | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    $Users | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    return
                }
                Break
            }
        }
        Else {
            If ($Identity -and (-not($Properties))) {
                
                If ($Identity -eq "*") {
                    $users = $database | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    foreach ($user in $users) {
                        $user.PSTypeNames.Insert(0, "ADUser")
                    }
                    $Users | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    return
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -match $Identity }
                If ($FoundUser) {
                    $User = [PSCustomObject] @{
                        'DistinguishedName' = $FoundUser.'DistinguishedName'
                        'FirstName' = $FoundUser.'FirstName'
                        'LastName'  = $FoundUser.'LastName'
                        'DisplayName' = $FoundUser.'DisplayName'
                        'SamAccountName' = $FoundUser.'SamAccountName'
                        'Enabled' = $FoundUser.'Enabled'
                    }
                    $User.PSTypeNames.Insert(0, "ADUser")
                    
                    $User | Select-Object DistinguishedName, FirstName, LastName, DisplayName, SamAccountName, Enabled
                    return
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
            ElseIf (($Identity -and $Properties)) {
                If ($Identity -eq "*") {
                    $users = $database | Select-Object -Property $Properties
                    
                    $Users | Select-Object -Property $Properties
                    return
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -in $Identity }
                If ($FoundUser) {
                    $users = $FoundUser | Select-Object -Property $Properties

                    $Users | Select-Object -Property $Properties
                    return
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
        }
    }
}
