Write-Output "Installing GitBash CLI using Chocolately"
choco install git -y --force --force-dependencies --no-progress

# http://www.hurryupandwait.io/blog/need-an-ssh-client-on-windows-dont-use-putty-or-cygwinuse-git

$bashPath = 'C:\Program Files\Git\usr\bin\'
if($env:PATH -like "*$bashPath*"){
    Write-Output "PATH already contains path to bash.exe"
}
else{

    if(Test-Path $bashPath){
        Write-Output "Located bash.exe at: $bashPath"
    }
    else{
        Write-Error "Unable to locate bash.exe at provided path: $bashPath"
        exit 1
    }

    Write-Output "Adding bash.exe to PATH"
    $new_path = "$env:PATH;$bashPath"
    $env:PATH = $new_path

    Write-Output "Refreshing environment variables"
    [Environment]::SetEnvironmentVariable("path", $new_path, "Machine")
}