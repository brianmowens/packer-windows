param(
  [CmdletBinding()]  
  
  [Parameter(Mandatory=$false)]
  [string] $PackerBuilder = "virtualbox-iso",

  [Parameter(Mandatory=$false)]
  [string] $isoUrl = "$($env:server2019iso)",

  [Parameter(Mandatory=$false)]
  [string] $packerFile = "..\packer_files\2019_core.json"
)

Write-Output "Starting build"
packer build --only=$PackerBuilder --var iso_url=$isoUrl $packerFile

<#
packer build `
  --only=virtualbox-iso `
  --var iso_url=c:/workbench/software/microsoft/17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso `
  ../packer_files/2019_core.json

if(Test-Path -Path ".\packer_cache"){
  Write-Output "Clearing packer cache from local disk"
  Remove-Item .\packer_cache -Recurse -Force
}
#>
