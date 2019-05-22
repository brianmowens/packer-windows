$OpenSSHServerVersion = "OpenSSH.Server~~~~0.0.1.0"
$OpenSSHUtilsVersion = "0.0.2.0"

Write-Output "Configuring OpenSSH Server"

# Install the service if it isn't already installed
$ExistingInstall = Get-WindowsCapability -Online -Name $OpenSSHServerVersion
if($ExistingInstall.State -ne "Installed"){
    Write-Output "Attempting to install: $OpenSSHServerVersion"
    Add-WindowsCapability -Online -Name $OpenSSHServerVersion
    Write-Output "Installation finished"
}

# Put the config file in place
if(Test-Path "a:\sshd_config"){
    Write-Output "Found supplied shhd_config"
    if(!(Test-Path "$env:PROGRAMDATA\ssh")){
        Write-Output "Creating ssh directory"
        New-Item -ItemType Directory -Path "$env:PROGRAMDATA\ssh" -Force | Out-Null
    }
    Write-Output "Copying sshd_config"
    Copy-Item -Path "a:\sshd_config" -Destination "$env:PROGRAMDATA\ssh\sshd_config" -Force
}
else{
    Write-Error "Unable to find sshd_config file."
}

# Start the service
$sshdService = Get-Service -Name "sshd"
if(($sshdService) -and ($sshdService.Status -ne 'Running')){
    Write-Output "Starting sshd service"
    Start-Service -Name "sshd"
}
# Set service to start automatically
if(($sshdService) -and ($sshdService.StartType -ne 'Automatic')){
    Write-Output "Setting sshd service to startup type Automatic"
    $sshdService | Set-Service -StartupType 'Automatic'
}

# Ensure the pre-existing firewall rule is enabled
$ExistingFWRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
if($ExistingFWRule.Enabled -ne 'True'){
    Write-Output "Enabling firewall rule for inbound SSH access"
    $ExistingFWRule | Set-NetFirewallRule -Enabled True
}

# NuGet package manager is required in order to install modules using PowerShell
$ExistingPackageProviders = Get-PackageProvider

if($ExistingPackageProviders.Name -contains "NuGet"){
    Write-Output "NuGet package provider already installed."
}
else{
    Write-Output "Installing NuGet package provider."
    Install-PackageProvider -Name "NuGet" -Force | Out-Null
}

# Install SSH Utils
Write-Output "Checking for OpenSSHUtils installation"
$ExistingModule = Get-Module -Name "OpenSSHUtils"
if($ExistingModule.Version -ne $OpenSSHUtilsVersion){
    Write-Output "Installing OpenSSHUtils version: $OpenSSHUtilsVersion"
    Install-Module -Name "OpenSSHUtils" -Force -Scope AllUsers -RequiredVersion $OpenSSHUtilsVersion
}

