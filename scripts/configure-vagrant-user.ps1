
# Apply vagrant public insecure key to vagrant user for SSH use
<# 
####### !! Lot of issues getting the authorized_keys file copied in the correct encoding. 
Write-Output "Ensuring PowerShell is using TLS 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Output "Setting PowerShell output encoding to utf8"
$PSDefaultParameterValues['Out-File:Encoding'] = "utf8"

Write-Output "Obtaining vagrant insecure public key"
$VagrantInsecureKey = (curl -Uri "https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub" -UseBasicParsing).Content 

Write-Output "Creating authorized_keys file"
New-Item -Path "C:\Users\vagrant\.ssh\authorized_keys" -Force | Out-Null

Write-Output "Setting content of authorized_keys"
$VagrantInsecureKey >> "C:\Users\vagrant\.ssh\authorized_keys"

Write-Output "Fixing permissions on authorized_keys"
Repair-AuthorizedKeyPermission "C:\Users\vagrant\.ssh\authorized_keys" -Confirm:$False
#>
if(Test-Path "a:\authorized_keys"){
    Write-Output "Found supplied authorized_keys file."
    if(!(Test-Path "C:\Users\vagrant\.ssh")){
        Write-Output "Creating .ssh directory"
        New-Item -ItemType Directory -Path "C:\Users\vagrant\.ssh"
    }
    Write-Output "Copying authoried_keys file"
    Copy-Item -Path "a:\authorized_keys" -Destination "C:\Users\vagrant\.ssh\authorized_keys" -Force
}
else{
    Write-Error "Unable to locate a:\authorized_keys file"
}
