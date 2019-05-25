
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string] $auditphase = $env:AUDIT_PHASE,

    [Parameter(Mandatory=$false)]
    [string] $logdirectory = "C:\Packer\Logs\build_audit"
)

# In case the environment variable was null or an empty string, lets default to "initial"
# This is only used for naming of the output files, as we want to run this audit before and after
# running updates to get a complete picture of what has been installed via updates.
if($auditphase -eq "" -or $null -eq $auditphase){
    Write-Output "Did not determine that auditphase value was defined. Default to initial."
    $auditphase = "initial"
}

# Convert Wua History ResultCode to a Name # 0, and 5 are not used for history # See https://msdn.microsoft.com/en-us/library/windows/desktop/aa387095(v=vs.85).aspx
function Convert-WuaResultCodeToName {
    param( [Parameter(Mandatory = $true)]
        [int] $ResultCode
    )
    $Result = $ResultCode
    switch ($ResultCode) {
        2 {
            $Result = "Succeeded"
        }
        3 {
            $Result = "Succeeded With Errors"
        }
        4 {
            $Result = "Failed"
        }
    }
    return $Result
}
function Get-WuaHistory {
    # Get a WUA Session
    $session = (New-Object -ComObject 'Microsoft.Update.Session')
    # Query the latest 1000 History starting with the first recordp
    $history = $session.QueryHistory("", 0, 50) | ForEach-Object {
        $Result = Convert-WuaResultCodeToName -ResultCode $_.ResultCode
        # Make the properties hidden in com properties visible.
        $_ | Add-Member -MemberType NoteProperty -Value $Result -Name Result
        $Product = $_.Categories | Where-Object { $_.Type -eq 'Product' } | Select-Object -First 1 -ExpandProperty Name
        $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.UpdateId -Name UpdateId
        $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.RevisionNumber -Name RevisionNumber
        $_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
        Write-Output $_
    }
    #Remove null records and only return the fields we want
    $history |
    Where-Object { ![String]::IsNullOrWhiteSpace($_.title) } |
    Select-Object Result, Date, Title, SupportUrl, Product, UpdateId, RevisionNumber
}

if(!(Test-Path -Path "$logdirectory")){
    Write-Output "Creating build_audit directory."
    New-Item -ItemType Directory -Path "$logdirectory" -Force | Out-Null
}

# The below command is a shorter version of: wmic path win32_quickfixengineering get Hotfixid
# We're checking the Quick-Fix Engineering WMIC class for what quickfixes are installed
wmic qfe list >> $($logdirectory)\audit_$($auditphase)_qfe.txt

# The below command executes the functions above and was found in MS support repo's.
# The purpose of this command is to query Windows Update for a list of installed updates.
Get-WuaHistory | Format-Table >> $($logdirectory)\audit_$($auditphase)_wua.txt

# The below command builds a search object to search the windows update history for all
# installed updates.
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$Searcher.Search("IsInstalled=1").Updates | Format-Table -AutoSize Title | Out-File $($logdirectory)\build_audit\audit_$($auditphase)_msupdate.txt