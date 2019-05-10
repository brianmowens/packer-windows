Write-Output "Disable screen saver" 
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -Type DWord

Write-Output "Changing power settings to never turn off monitor."
& powercfg -x -monitor-timeout-ac 0
& powercfg -x -monitor-timeout-dc 0