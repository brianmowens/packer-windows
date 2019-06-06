param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $SwitchName = "NATSwitch",

    [Parameter(Mandatory=$false)]
    [string] $SwitchType = "Internal"
)

# Check for an existing switch
$ExistingSwitch = Get-VMSwitch -Name $SwitchName -EA SilentlyContinue

# Remove the existing switch if it exists
if($ExistingSwitch){
    Write-Host "Attempting to remove existing switch."
    try{
        Remove-VMSwitch -Name $SwitchName -Force -EA Stop
    }
    catch{
        Write-Error "Failed to remove existing switch. Error: $($_.Exception.Message)"
        break
    }
}

# Create the new switch
try{
    Write-Host "Attempting to create new switch [$SwitchName]."
    New-VMSwitch -SwitchName "$SwitchName" -SwitchType $SwitchType -EA Stop
}
catch {
    Write-Error "Failed to create new switch. Error: $($_.Exception.Message)"
    break
}

# Make sure we can find the new switch
$SwitchAdapter = Get-NetAdapter | Where {$_.Name -like "*vEthernet ($SwitchName)*"}
if($SwichAdapter){
    Write-Host "Found new switch."
}
else{
    Write-Error "Failed to locate new switch."
    break
}

try{
    Write-Host "Creating new NetIPAddress"
    New-NetIPAddress -IPAddress 10.1.0.1 -PrefixLength 24 -InterfaceIndex $SwitchAdapter.InterfaceIndex -EA Stop
}
catch{
    Write-Error "Failed to create new NetIPAddress. Error: $($_.Exception.Message)"
    break
}

try{
    Write-Host "Creating new NAT network"
    New-NetNAT -Name "$SwitchName" -InternalIPInterfaceAddressPrefix 10.1.0.0/24 -EA Stop
}
catch{
    Write-Error "Failed to create new NAT network. Error: $($_.Exception.Message)"
    break
}