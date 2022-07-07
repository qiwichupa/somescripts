function Prompt-Continue{
    while(-1){
        switch (Read-Host '(Y/N)'){
            Y { 
                Write-Host Continue... -fore green
                return 
              }
            N { exit }
            default { Write-Host 'Only Y/N valid' -fore red }
        }
    }
}

filter leftside{
param(
        [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $obj
    )

    $obj|?{$_.sideindicator -eq '<='}

}


$currentDomain = (Get-ADDomain).NetBIOSName

write-host "All users and groups from SOURCE-group will be added to TARGET-group`n"
write-host "Current domain: $currentDomain"

$domainFromCheck = $false
while  ( $domainFromCheck -eq $false ) 
    {
        write-host "Enter SOURCE-domain [$currentDomain]:"
        $ADDomainFrom=(read-host).trim()
        if ($ADDomainFrom -eq '') {$ADDomainFrom=$currentDomain}
        if ( Get-ADDomainController -Discover -Domain $ADDomainFrom )
        {
            $ADDomainFromDC=(Get-ADDomainController -Discover -Domain $ADDomainFrom).HostName[0]
            $domainFromCheck = $true
        }
    }


if ($ADDomainFrom -ne $currentDomain)
{
    $credcheck=$false
    while ($credcheck -eq $false)
    {
        write-host "Enter username for ${ADDomainFrom}:"
        $ADDomainFromUsername=(read-host).trim()
        write-host "Enter password for ${ADDomainFrom}\${ADDomainFromUsername}:"
        #$ADDomainFromPassword=(read-host).trim()
        #$ADDomainFromPasswordSec = ConvertTo-SecureString $ADDomainFromPassword -AsPlainText -Force
        $ADDomainFromPasswordSec=(read-host -AsSecureString -Prompt "Enter password for ${ADDomainFrom}\${ADDomainFromUsername}:")
        $ADDomainFromCred = New-Object System.Management.Automation.PSCredential "${ADDomainFrom}\${ADDomainFromUsername}", $ADDomainFromPasswordSec
        
        if ( (Get-ADDomain -Credential $ADDomainFromCred ${ADDomainFrom}) ){ $credcheck=$true }
    }

}

write-host "Enter (without quotes) SOURCE-group:"
$ADGroupNameFrom=(read-host).trim()
write-host
write-host "Enter (without quotes) TARGET-group::"
$ADGroupNameTo=(read-host).trim()
Write-Host


if ($ADDomainFrom -eq $currentDomain)
{
    $ADUsersFrom=Get-ADGroupMember -Identity "$ADGroupNameFrom"
    $ADUsersTo=Get-ADGroupMember -Identity "$ADGroupNameTo"
} 
else 
{
    write-host "Extract SOURCE-group? [Y/n]:"
    $extract=(read-host).trim()
    if ($extract -eq '' -or $extract -eq 'Y'){
        $ADUsersFrom=Get-ADGroupMember -server $ADDomainFromDC `
                                       -credential $ADDomainFromCred  `
                                       -Identity "$ADGroupNameFrom" `
                                       -Recursive
    
    } 
    else 
    {
        $ADUsersFrom=Get-ADGroupMember -server $ADDomainFromDC `
                                       -credential $ADDomainFromCred  `
                                       -Identity "$ADGroupNameFrom"
    }

    $ADUsersTo=Get-ADGroupMember -Identity "$ADGroupNameTo" 

}

$users=@()
if ($ADUsersFrom){
    if ($ADUsersTo){
        Compare-Object $ADUsersFrom $ADUsersTo | leftside | ForEach-Object {
            $users+=$_.InputObject
        }
    }else{
    $users = $ADUsersFrom
    }
}

Write-Host $ADGroupNameFrom ":  " $ADUsersFrom.Count " users and groups."
Write-Host $ADGroupNameTo ": " $ADUsersTo.Count " users and groups."
Write-Host "Will be added to " $ADGroupNameTo ":" $users.Count " users and groups"
Write-Host 
Write-Host "Continue?"
Prompt-Continue

Add-ADGroupMember -Identity "$ADGroupNameTo" -Members $users
