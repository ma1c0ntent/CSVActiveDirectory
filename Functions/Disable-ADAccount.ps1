Function Disable-ADAccount {
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
        $datetime = Get-Date
        $date = $datetime.ToShortDateString()
        $time = $datetime.ToShortTimeString()
    }
    Process {
            
        Foreach ($User in $Identity) {
            $FoundUser = $database | Where-Object { $_.SamAccountName -in $User }
            If ($FoundUser) {
                $FoundUser.Enabled = "FALSE"
                $FoundUser.Modified = "$date $time"
                $database | Export-Csv -Path "$PSScriptRoot\..\Database\database.csv" -NoTypeInformation
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
