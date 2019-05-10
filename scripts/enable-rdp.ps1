Write-Output "Opening RDP Inbound Firewall Port"
New-NetFirewallRule -Name "RDP-Inbound" -DisplayName "Remote Desktop - Inbound" `
    -Protocol TCP -LocalPort 3389 -Action Allow -Direction Inbound | Out-Null

Write-Output "Enabling Remote Desktop"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name 'fDenyTSConnections' `
    -Value 0 -Force