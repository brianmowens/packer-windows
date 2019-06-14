param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $SwitchName = "NATSwitch",

    [Parameter(Mandatory=$false)]
    [string] $SwitchType = "Internal"
)


Write-Output "Creating VM Switch"
New-VMSwitch -SwitchName "$SwitchName" -SwitchType $SwitchType
$SwitchAdapter = Get-NetAdapter | Where-Object {$_.Name -like "*vEthernet ($SwitchName)*"}
Write-Output "Creating Net IP Address"
New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 24 -InterfaceAlias "$($SwitchAdapter.InterfaceAlias)"
Write-Output "Creating NAT network"
New-NetNAT -Name "$SwitchName" -InternalIPInterfaceAddressPrefix 192.168.1.0/24