# Import all public functions
$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\Functions\Public\*.ps1 -ErrorAction SilentlyContinue)
ForEach ($import in @($PublicFunctions))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import public function $($import.fullname): $_"
    }
}

# Import all private functions (but don't export them)
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Functions\Private\*.ps1 -ErrorAction SilentlyContinue)
ForEach ($import in @($PrivateFunctions))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import private function $($import.fullname): $_"
    }
}

# Import format files
$FormatFiles = @(Get-ChildItem -Path $PSScriptRoot\Data\Formats\*.ps1xml -ErrorAction SilentlyContinue)
ForEach ($format in @($FormatFiles))
{
    Try
    {
        Update-FormatData -PrependPath $format.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import format file $($format.fullname): $_"
    }
}

# Export all functions (the manifest will control which ones are actually exported)
Export-ModuleMember -Function *
