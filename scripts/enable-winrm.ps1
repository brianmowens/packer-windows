Write-Output "Enabling PSRemoting"
Enable-PSRemoting -Force

Write-Output "Configuring WinRM"
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

Write-Output "Enabling Firewall Rules"
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Set-NetFirewallRule -Action Allow

Write-Output "Setting WinRM Service to auto startup."
Set-Service -Name "winrm" -StartupType Automatic

Write-Output "Restarting WinRM"
Restart-Service -Name "winrm"