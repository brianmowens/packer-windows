param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $logFile = "C:\Packer\Logs\windows_update.txt"

)

function New-LogFile {
    param(
        [Parameter(Mandatory=$false)]
        [string] $logFile = "C:\Packer\Logs\windows_update.txt",

        [Parameter(Mandatory=$false)]
        [switch] $Append
    )

    if($Append){
        if(Test-Path $logFile -EA SilentlyContinue){
            Write-Output "Log file already exists. - Appending"
            Write-Log "Appending new log entries to an existing log file."
            return
        }
        else{
            Write-Output "No existing logfile was found for appending writes."
        }
    }

    if((Test-Path $logFile -EA SilentlyContinue) -and !($Append)){
        # Get the existing log file
        $existingLogFile = (Get-Item $logFile -EA Stop)
        
        # Generate a name for the old log file to be renamed to
        $renamedLogFileName = $existingLogFile.Name.Split(".")[0] + "_$(Get-Date -Format yyyyMMdd-hhmmss)." + $existingLogFile.Name.Split(".")[1]
        $renamedLogFilePath = "$($existingLogFile.Directory.FullName)\$($renamedLogFileName)"

        # Perform the copy
        Write-Output "Renaming existing log file to: $renamedLogFileName"
        try{
            Move-Item -Path $logFile -Destination "$renamedLogFilePath" -Force -EA Stop
        }
        catch{
            Write-Error "Failed to rename existing logfile [$($existingLogFile.FullName)] to [$renamedLogFilePath]. Error: $($_.Exception.Message)"
            break
        }
    }
    
    Write-Output "Creating new log file."
    try{
        New-Item -ItemType File -Path $logFile -Force -EA Stop | Out-Null
    }
    catch{
        Write-Error "Failed to create new log file. Error: $($_.Exception.Message)"
        break
    }

}

function Write-Log {
    param(
        [Parameter(Mandatory=$false)]
        [string] $LogFile = "C:\Packer\Logs\windows_update.txt",

        [Parameter(Mandatory=$false,Position=0)]
        [string] $LogLine = "",

        [Parameter(Mandatory=$false)]
        [switch] $DisableTimeStamp,

        [Parameter(Mandatory=$false)]
        [switch] $Quiet
    )

    # Add a timestamp to the beginning of the log line unless it's disabled.
    if(!($DisableTimeStamp)){
        $TimeStamp = "$(Get-Date -format s) - "
        $LogLine = $TimeStamp + $LogLine
    }

    try{
        Add-Content -Path $logFile -Value $logLine -EA Stop
        # Write output to console unless switched off.
        if(!($Quiet)){
            Write-Host $LogLine
        }
    }
    catch{
        Write-Error "Failed to write content to log file. Error: $($_.Exception.Message)"
        break
    }
}

function Set-RebootEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,Position=0)]
        [string] $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        
        [Parameter(Mandatory=$false,Position=1)]
        [string] $RegistryEntry = "InstallWindowsUpdates",

        [Parameter(Mandatory=$false)]
        [switch] $RebootNow
    )

    Write-Log "---- Setting reboot entry."
    # Check for an existing entry    
    $Property = (Get-ItemProperty -Path $RegistryKey).$RegistryEntry
    if($Property){
        Write-Log "----- Reboot entry already exists."
    }
    else{
        Write-Log "----- Applying reboot entry."
        $ScriptPath = $MyInvocation.ScriptName
        Set-ItemProperty -Path $RegistryKey -Name $RegistryEntry -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File $($ScriptPath)"
    }

    if($RebootNow){
        Write-Log "----- Rebooting machine."
        Restart-Computer -Force
        Start-Sleep 30
    }
}

function Remove-RebootEntry { 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,Position=0)]
        [string] $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        
        [Parameter(Mandatory=$false,Position=1)]
        [string] $RegistryEntry = "InstallWindowsUpdates"
    )

    Write-Log "---- Checking for reboot entry."
    # Check for an existing entry    
    $Property = (Get-ItemProperty -Path $RegistryKey).$RegistryEntry
    if($Property){
        Write-Log "----- Removing reboot entry."
        Remove-ItemProperty -Path $RegistryKey -Name $RegistryEntry -EA SilentlyContinue
    }
    else{
        Write-Log "----- No existing reboot entry was found."
    }
}

function Get-WindowsUpdates {
    param(
        [CmdletBinding()]
        [Parameter(Mandatory=$false)]
        [int] $searchAttempts = 12
    )

    Write-Log "---- Obtaining Windows Updates."

    # Create an Update Session
    try{
        Write-Log "----- Creating new update session"
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session' -EA Stop
        $UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'
    }
    catch{
        Write-Log "ERROR: Failed to generate update session. Error: $($_.Exception.Message)"
        break
    }

    # Create an Update Searcher
    Write-Log "----- Creating update searcher"
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

    # Create an Update Collection to hold search results
    Write-Log "----- Initializing update collection"
    $SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'

    Write-Log "----- Amount of search attempts to perform: $searchAttempts"

    # Search for updates
    $searchSuccessful = $false
    while($searchSuccessful -eq $false -and ($currentSearchAttempt -le $searchAttempts)){
        try{
            Write-Log "----- Checking for Windows Updates"
            $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            $searchSuccessful = $true
            Write-Log "----- Successfully obtained a list of updates."
        }
        catch{
            Write-Log "ERROR: Failed to obtain updates. Will try again in 10 seconds. Attempt [$currentSearchAttempt] of [$searchAttempts]"
            $currentSearchAttempt ++
            Start-Sleep 10
        }
    }

    # Return our search result
    if($SearchResult.Updates.Count -eq 0){
        Write-Log "----- No new updates were found."
        return $null
    }
    else{
        return $searchResult
    }
}

function Install-WindowsUpdates {
    param(
        [CmdletBinding()]
        [Parameter(Mandatory=$false,Position=0)]
        [ValidateNotNullOrEmpty()]
        $updatesCollection,

        [Parameter(Mandatory=$false,Position=1)]
        [int] $updateLimit = 500,

        [Parameter(Mandatory=$false,Position=2)]
        [int] $maxDownloadAttempts = 5,

        [Parameter(Mandatory=$false)]
        [switch] $ReturnRebootCode
    )

    Write-Log "---- Installing Windows Updates."
    
    try{
        Write-Log "----- Initializing new update collection object."
        $updatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    }
    catch{
        Write-Log "ERROR: Failed to initial update collection object. Error: $($_.Exception.Message)"
        break
    }
    # Build a list of updates to download
    $totalUpdates = $updatesCollection.Updates.Count
    Write-Log "----- Evaluating updates for download eligibility. Total updates: $totalUpdates"
    $count=0
    While($count -lt $updatesCollection.Updates.Count -and $count -le $updateLimit){
        [bool]$queueCurrentUpdate = $false

        # Get the update for the current loop iteration
        $currentUpdate = $updatesCollection.Updates.Item($count)

        Write-Log "------ Update [$($count+1)] of [$totalUpdates] / Maximum: [$updateLimit] - $($currentUpdate.Title)"

        # Check each update and exclude any that require manual user interaction.
        # Also ensure we accept any EULA agreements
        if($null -ne $currentUpdate){
            $queueCurrentUpdate = $false
            if($currentUpdate.InstallationBehavior.CanRequestUserInput) {
                Write-Log "------- Skipping update due to possibility of user interaction being required: [$($currentUpdate.Title)]"
                $queueCurrentUpdate = $false
            }
            elseif(!($currentUpdate.EulaAccepted)){
                Write-Log "Accepting EULA agreement for update: [$($currentUpdate.Title)]"
                $currentUpdate.AcceptEula()
                [bool]$queueCurrentUpdate = $true
            }
            else{
                [bool]$queueCurrentUpdate = $true
            }
            if($queueCurrentUpdate){
                Write-Log "------- Queueing update for download."
                $updatesToDownload.Add($currentUpdate) | Out-Null
            }
        }
        $count++
    }

    # Download the queued updates
    Write-Log "----- Starting update downloads."
    if($updatesToDownload.Count -eq 0){
        Write-Log "------ No updates need to be downloaded."
        break
    }
    else{
        Write-Log "------ Creating Update Session."
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
        $UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'
        $downloadSuccessful = $false
        $downloadAttempts = 0
        While($downloadSuccessful -ne $true -and $downloadAttempts -le $maxDownloadAttempts){
            try{
                Write-Log "------- Creating Downloader."
                $Downloader = $UpdateSession.CreateUpdateDownloader()
                Write-Log "------- Starting download."
                $Downloader.Updates = $updatesToDownload
                $Downloader.Download() | Out-Null
                $downloadSuccessful = $true
            }
            catch{
                $downloadAttempts++
                Write-Log "ERROR: Failed to download updates. Error: $($_.Exception.Message)"
                Write-Log "------- Waiting 30s before retrying. Attempt [$downloadAttempts] of [$maxDownloadAttempts]."
                Start-Sleep 10
                $downloadSuccessful = $false
            }
        }
    }
    Write-Log "----- Finished downloading updates."

    # Check the updatesCollection and grab every update marked as downloaded.
    Write-Log "----- Preparing for update installation."
    $updatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $Installer = $UpdateSession.CreateUpdateInstaller()
    $rebootRequired = 0
    
    Write-Log "------ The following updates are ready for installation:"
    ForEach($Update in $updatesCollection.Updates){
        if($Update.IsDownloaded){
            Write-Log "------- $($Update.Title)"
            $updatesToInstall.Add($Update) | Out-Null
        }
        if($Update.InstallationBehavior.RebootBehavior -gt 0){
            Write-Log "-------- This update may require a reboot."
            $rebootRequired = 1
        }
    }

    # Exit the function if there's nothing to actually install.
    if($updatesToInstall.Count -eq 0){
        Write-Log "------- No updates are available for installation."
        if($ReturnRebootCode){
            return $rebootRequired
        }
        break
    }
    
    # Perform the install
    Write-Log "----- Starting Installation."
    $Installer.Updates = $updatesToInstall
    $InstallerResult = $Installer.Install()

    Write-Log "------ Installation finished. Result: $($InstallerResult.ResultCode)"
    Write-Log "------ Reboot required?: $($InstallerResult.RebootRequired)"
    Write-Log "------ Individual update installation results:"

    # Write out the individual updates and their installation status for logging
    For($i=0;$i -lt $updatesToInstall.Count;$i++){
        Write-Log "------- Update: $($updatesToInstall.Item($i).Title)"
        Write-Log "-------- Result: $($InstallerResult.GetUpdateResult($i).ResultCode)"
    }

    # End the function, return reboot code is needed.
    Write-Log "----- Installation Finished."
    if($ReturnRebootCode){
        return $rebootRequired
    }
}

# Batch variables
$maximumBatches = 5
$currentBatch = 0

# Initialize logging
New-LogFile -Append
Write-Log "- Starting windows update"

While($currentBatch -lt $maximumBatches){
    $currentBatch++
    
    # Get a list of updates
    Write-Log "--- Getting batch of updates."
    Write-Log "--- Batch [$currentBatch] of [$maximumBatches]."
    $windowsUpdates = Get-WindowsUpdates

    # Break the loop if we have no updates to install.
    if($null -eq $windowsUpdates){
        break
    }

    # Start the download/install process
    Write-Log "--- Starting installation."
    $rebootRequired = Install-WindowsUpdates $windowsUpdates -ReturnRebootCode

    # Check if a reboot is required. Reboot if necessary.
    if($rebootRequired -eq 1){
        Write-Log "--- Reboot required."
        Set-RebootEntry -RebootNow
    }
    else{
        Write-Log "--- No reboot required."
        Remove-RebootEntry
    }    
}

Write-Log "-- Finished updating windows."

if(Test-Path -Path "a:\enable-winrm.ps1"){
    Write-Log "- Calling enable-winrm.ps1"
    & a:\enable-winrm.ps1
}
else{
    Write-Log "- a:\enable-winrm.ps1 not found, skipping."
}

Write-Log "- Exiting."