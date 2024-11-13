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
        $database = Import-Csv -Path '.\Database\database.csv'
    }
    Process {
        Foreach ($User in $Identity) {
            $FoundUser = $database | Where-Object { $_.SamAccountName -in $User }
            If ($FoundUser) {
                Write-Host "Removing $($FoundUser.SamAccountName)"
                $database = $database | Where-Object { $_.SamAccountName -notin $User }
            }
            Else {
                Write-Warning "User not found"
            }
        }
    }
    End {
        $database | Export-Csv -Path '.\Database\database.csv' -NoTypeInformation
    }
}
