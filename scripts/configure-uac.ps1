# Are we enabling or disabling UAC?
$EnableUAC = $false

# Get the current value
Write-Output "Getting existing UAC value"
$CurrentValue = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableLUA").EnableLUA

if($EnableUAC -and ($CurrentValue -eq 0)){
    Write-Output "Enabling UAC"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableLUA" -Value 1
}
elseif($EnableUAC -and ($CurrentValue -eq 1)){
    Write-Output "UAC already enabled."
}
elseif(!($EnableUAC) -and ($CurrentValue -eq 0)){
    Write-Output "UAC already disabled."
}
elseif(!($EnableUAC) -and ($CurrentValue -eq 1)){
    Write-Output "Disabling UAC"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableLUA" -Value 0
}