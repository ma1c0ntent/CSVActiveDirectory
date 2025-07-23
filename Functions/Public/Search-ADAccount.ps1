Function Search-ADAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
        Position = 0,
        HelpMessage = "LDAP filter to search for accounts"
        )]
        [string]$Filter = "*",

        [Parameter(Mandatory = $false,
        Position = 1,
        HelpMessage = "Search by account identity (SamAccountName, DisplayName, or Email)"
        )]
        [string]$Identity,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Base", "OneLevel", "Subtree")]
        [string]$SearchScope = "Subtree",

        [Parameter(Mandatory = $false)]
        [ValidateSet("All", "Users", "Computers", "Groups")]
        [string]$SearchBase = "Users",

        [Parameter(Mandatory = $false)]
        [string[]]$Properties,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 1000)]
        [int]$ResultPageSize = 100,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10000)]
        [int]$ResultSetSize = 1000,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeDeletedObjects,

        [Parameter(Mandatory = $false)]
        [switch]$Tombstone,

        [Parameter(Mandatory = $false)]
        [switch]$ShowDeleted,

        [Parameter(Mandatory = $false)]
        [string]$Server,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory = $false)]
        [switch]$AuthType,

        [Parameter(Mandatory = $false)]
        [switch]$UseSSL,

        [Parameter(Mandatory = $false)]
        [switch]$LockedOut,

        [Parameter(Mandatory = $false)]
        [switch]$AccountExpired,

        [Parameter(Mandatory = $false)]
        [switch]$AccountInactive,

        [Parameter(Mandatory = $false)]
        [switch]$PasswordExpired,

        [Parameter(Mandatory = $false)]
        [switch]$PasswordNeverExpires,

        [Parameter(Mandatory = $false)]
        [switch]$AllowReversiblePasswordEncryption,

        [Parameter(Mandatory = $false)]
        [switch]$CannotChangePassword,

        [Parameter(Mandatory = $false)]
        [switch]$DoesNotRequirePreAuth,

        [Parameter(Mandatory = $false)]
        [switch]$TrustedForDelegation,

        [Parameter(Mandatory = $false)]
        [switch]$TrustedToAuthForDelegation,

        [Parameter(Mandatory = $false)]
        [switch]$UseDESKeyOnly,

        [Parameter(Mandatory = $false)]
        [switch]$SmartCardRequired,

        [Parameter(Mandatory = $false)]
        [switch]$NotDelegated,

        [Parameter(Mandatory = $false)]
        [switch]$Enabled,

        [Parameter(Mandatory = $false)]
        [switch]$Disabled
    )

    Begin {
        # Load database
        $databasePath = "$PSScriptRoot\..\..\Data\Database\Database.csv"
        if (Test-Path $databasePath) {
            $database = Import-Csv -Path $databasePath
        } else {
            Write-Error "Database file not found at: $databasePath"
            return
        }

        # Initialize search results
        $searchResults = @()
        
        Write-Verbose "Search-ADAccount: Starting search with scope '$SearchScope' and base '$SearchBase'"
    }

    Process {
        try {
            # Handle different search scenarios
            if ($Identity) {
                Write-Verbose "Search-ADAccount: Searching by identity '$Identity'"
                $searchResults = Search-ByIdentity -Database $database -Identity $Identity -Properties $Properties
            } else {
                Write-Verbose "Search-ADAccount: Searching with filter '$Filter'"
                $searchResults = Search-ByFilter -Database $database -Filter $Filter -Properties $Properties
            }

            # Apply account-specific filters
            $searchResults = Apply-AccountFilters -Results $searchResults -Params $PSBoundParameters

            # Apply search scope limitations
            if ($SearchScope -eq "Base") {
                Write-Verbose "Search-ADAccount: Limiting to base scope (first result only)"
                $searchResults = $searchResults | Select-Object -First 1
            } elseif ($SearchScope -eq "OneLevel") {
                Write-Verbose "Search-ADAccount: Limiting to one level scope"
                $searchResults = $searchResults | Select-Object -First $ResultPageSize
            }

            # Apply result size limits
            if ($ResultSetSize -lt $searchResults.Count) {
                Write-Verbose "Search-ADAccount: Limiting results to $ResultSetSize"
                $searchResults = $searchResults | Select-Object -First $ResultSetSize
            }

            # Handle deleted objects (simulated)
            if ($ShowDeleted -or $IncludeDeletedObjects -or $Tombstone) {
                Write-Verbose "Search-ADAccount: Including deleted objects (simulated)"
                foreach ($result in $searchResults) {
                    $result | Add-Member -MemberType NoteProperty -Name "IsDeleted" -Value $false -Force
                }
            }

            # Apply custom properties if specified
            if ($Properties) {
                $searchResults = $searchResults | Select-Object -Property $Properties
            }

            # Add type information
            foreach ($result in $searchResults) {
                if ($Properties) {
                    $result.PSTypeNames.Insert(0, "ADAccountExtended")
                } else {
                    $result.PSTypeNames.Insert(0, "ADAccount")
                }
            }

            Write-Verbose "Search-ADAccount: Found $($searchResults.Count) results"
            return $searchResults

        } catch {
            Write-Error "Search-ADAccount: Error during search - $($_.Exception.Message)"
            return $null
        }
    }

    End {
        Write-Verbose "Search-ADAccount: Search completed"
    }
}

# Helper function to search by identity
Function Search-ByIdentity {
    param(
        [array]$Database,
        [string]$Identity,
        [string[]]$Properties
    )

    $results = @()

    # Search by SamAccountName (exact match)
    $samResults = $Database | Where-Object { $_.SamAccountName -eq $Identity }
    if ($samResults) {
        $results += $samResults
    }

    # Search by DisplayName (contains)
    $displayResults = $Database | Where-Object { $_.DisplayName -like "*$Identity*" }
    if ($displayResults) {
        $results += $displayResults
    }

    # Search by FirstName or LastName (contains)
    $nameResults = $Database | Where-Object { 
        $_.FirstName -like "*$Identity*" -or $_.LastName -like "*$Identity*" 
    }
    if ($nameResults) {
        $results += $nameResults
    }

    # Search by Email (contains)
    $emailResults = $Database | Where-Object { $_.EmailAddress -like "*$Identity*" }
    if ($emailResults) {
        $results += $emailResults
    }

    # Remove duplicates
    $results = $results | Sort-Object SamAccountName -Unique

    return $results
}

# Helper function to search by LDAP filter
Function Search-ByFilter {
    param(
        [array]$Database,
        [string]$Filter,
        [string[]]$Properties
    )

    $results = @()

    # Handle common LDAP filter patterns
    if ($Filter -eq "*") {
        $results = $Database
    } elseif ($Filter -like "*(sAMAccountName=*)*") {
        # Extract SamAccountName from filter
        if ($Filter -match "sAMAccountName=([^)]+)") {
            $samAccount = $matches[1]
            $results = $Database | Where-Object { $_.SamAccountName -like "*$samAccount*" }
        }
    } elseif ($Filter -like "*(displayName=*)*") {
        # Extract DisplayName from filter
        if ($Filter -match "displayName=([^)]+)") {
            $displayName = $matches[1]
            $results = $Database | Where-Object { $_.DisplayName -like "*$displayName*" }
        }
    } elseif ($Filter -like "*(department=*)*") {
        # Extract Department from filter
        if ($Filter -match "department=([^)]+)") {
            $department = $matches[1]
            $results = $Database | Where-Object { $_.Department -like "*$department*" }
        }
    } elseif ($Filter -like "*(title=*)*") {
        # Extract Title from filter
        if ($Filter -match "title=([^)]+)") {
            $title = $matches[1]
            $results = $Database | Where-Object { $_.Title -like "*$title*" }
        }
    } elseif ($Filter -like "*(enabled=*)*") {
        # Extract Enabled status from filter
        if ($Filter -match "enabled=([^)]+)") {
            $enabled = $matches[1]
            $results = $Database | Where-Object { $_.Enabled -eq $enabled }
        }
    } elseif ($Filter -like "*(badPwdCount*)*") {
        # Extract BadPasswordCount from filter
        if ($Filter -match "badPwdCount([^)]+)") {
            $badPwdCount = $matches[1]
            if ($badPwdCount -like ">=*") {
                $value = $badPwdCount.Substring(2)
                $results = $Database | Where-Object { [int]$_.BadPasswordCount -ge [int]$value }
            } elseif ($badPwdCount -like "=*") {
                $value = $badPwdCount.Substring(1)
                $results = $Database | Where-Object { [int]$_.BadPasswordCount -eq [int]$value }
            } else {
                $results = $Database | Where-Object { [int]$_.BadPasswordCount -ge [int]$badPwdCount }
            }
        }
    } elseif ($Filter -like "*(lockoutTime=*)*") {
        # Extract LockoutTime from filter
        if ($Filter -match "lockoutTime=([^)]+)") {
            $lockoutTime = $matches[1]
            if ($lockoutTime -eq "0") {
                $results = $Database | Where-Object { $_.LockoutTime -eq "" -and $_.LockedOut -eq "FALSE" }
            } else {
                $results = $Database | Where-Object { $_.LockoutTime -ne "" -or $_.LockedOut -eq "TRUE" }
            }
        }
    } elseif ($Filter -like "*(lockedOut=*)*") {
        # Extract LockedOut status from filter
        if ($Filter -match "lockedOut=([^)]+)") {
            $lockedOut = $matches[1]
            if ($lockedOut -eq "TRUE") {
                $results = $Database | Where-Object { $_.LockedOut -eq "TRUE" }
            } else {
                $results = $Database | Where-Object { $_.LockedOut -eq "FALSE" }
            }
        }
    } else {
        # Fallback to simple text search across all fields
        $results = $Database | Where-Object {
            $_.SamAccountName -like "*$Filter*" -or
            $_.DisplayName -like "*$Filter*" -or
            $_.FirstName -like "*$Filter*" -or
            $_.LastName -like "*$Filter*" -or
            $_.Department -like "*$Filter*" -or
            $_.Title -like "*$Filter*" -or
            $_.EmailAddress -like "*$Filter*"
        }
    }

    return $results
}

# Helper function to apply account-specific filters
Function Apply-AccountFilters {
    param(
        [array]$Results,
        [hashtable]$Params
    )

    $filteredResults = $Results

    # LockedOut filter
    if ($Params.LockedOut) {
        Write-Verbose "Search-ADAccount: Filtering for locked out accounts only"
        $filteredResults = $filteredResults | Where-Object { 
            $_.LockedOut -eq "TRUE" -or $_.LockoutTime -ne "" 
        }
    }

    # AccountExpired filter
    if ($Params.AccountExpired) {
        Write-Verbose "Search-ADAccount: Filtering for expired accounts only"
        $filteredResults = $filteredResults | Where-Object { 
            $_.AccountExpires -ne "" -and $_.AccountExpires -ne "NEVER" 
        }
    }

    # AccountInactive filter
    if ($Params.AccountInactive) {
        Write-Verbose "Search-ADAccount: Filtering for inactive accounts only"
        $filteredResults = $filteredResults | Where-Object { 
            $_.LastLogon -eq "" -or [DateTime]::Parse($_.LastLogon) -lt (Get-Date).AddDays(-30)
        }
    }

    # PasswordExpired filter
    if ($Params.PasswordExpired) {
        Write-Verbose "Search-ADAccount: Filtering for expired passwords only"
        $filteredResults = $filteredResults | Where-Object { 
            $_.PasswordLastSet -ne "" -and [DateTime]::Parse($_.PasswordLastSet) -lt (Get-Date).AddDays(-90)
        }
    }

    # PasswordNeverExpires filter
    if ($Params.PasswordNeverExpires) {
        Write-Verbose "Search-ADAccount: Filtering for accounts with passwords that never expire"
        $filteredResults = $filteredResults | Where-Object { $_.PasswordNeverExpires -eq "TRUE" }
    }

    # Enabled filter
    if ($Params.Enabled) {
        Write-Verbose "Search-ADAccount: Filtering for enabled accounts only"
        $filteredResults = $filteredResults | Where-Object { $_.Enabled -eq "TRUE" }
    }

    # Disabled filter
    if ($Params.Disabled) {
        Write-Verbose "Search-ADAccount: Filtering for disabled accounts only"
        $filteredResults = $filteredResults | Where-Object { $_.Enabled -eq "FALSE" }
    }

    # SmartCardRequired filter
    if ($Params.SmartCardRequired) {
        Write-Verbose "Search-ADAccount: Filtering for accounts requiring smart cards"
        $filteredResults = $filteredResults | Where-Object { $_.SmartCardRequired -eq "TRUE" }
    }

    # CannotChangePassword filter
    if ($Params.CannotChangePassword) {
        Write-Verbose "Search-ADAccount: Filtering for accounts that cannot change passwords"
        $filteredResults = $filteredResults | Where-Object { $_.CannotChangePassword -eq "TRUE" }
    }

    return $filteredResults
} 