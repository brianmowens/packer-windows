# What is ngen and why are we running it during image builds?
# http://support.microsoft.com/kb/2570538
# http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/
# https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator

if($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){
    Write-Output "Running pre-compile of .net assemblies for AMD64"
    Start-Process "$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" -ArgumentList "update","/force","/queue"
    Start-Process "$env:windir\microsoft.net\framework64\v4.0.30319\ngen.exe" -ArgumentList "update","/force","/queue"
    Start-Process "$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" -ArgumentList "executequeueditems"
    Start-Process "$env:windir\microsoft.net\framework64\v4.0.30319\ngen.exe" -ArgumentList "executequeueditems"

}
else{
    Write-Output "Running pre-compile of .net assemblies for x86"
    Start-Process "$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe"  -ArgumentList "update","/force","/queue"
    Start-Process "$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" -ArgumentList "executequeueditems"
}

Write-Output "Finished pre-compiling."