Function Show-ADProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $false)]
        [string]$Status = "Processing...",
        
        [Parameter(Mandatory = $false)]
        [int]$PercentComplete = 0,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Simple", "Detailed", "Minimal", "None")]
        [string]$Style = "Detailed",
        
        [Parameter(Mandatory = $false)]
        [switch]$Completed
    )
    
    if ($Style -eq "None") {
        return
    }
    
    if ($Completed) {
        Write-Host "Completed: $Activity" -ForegroundColor Green
    } else {
        $StatusToUse = if ([string]::IsNullOrEmpty($Status)) { "Processing..." } else { $Status }
        Write-Progress -Activity $Activity -Status $StatusToUse -PercentComplete $PercentComplete
    }
}

Function Start-ADOperation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OperationName,
        
        [Parameter(Mandatory = $false)]
        [int]$TotalItems = 0,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Simple", "Detailed", "Minimal", "None")]
        [string]$ProgressStyle = "Detailed"
    )
    
    $Operation = @{
        Name = $OperationName
        TotalItems = $TotalItems
        CurrentItem = 0
        StartTime = Get-Date
        ProgressStyle = $ProgressStyle
    }
    
    Show-ADProgress -Activity $OperationName -Status "Starting operation..." -Style $ProgressStyle
    
    return $Operation
}

Function Update-ADOperation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Operation,
        
        [Parameter(Mandatory = $false)]
        [string]$CurrentItem = "",
        
        [Parameter(Mandatory = $false)]
        [string]$Status = ""
    )
    
    $Operation.CurrentItem++
    $PercentComplete = if ($Operation.TotalItems -gt 0) { 
        [math]::Round(($Operation.CurrentItem / $Operation.TotalItems) * 100) 
    } else { 
        0 
    }
    
    Show-ADProgress -Activity $Operation.Name -Status $Status -PercentComplete $PercentComplete -Style $Operation.ProgressStyle
}

Function Complete-ADOperation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Operation,
        
        [Parameter(Mandatory = $false)]
        [string]$Message = ""
    )
    
    $Duration = (Get-Date) - $Operation.StartTime
    
    Show-ADProgress -Activity $Operation.Name -Completed -Style $Operation.ProgressStyle
    
    if ($Message) {
        Write-Host "  $Message" -ForegroundColor Gray
    }
    
    Write-Host "  Duration: $($Duration.ToString('mm\:ss'))" -ForegroundColor Gray
}

Function Show-ADBulkProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $true)]
        [array]$Items,
        
        [Parameter(Mandatory = $true)]
        [scriptblock]$ProcessScript,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Simple", "Detailed", "Minimal", "None")]
        [string]$Style = "Detailed",
        
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf
    )
    
    $Operation = Start-ADOperation -OperationName $Activity -TotalItems $Items.Count -ProgressStyle $Style
    
    $Results = @()
    $Errors = @()
    
    foreach ($Item in $Items) {
        if (-not $WhatIf) {
            try {
                $Result = & $ProcessScript -Item $Item
                $Results += $Result
            }
            catch {
                $Errors += @{
                    Item = $Item
                    Error = $_.Exception.Message
                }
            }
        }
        
        Update-ADOperation -Operation $Operation -CurrentItem $Item.ToString()
    }
    
    $Message = "Processed $($Items.Count) items"
    if ($Errors.Count -gt 0) {
        $Message += " ($($Errors.Count) errors)"
    }
    
    Complete-ADOperation -Operation $Operation -Message $Message
    
    return @{
        Results = $Results
        Errors = $Errors
        TotalProcessed = $Items.Count
        TotalErrors = $Errors.Count
    }
}

Function Show-ADStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [string]$Details = ""
    )
    
    $Colors = @{
        Info = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error = "Red"
    }
    
    $Icons = @{
        Info = "i"
        Success = "OK"
        Warning = "!"
        Error = "X"
    }
    
    $Color = $Colors[$Type]
    $Icon = $Icons[$Type]
    
    Write-Host "$Icon " -ForegroundColor $Color -NoNewline
    Write-Host $Message -ForegroundColor White
    
    if ($Details) {
        Write-Host "  $Details" -ForegroundColor Gray
    }
} 
