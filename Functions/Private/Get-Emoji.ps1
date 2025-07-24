Function Get-Emoji {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Success", "Error", "Warning", "Info", "Search", "Target", "Lightning", "Rocket", "Bulb", "Lock", "Unlock", "Check", "Cross", "Exclamation", "Bullet", "User", "Alert", "Magnify", "Gear", "Shield", "ArrowRight")]
        [string]$Type
    )

    $PSVersion = $PSVersionTable.PSVersion.Major

    if ($PSVersion -ge 7) {
        switch ($Type) {
            "Success"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2705", 16)) } # ✅
            "Error"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("274C", 16)) } # ❌
            "Warning"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A0", 16)) } # ⚠
            "Info"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2139", 16)) } # ℹ
            "Search"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F50D", 16)) } # 🔍
            "Target"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F3AF", 16)) } # 🎯
            "Lightning"   { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A1", 16)) } # ⚡
            "Rocket"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F680", 16)) } # 🚀
            "Bulb"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F4A1", 16)) } # 💡
            "Lock"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F512", 16)) } # 🔒
            "Unlock"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F513", 16)) } # 🔓
            "Check"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2705", 16)) } # ✅
            "Cross"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("274C", 16)) } # ❌
            "Exclamation" { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A0", 16)) } # ⚠
            "Bullet"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2022", 16)) } # •
            "User"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F464", 16)) } # 👤
            "Alert"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F6A8", 16)) } # 🚨
            "Magnify"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F50D", 16)) } # 🔍
            "Gear"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2699", 16)) } # ⚙️
            "Shield"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F6E1", 16)) } # 🛡️
            "ArrowRight"  { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("25B6", 16)) } # ▶
        }
    } else {
        # For PowerShell 5.1, use the same method as PS7+ for better compatibility
        switch ($Type) {
            "Success"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2705", 16)) } # ✅
            "Error"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("274C", 16)) } # ❌
            "Warning"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A0", 16)) } # ⚠
            "Info"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2139", 16)) } # ℹ
            "Search"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F50D", 16)) } # 🔍
            "Target"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F3AF", 16)) } # 🎯
            "Lightning"   { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A1", 16)) } # ⚡
            "Rocket"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F680", 16)) } # 🚀
            "Bulb"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F4A1", 16)) } # 💡
            "Lock"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F512", 16)) } # 🔒
            "Unlock"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F513", 16)) } # 🔓
            "Check"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2705", 16)) } # ✅
            "Cross"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("274C", 16)) } # ❌
            "Exclamation" { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("26A0", 16)) } # ⚠
            "Bullet"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2022", 16)) } # •
            "User"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F464", 16)) } # 👤
            "Alert"       { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F6A8", 16)) } # 🚨
            "Magnify"     { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F50D", 16)) } # 🔍
            "Gear"        { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("2699", 16)) } # ⚙️
            "Shield"      { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("1F6E1", 16)) } # 🛡️
            "ArrowRight"  { return [char]::ConvertFromUtf32([System.Convert]::ToInt32("25B6", 16)) } # ▶
        }
    }
}

Function Write-EmojiMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Success", "Error", "Warning", "Info")]
        [string]$Type,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [string]$Details = "",
        
        [Parameter(Mandatory = $false)]
        [switch]$NoNewline
    )
    
    $Emoji = Get-Emoji -Type $Type
    $Colors = @{
        Success = "Green"
        Error = "Red"
        Warning = "Yellow"
        Info = "Cyan"
    }
    
    $Color = $Colors[$Type]
    
    if ($NoNewline) {
        Write-Host "$Emoji $Message" -ForegroundColor $Color -NoNewline
    } else {
        Write-Host "$Emoji $Message" -ForegroundColor $Color
    }
    
    if ($Details) {
        Write-Host "  $Details" -ForegroundColor Gray
    }
} 