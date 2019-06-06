
# Configure the VM nic
$Interface = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*"}
New-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias -IPAddress 10.1.0.2 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 10.1.0.1
Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses @("8.8.8.8","8.8.4.4")
