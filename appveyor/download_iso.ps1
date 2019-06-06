param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $Uri = "$($env:server2019iso)",

    [Parameter(Mandatory=$false)]
    [string] $Outfile = ".\server2019.iso"
)

$StopWatch = [system.diagnostics.stopwatch]::StartNew()
$WebClient = New-Object System.Net.WebClient -EA Stop

try{
    Write-Host "Starting file download [$Uri]."
    $WebClient.DownloadFile($Uri,$OutFile)
}
catch{
    Write-Error "Failed to download file. Error: $($_.Exception.Message)"
    break
}

$StopWatch.stop()
$Minutes = [math]::Round($StopWatch.Elapsed.TotalMinutes,0)
$Seconds = [math]::Round($StopWatch.Elapsed.TotalSeconds,0)
Write-Host "Download time taken (Minutes:Seconds): $($Minutes):$($Seconds)"