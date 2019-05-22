
if ( $env:PACKER_BUILD_TYPE -eq "hyperv") {
    Write-Output "Skipping compact steps in Hyper-V build."
    exit
}

Write-Output "Ensuring PowerShell is using TLS 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create a webclient because of redirects downloading from sourceforge. Invoke-Webrequest returns invalid files.
$WebClient = New-Object System.Net.WebClient

if(! (Test-Path "C:\Windows\Temp\ultradefrag.zip")){
    Write-Output "Downloading UltraDefrag"
    $WebClient.DownloadFile("https://downloads.sourceforge.net/project/ultradefrag/stable-release/6.1.0/ultradefrag-portable-6.1.0.bin.amd64.zip","C:\Windows\Temp\ultradefrag.zip")
}

if(! (Test-Path "C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe")){
    Write-Output "Expanding UltraDefrag archive."
    Expand-Archive -Path "C:\Windows\Temp\ultradefrag.zip" -DestinationPath "C:\Windows\Temp"
}

if(! (Test-Path "C:\Windows\Temp\SDelete.zip")){
    Write-Output "Downloading SDelete"
    $WebClient.DownloadFile("https://download.sysinternals.com/files/SDelete.zip","C:\Windows\Temp\SDelete.zip")
}

if(! (Test-Path "C:\Windows\Temp\sdelete.exe")){
    Write-Output "Expanding SDelete Archive"
    Expand-Archive -Path "C:\Windows\Temp\SDelete.zip" -DestinationPath "C:\Windows\Temp"
}

Write-Output "Clearing SoftwareDistribution Downloads"
try{
    Write-Output "Stopping wuauserv service"
    Stop-Service wuauserv -Force
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force
    New-Item -ItemType Directory -Path "C:\Windows\SoftwareDistribution\Download"
    Write-Output "Starting wuauserv service"
    Start-Service wuauserv
}
catch{
    Write-Error "Failed to clear SoftwareDistribution Downloads. Error: $($_.Exception.Message)"
}

if($env:PACKER_BUILDER_TYPE -ne "hyperv-iso"){
    Write-Output "Running UDefrag"
    Start-Process "C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe" -ArgumentList "--optimize","--repeat C:" -Wait
    
    Write-Output "Adding SDelete EulaAccepted registry key."
    New-Item -Path "HKCU:\Software\Sysinternals\SDelete" -Force
    Set-ItemProperty -Path "HKCU:\Software\Sysinternals\SDelete" -Name 'EulaAccepted' -Value 1
    
    Write-Output "Running SDelete"
    Start-Process "C:\Windows\Temp\sdelete.exe" -ArgumentList "-q","-z C:"
}