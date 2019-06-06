
# Configure the VM nic
if($env:PACKER_BUILDER_TYPE -eq "hyperv-iso"){
    $Interface = (Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*"})[0]

    New-NetIPAddress -InterfaceAlias $Interface.InterfaceAlias -IPAddress 10.1.0.2 -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway 10.1.0.1
    Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses @("8.8.8.8","8.8.4.4")
}
else{
    Write-Host "Only Hyper-V hosts should run this script."
}