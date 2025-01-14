Function Remove-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0,
        HelpMessage = "Enter the SamAccountName of the user"
        )]
        [string[]]$Identity
    )
    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\Database\database.csv"
    }
    Process {
        Foreach ($User in $Identity) {
            $FoundUser = $database | Where-Object { $_.SamAccountName -in $User }
            If ($FoundUser) {
                $database = $database | Where-Object { $_.SamAccountName -notin $User }
                If($PSBoundParameters.ContainsKey("Verbose")) {
                    Write-Verbose "Found user $($FoundUser.SamAccountName)"
                    Write-Verbose "Removing user $($FoundUser.SamAccountName)"
                    Write-Verbose "User $($FoundUser.SamAccountName) removed"
                }
            }
            Else {
                Write-Warning "User not found"
            }
        }
    }
    End {
        $database | Export-Csv -Path "$PSScriptRoot\..\Database\database.csv" -NoTypeInformation
    }
}
