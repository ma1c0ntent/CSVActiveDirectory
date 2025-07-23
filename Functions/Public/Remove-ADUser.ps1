Function Remove-ADUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        Position = 0,
        HelpMessage = "Enter the SamAccountName of the user"
        )]
        [string[]]$Identity,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    Begin {
        $database = Import-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv"
    }
    Process {
        Foreach ($User in $Identity) {
            $FoundUser = $database | Where-Object { $_.SamAccountName -in $User }
            If ($FoundUser) {
                if ($Force -or $PSCmdlet.ShouldProcess("User $($FoundUser.SamAccountName)", "Remove")) {
                $database = $database | Where-Object { $_.SamAccountName -notin $User }
                    Write-Verbose "Found user $($FoundUser.SamAccountName)"
                    Write-Verbose "Removing user $($FoundUser.SamAccountName)"
                    Write-Verbose "User $($FoundUser.SamAccountName) removed"
                    return "User $($FoundUser.SamAccountName) removed successfully"
                }
            }
            Else {
                Write-Warning "User not found"
                return "User not found"
            }
        }
    }
    End {
        $database | Export-Csv -Path "$PSScriptRoot\..\..\Data\Database\Database.csv" -NoTypeInformation
    }
}
