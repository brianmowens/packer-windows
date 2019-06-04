param(
  [CmdletBinding()]  
  
  [Parameter(Mandatory=$false)]
  [string] $PackerBuilder = "virtualbox-iso",

  [Parameter(Mandatory=$false)]
  [string] $isoUrl = "$($env:server2019iso)",

  [Parameter(Mandatory=$false)]
  [string] $packerFile = ".\packer_files\2019_core.json"
)

Write-Output "Starting build"
packer build --only=$PackerBuilder --var iso_url=$isoUrl $packerFile