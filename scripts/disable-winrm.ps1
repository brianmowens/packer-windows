# The purpose of this script is to disable inbound WinRM connections from the Packer
# provisioner until after all of our Windows pre-configuration steps have been completed.

Write-Output "Disabling WinRM inbound firewall rule"
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Set-NetFirewallRule -Action Block

$winRmService = Get-Service -Name "WinRM"
if($winRmService.Status -eq "Running"){
    Write-Output "Disabling PSRemoting"
    Disable-PSRemoting -Force -WarningAction SilentlyContinue
}

Write-Output "Stopping WinRM Service"
if($winRmService.Status -eq "Running"){
    $winRmService | Stop-Service -Force
}

Write-Output "Disabling WinRM Service"
if($winRmService.StartType -ne "Disabled"){
    $winRmService | Set-Service -StartupType "Disabled"
}