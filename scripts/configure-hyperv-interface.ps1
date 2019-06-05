
# Configure the VM nic
if($env:PACKER_BUILDER_TYPE -eq "hyperv-iso"){
    New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.168.0.2 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 192.168.0.1
    Set-DnsClientServerAddress -InterfaceIndex 12 -ServerAddresses @("8.8.8.8","8.8.4.4")
}
else{
    Write-Host "Only Hyper-V hosts should run this script."
}