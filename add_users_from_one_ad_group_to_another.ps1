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


write-host "All users and groups from SOURCE-group will be added to TARGET-group`n"
write-host "Enter (without quotes) SOURCE-group:"
$ADGroupNameFrom=(read-host).trim()
write-host
write-host "Enter (without quotes) TARGET-group::"
$ADGroupNameTo=(read-host).trim()
Write-Host


## With extracting users from sub-groups
# $ADUsersFrom=Get-ADGroupMember -Identity "$ADGroupNameFrom"  -Recursive
# $ADUsersTo=Get-ADGroupMember -Identity "$ADGroupNameTo" -Recursive

## Without extracting users from sub-groups
$ADUsersFrom=Get-ADGroupMember -Identity "$ADGroupNameFrom"
$ADUsersTo=Get-ADGroupMember -Identity "$ADGroupNameTo"

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
