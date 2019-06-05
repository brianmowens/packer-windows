$SwitchName = "packer-hyperv-iso"

if(Get-VMSwitch -name $SwitchName){
    "Hyper-V Switch already exists."
    try{
        Remove-VMSwitch -name $SwitchName -Force
    }
    catch{
        Write-Output "Failed to remove existing switch."
        break
    }

    $NetAdapter = Get-NetAdapter -EA Stop
    if($NetAdapter){
        try{
            New-VMSwitch -name $SwitchName -NetAdapeterName $NetAdapter[0].Name -AllowManagementOs $true -Verbose
        }
        catch{
            Write-Output "Failed to create new switch."
        }
    }
}