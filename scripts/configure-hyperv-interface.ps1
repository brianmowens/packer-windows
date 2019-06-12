# This script is to configure the NIC of a Hyper-V Virtual Machine
# that is running on a NAT network. 

param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $IPAddress = "10.1.0.2",

    [Parameter(Mandatory=$false)]
    [string] $PrefixLength = "24",

    [Parameter(Mandatory=$false)]
    [string] $DefaultGateway = "10.1.0.1",

    [Parameter(Mandatory=$false)]
    [array] $DNSServers = @("8.8.8.8","8.8.4.4")
)

# Check if we're running on the AppVeyor platform
if($env:APPVEYOR_PROJECT_NAME){
    Write-Output "Build is running on AppVeyor platform. Configuring NIC."
}
# If not in AppVeyor, make sure we're running Hyper-V
elseif($env:PACKER_BUILDER_TYPE -eq "hyperv-iso"){
    Write-Output "Packer build type is Hyper-V. Configuring NIC."
}
# Exit if we don't have a match
else {
    Write-Output "Only AppVeyor and Hyper-V need their NIC configured."
    break
}

# Configure the VM nic
$Interface = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*"}
New-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias -IPAddress $IPAddress -AddressFamily IPv4 -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $DNSServers
