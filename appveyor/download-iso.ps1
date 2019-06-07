param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $Uri = "$($env:server2019_iso_uri)",

    [Parameter(Mandatory=$false)]
    [string] $Outfile = "$($env:server2019_iso_output_path)"
)

$StopWatch = [system.diagnostics.stopwatch]::StartNew()

Write-Output "Starting iso download."
$Transfer = Start-BitsTransfer -Source $Uri -Destination $Outfile -Asynchronous
$CurrentStatus = ($Transfer | Get-BitsTransfer ).JobState

$ConnectingTimeout = 30
$ConnectingTime = 0
do{
    $CurrentStatus = ($Transfer | Get-BitsTransfer ).JobState
    Start-Sleep 1
    $ConnectingTime++
    if($ConnectingTime -gt $ConnectingTimeout){
        Write-Error "Failed to establish connectiong in the time alotted."
        break
    }
    else {
        Write-Output "Waiting for BITs to establish a connection. Attempt [$ConnectingTime] of [$ConnectingTimeOut]"
    }
}While ($CurrentStatus -eq "Connecting")

do{
    $Min = [math]::Round($StopWatch.Elapsed.Minutes,0)
    $Sec = [math]::Round($StopWatch.Elapsed.Seconds,0)
    
    $CurrentStatus = ($Transfer | Get-BitsTransfer ).JobState
    if($currentStatus -eq "Transferring"){
        Write-Output "Waiting for ISO download to complete. Current transfer time: $Min minutes, $Sec seconds."
        Start-Sleep 15
    }
    elseif($CurrentStatus -eq "Transferred"){
        Write-Output "Transfer complete. Writing to disk. Current transfer time: $Min minutes, $Sec seconds."
        $Transfer | Complete-BitsTransfer
        continue
    }
} While ($CurrentStatus -eq "Transferring")

$StopWatch.stop()
$Minutes = [math]::Round($StopWatch.Elapsed.TotalMinutes,0)
$Seconds = [math]::Round($StopWatch.Elapsed.TotalSeconds,0)
Write-Host "Download time taken (Minutes:Seconds): $($Minutes):$($Seconds)"