param(
    [CmdletBinding()]

    [Parameter(Mandatory=$false)]
    [string] $Uri = "$($env:server2019iso)",

    [Parameter(Mandatory=$false)]
    [string] $Outfile = "C:/projects/packer-windows/server2019.iso"
)

$StopWatch = [system.diagnostics.stopwatch]::StartNew()


try{
    Write-Host "Starting file download [$Uri]."
    Invoke-WebRequest -Uri $Uri -OutFile $Outfile -TimeoutSec 1200
    Write-Host "File saved to: [$OutFile]."
}
catch{
    Write-Error "Failed to download file. Error: $($_.Exception.Message)"
    break
}

$StopWatch.stop()
$Minutes = [math]::Round($StopWatch.Elapsed.TotalMinutes,0)
$Seconds = [math]::Round($StopWatch.Elapsed.TotalSeconds,0)
Write-Host "Download time taken (Minutes:Seconds): $($Minutes):$($Seconds)"