# exports VMs list with IPs and all custom attributes

function Export-VMInfo{
    
    [CmdletBinding()]
    param(
    $vcenter
    )

    Connect-VIServer -Server $vcenter

    foreach ($vm in $(Get-VM | Sort-Object)) 
    { 
        $ip = [system.String]::Join(", ", $vm.Guest.IPAddress)
                            
        $vmObj = New-Object -TypeName PSObject
        Add-Member -InputObject $vmObj -MemberType NoteProperty -Name "vCenter Server" -Value $vcenter
        Add-Member -InputObject $vmObj -MemberType NoteProperty -Name Name -Value $vm.Name 
        Add-Member -InputObject $vmObj -MemberType NoteProperty -Name IPs -Value $ip 

        foreach ($vmannlist in $(Get-Annotation $vm))
        {
            $Name = $vmannlist.Name
            $Value = $vmannlist.Value
            Add-Member -InputObject $vmObj -MemberType NoteProperty -Name "$Name" -Value "$Value"
        }
                        
        $script:vms += $vmObj
    } 
}

# settings
$vcenters = @('vc1.local', 'vc2.local')
$Path = "C:\vms_info\"

# main code
$Date = Get-Date -format  "yyyyMMddHms"
$vms = @()
$LastestFile = Get-ChildItem -Path $Path | Sort-Object | Select-Object -Last 1

foreach ($vcenter in $vcenters)
{
    Export-VMInfo -vcenter $vcenter 
}

$script:vms | Export-Csv -Delimiter ";" -Encoding "Unicode" -NoTypeInformation -Path $Path"vms_fields_"$Date".csv"
$script:vms | Export-Csv -Delimiter ";" -Encoding "Unicode" -NoTypeInformation -Path $Path"vms_fields_latest.csv"

$CurrentFile = Get-ChildItem -Path $Path | Sort-Object | Select-Object -Last 1

if ( (Get-FileHash $LastestFile.PSPath).Hash -eq (Get-FileHash $CurrentFile.PSPath).Hash )
{
    $LastestFile.PSPath + ": " + (Get-FileHash $LastestFile.PSPath).Hash
    $CurrentFile.PSPath + ": " + (Get-FileHash $CurrentFile.PSPath).Hash
    Remove-Item $LastestFile.PSPath
}
