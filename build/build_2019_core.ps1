
packer build `
  --only=virtualbox-iso `
  --var iso_url=c:/workbench/software/microsoft/17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso `
  ../packer_files/2019_core.json

if(Test-Path -Path ".\packer_cache"){
  Write-Output "Clearing packer cache from local disk"
  Remove-Item .\packer_cache -Recurse -Force
}
