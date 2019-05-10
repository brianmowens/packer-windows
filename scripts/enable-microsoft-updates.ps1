Write-Output "Enabling Microsoft Updates"

$winrmService = Get-Service -Name "winrm"
if($winrmService.Status -eq "Running"){
    Write-Output "Stopping WinRM service"
    $winrmService | Stop-Service -Force
}

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
    -Name "EnableFeaturedSoftware" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
    -Name "IncludeRecommendedUpdates" -Value 1

echo Set ServiceManager = CreateObject("Microsoft.Update.ServiceManager") > A:\temp.vbs
echo Set NewUpdateService = ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") >> A:\temp.vbs

cscript A:\temp.vbs

if($winrmService.Status -ne "Running"){
    Write-Output "Starting WinRM service"
    $winrmService | Start-Service 
}