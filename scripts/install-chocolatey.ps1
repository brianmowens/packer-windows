
# Set PowerShell to unrestricted execution
if((Get-ExecutionPolicy) -eq "Restricted"){
    Write-Output "Setting PowerShell Executing policy to Bypass for scope of process."
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
}

# Execute Chocolately installer
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))