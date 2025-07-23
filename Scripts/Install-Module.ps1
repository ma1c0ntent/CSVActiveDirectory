# Install-Module.ps1
# Scripts folder - Utility script for module installation

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$InstallPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\CSVActiveDirectory",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Write-Host "Installing CSVActiveDirectory Module..." -ForegroundColor Green

# Check if module already exists
if (Test-Path $InstallPath) {
    if ($Force) {
        Write-Host "Removing existing installation..." -ForegroundColor Yellow
        Remove-Item -Path $InstallPath -Recurse -Force
    } else {
        Write-Error "Module already exists at $InstallPath. Use -Force to overwrite."
        return
    }
}

# Create installation directory
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

# Copy module files
$SourcePath = Split-Path -Parent $PSScriptRoot
Copy-Item -Path "$SourcePath\*.psd1" -Destination $InstallPath -Force
Copy-Item -Path "$SourcePath\*.psm1" -Destination $InstallPath -Force
Copy-Item -Path "$SourcePath\Functions" -Destination $InstallPath -Recurse -Force
Copy-Item -Path "$SourcePath\Data" -Destination $InstallPath -Recurse -Force

Write-Host "Module installed successfully at: $InstallPath" -ForegroundColor Green
Write-Host "Import the module with: Import-Module CSVActiveDirectory" -ForegroundColor Cyan 