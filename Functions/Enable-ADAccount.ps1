Function Enable-ADAccount {
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
            If ($FoundUser -AND $FoundUser.Enabled -eq "FALSE") {
                $FoundUser.Enabled = "TRUE"
                $FoundUser.Modified = "$date $time"

                If($PSBoundParameters.ContainsKey("Verbose")) {
                    Write-Verbose "Found user $($FoundUser.SamAccountName)"
                    Write-Verbose "User $($FoundUser.SamAccountName) currently disabled"
                    Write-Verbose "Enabling user $($FoundUser.SamAccountName)"
                    Write-Verbose "User $($FoundUser.SamAccountName) enabled"
                }
            }
            ElseIf($FoundUser -AND $FoundUser.Enabled -eq "TRUE") {
                Write-Warning "User $($FoundUser.SamAccountName) already enabled"
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
