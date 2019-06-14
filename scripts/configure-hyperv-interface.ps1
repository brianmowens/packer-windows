# This script is to configure the NIC of a Hyper-V Virtual Machine
# that is running on a NAT network. 

param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $IPAddress = "192.168.1.2",

    [Parameter(Mandatory=$false)]
    [string] $PrefixLength = "24",

    [Parameter(Mandatory=$false)]
    [string] $DefaultGateway = "192.168.1.1",

    [Parameter(Mandatory=$false)]
    [array] $DNSServers = @("8.8.8.8","8.8.4.4")
)


# Configure the VM nic
$Interface = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*"}
New-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias -IPAddress $IPAddress -AddressFamily IPv4 -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $DNSServers
