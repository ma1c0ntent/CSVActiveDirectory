# Purpose
This repository/module/functions were designed with the idea of simulating the PowerShell module, ActiveDirectory, without needing to:
1. Have an Active Directory environment set up
2. Practice on a domain controller

## Getting Started

### Import-Module
Use Import-Module .\CSVActiveDirectory.psd1 to import the commands

Once imported, you will have access to the following commands:
- **`Get-ADUser`**
- **`New-ADUser`**
- **`Remove-ADUser`**
- **`Enable-ADUser`**
- **`Disable-ADUser`**

### Command Help
1. You can also see the list of commands by using Get-Module -Name CSVActiveDirectory
2. To see the list of parameters and their use case, type Get-Help `<Command>` -Full

#### Get-ADUser
This command requires that either the Identity parameter or Filter parameter be used.

- To return the entire database, use Get-ADUser * or Get-ADUser -Identity * or Get-ADUser -Filter *
  The default properties that are return are FirstName, LastName, DisplayName, and SamAccountName.
  To see more properties, use the -Properties parameter. Properties are comma delimited.

  .EXAMPLE `Get-ADUser -Identity jrusso -Properties *`
  .EXAMPLE `Get-ADUser -Identity jrusso -Properties DisplayName, DistinguishedName, Enabled
