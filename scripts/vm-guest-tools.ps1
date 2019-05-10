
$WebClient = New-Object System.Net.WebClient
$VBoxGuestVersion = '5.2.26'

if($env:PACKER_BUILDER_TYPE -eq "virtualbox-iso"){
    Write-Output "Running virtualbox-iso guest tools installation."
    if(Test-Path "C:\Users\vagrant\VBoxGuestAdditions.iso"){
        Write-Output "Moving iso to temp directory."
        Move-Item -Path "C:\Users\vagrant\VBoxGuestAdditions.iso" -Destination "C:\Windows\Temp" -Force
    }
    else{
        Write-Output "Downloading Guest Additions."
        $WebClient.DownloadFile("https://download.virtualbox.org/virtualbox/5.2.26/VBoxGuestAdditions_$($VBoxGuestVersion).iso","C:\Windows\Temp\VBoxGuestAdditions.iso")
    }
    
    Write-Output "Mounting ISO"
    $DiskImage = Mount-DiskImage -ImagePath "C:\Windows\Temp\VBoxGuestAdditions.iso"
    $DiskDrive = ($DiskImage | Get-Volume).DriveLetter

    Write-Output "Starting Guest Additions Installation"
    Start-Process -FilePath "$($DiskDrive):\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait

}

if($env:PACKER_BUILDER_TYPE -eq "vmware-iso"){
    Write-Output "Running vmware-iso guest tools installation."
    if(Test-Path -Path "C:\Users\vagrant\windows.iso"){
        Move-Item -Path "C:\Users\vagrant\windows.iso" -Destination "C:\Windows\Temp" -Force
    }
    else{
        Write-Output "Downloading Guest Additions"
        $WebClient.DownloadFile("https://softwareupdate.vmware.com/cds/vmw-desktop/ws/15.0.4/12990004/windows/packages/tools-windows.tar","C:\Windows\Temp\vmware-tools.tar")
    }

    Write-Output "Extracting tar"
    tar -xvf C:\Windows\Temp\vmware-tools.tar C:\Windows\Temp

    $VMWareIso = (Get-ChildItem -Path "C:\Windows\Temp" | Where {$_.Name -like "VMware*.iso"}).FullName

    if($VMWareISO){
        Write-Output "Mounting ISO"
        $DiskImage = Mount-DiskImage $VMWareIso
        $DiskDrive = ($DiskImage | Get-Volume).DriveLetter
    }

    Write-Output "Starting Guest Additions Installation"
}