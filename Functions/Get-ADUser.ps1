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
        [string[]]$Filter,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Properties
    )
    Begin {
        $database = Import-Csv -Path '.\Database\database.csv'
    }
    Process {
        If ($PSCmdlet.ParameterSetName -eq "Filter") {

            If ($Filter -eq "*") {
                return $database | Select-Object FirstName, LastName, DisplayName, SamAccountName
            }
            Else {
                $param1, $param2, $param3 = $filter.Split(' ')
                $Expression = "`$database | Where-Object { `$_.$param1 $param2 $param3}"
                return Invoke-Expression -Command $Expression
                #return $result
                Break
            }
        }
        Else {
            If ($Identity -and (-not($Properties))) {
                
                If ($Identity -eq "*") {
                    return $database | Select-Object FirstName, LastName, DisplayName, SamAccountName
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -in $Identity }
                If ($FoundUser) {
                    $User = [PSCustomObject]@{
                        'First Name' = $FoundUser.'FirstName'
                        'Last Name'  = $FoundUser.'LastName'
                        'Display Name' = $FoundUser.'DisplayName'
                        'SamAccountName' = $FoundUser.'SamAccountName'
                    }
                    return $User
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
            ElseIf (($Identity -and $Properties)) {
                If ($Identity -eq "*") {
                    return $database | Select-Object -Property $Properties
                }
                
                $FoundUser = $database | Where-Object { $_.SamAccountName -in $Identity }
                If ($FoundUser) {
                    return $FoundUser | Select-Object -Property $Properties
                }
                Else {
                    Write-Warning "User not found"
                    Break
                }
            }
        }
    }
}
