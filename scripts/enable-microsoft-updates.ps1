Write-Output "Enabling Microsoft Updates"

$windowsUpdateService = Get-Service -Name "wuauserv"
if($windowsUpdateService.Status -eq "Running"){
    Write-Output "Stopping Windows Update service"
    $windowsUpdateService | Stop-Service -Force
}

Write-Output "Setting registry key for EnabledFeaturedSoftware"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
    -Name "EnableFeaturedSoftware" -Value 1
Write-Output "Setting registry key for IncludeRecommendedUpdates"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
    -Name "IncludeRecommendedUpdates" -Value 1

if($windowsUpdateService.Status -ne "Running"){
    Write-Output "Starting Windows Update service"
    $windowsUpdateService | Start-Service 
}