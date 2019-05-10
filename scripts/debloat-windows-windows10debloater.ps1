Write-Output "Setting PowerShell Execution Policy to Unrestricted"
Set-ExecutionPolicy Unrestricted -Force

$debloatUri = "https://github.com/Sycnex/Windows10Debloater/archive/master.zip"

Write-Output "Setting PowerShell to use TLS 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$WebClient = New-Object System.Net.WebClient

Write-Output "Downloading Windows10Debloater from GitHub"
$WebClient.DownloadFile($debloatUri, "$env:TEMP\debloat.zip")

Write-Output "Expanding archive"
Expand-Archive -Path $env:TEMP\debloat.zip -DestinationPath $env:TEMP -Force

if(Test-Path "$env:Temp\Windows10Debloater-master\Windows10SysPrepDebloater.ps1"){
    Write-Output "Running Windows 10 Debloater"
    Invoke-Expression "$env:Temp\Windows10Debloater-master\Windows10SysPrepDebloater.ps1 -Debloat"
}

Write-Output "Removing Windows10Debloater"
Remove-Item -Recurse -Path "$env:TEMP\Windows10Debloater*" -Force