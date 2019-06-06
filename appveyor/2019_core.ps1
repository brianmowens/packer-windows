param(
  [CmdletBinding()]  
  
  [Parameter(Mandatory=$false)]
  [string] $PackerBuilder = "hyperv-iso",

  [Parameter(Mandatory=$false)]
  [string] $isoUrl = "C:/projects/packer-windows/server2019.iso",

  [Parameter(Mandatory=$false)]
  [string] $packerFile = ".\packer_files\2019_core.json"
)

Write-Output "Starting build"
packer build --only=$PackerBuilder --var iso_url=$isoUrl $packerFile