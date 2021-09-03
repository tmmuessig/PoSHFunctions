Clear-Host

<#
######################################################################
#                                                                    #
#                                ToDo                                #
#                                                                    #
######################################################################

Forest Information
Domain Information
FSMO Role Holders, per domain
Domain Controller List
Replication
Disk Space
Net Share (see where sysvol and netlogon are)
Any event 2889 events (unsecure LDAP) Get-WinEvent -FilterHashtable @{LogName = 'Security';ID=2889}
Repadmin /replsum
Required Services running $Services='DNS','DFS Replication','Intersite Messaging','Kerberos Key Distribution Center','NetLogon',’Active Directory Domain Services’
Ports open (Run my Test-Ports -ADPorts script)
Number of Enterprise and Domain Admins - test if there are nested groups
Check Schem Masters (There should be no one)
Group Policies
Any computer OS that is outside of support e.g. Server 2008
DC Latest Patches
Last Reboot time for each DC
#>

Function Get-ADDSDCInfo
{
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string[]]
        $ComputerName
    )

    Begin {
        $RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
        $RegistryKey  = 'DSA Database file'
    }

    Process
    {
        $ADDSData = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            #$SYSVOLShare = 
            $NTDSKey = Get-ItemProperty -Path $using:RegistryPath -Name $Using:RegistryKey
            [PSCustomObject] @{
                DITLocation = $NTDSKey.'DSA Database file'
                DITSizeInMB = (Get-Item $NTDSKey.'DSA Database file').Length / 1MB
            } 
        } | Select-Object DITLocation, DITSizeInMB, PSComputerName
    }

    End
    {
        Return $ADDSData 
    }
}

Function Get-ADServices
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]
        $ComputerName,

        [Parameter(ValueFromPipeline=$true)]
        [String[]]
        $Service,

        [Parameter()]
        [Switch]
        $ADServices
    )

    Begin {}

    Process
    {
        If ($ADServices)
        {
            $Service +=  @('DNS','DFS', 'DFSR', 'NTDS', 'ADWS', 'GPSVC', 'EventLog', 'W32Time', 'Winmgmt', 'Kdc')
        }
        Get-Service $Service -ComputerName $ComputerName | Select MachineName, ServiceName, Status, StartType
    }

    End {}
}




$FileSavePath = [Environment]::GetFolderPath('Desktop')
$FileSaveName = "ADInfo-" + $(Get-Date -Format yyyyMMdd-hhmmss) + ".txt"
$SavePath = Join-Path $FileSavePath $FileSaveName
$Spacer = $('-'*15)

#For testing only
Get-ChildItem $FileSavePath -Filter *.txt | remove-item -Force
# end for testing

# Get Forest and Domain Information
Write-Host "Getting Forest Information"
"$Spacer Forest Information $Spacer" | Out-File -Append -FilePath $SavePath
$Forest = Get-ADForest
$Forest | Select-Object Name, ForestMode | Format-Table -AutoSize | Out-File -FilePath $SavePath -Append

# Get Domain Information
Write-Host "Getting Domain Information" 
"$Spacer Domain Information $Spacer" | Out-File -FilePath $SavePath -Append
$Domains = $Forest.Domains | ForEach-Object { Get-ADDomain $_ -Server $_ }
$Domains | Select-Object DNSRoot, DomainMode, ChildDomains, AllowedDNSSuffixes | Format-Table -AutoSize | Out-File -FilePath $SavePath -Append

# Get FSMO Role Holders
"$Spacer FSMO Role Holders $Spacer" | Out-File -FilePath $SavePath -Append
Write-Host "FSMO Role Holders"
$FSMO = $Domains | Select-Object @{l = 'DomainName'; e = { $_.DNSRoot } }, PDCEmulator, RIDMaster, InfrastructureMaster, @{l = 'SchemaMaster'; e = { $Forest.SchemaMaster } }, @{l = 'DomainNamingMaster'; e = { $Forest.DomainNamingMaster } }
$FSMO | Out-File -FilePath $SavePath -Append

# Get all Domain Controllers Forest Wide
"$Spacer Forest Domain Controllers $Spacer" | Out-File -FilePath $SavePath -Append
Write-Host "Forest Domain Controllers"
$DomainControllers = $Domains.DNSRoot | ForEach-Object { Get-ADDomainController -filter * -Server $_ }
$DomainControllers | Select-Object Name, Domain, OperatingSystem | Out-File -FilePath $SavePath -Append

# Get DC Information

$DCInfo = Get-ADDSDCInfo -ComputerName $DomainControllers.Name

"$Spacer Domain Controller DIT $Spacer" | Out-File -FilePath $SavePath -Append
$DCInfo | format-table -AutoSize | Out-File -FilePath $SavePath -Append

# Get AD Services
Write-Host "AD Services"
$ADServices = Get-ADServices -ADServices -ComputerName $DomainControllers.Name
"$Spacer AD Services $Spacer" | Out-File -FilePath $SavePath -Append
$ADServices | ft -AutoSize | Out-File -FilePath $SavePath -Append

# Tier 0 Groups
$T0Groups = @()
$T0Groups += Get-ADGroup 'Enterprise Admins' -Server $Forest.Name -properties Members | Select-Object Name, DistinguishedName, @{l = 'MemberCount'; e = { $_.Members.Count } }, @{l = 'Domain'; e = { $Forest.Name } }
$T0Groups += Get-ADGroup 'Schema Admins' -Server $Forest.Name -properties Members | Select-Object Name, DistinguishedName, @{l = 'MemberCount'; e = { $_.Members.Count } }, @{l = 'Domain'; e = { $Forest.Name } }
$T0Groups += $Domains | ForEach-Object { $tDomain = $_.DNSRoot ; Get-ADGroup 'Domain Admins' -Properties Members -Server $_.DNSRoot | Select-Object Name, DistinguishedName, @{l = 'MemberCount'; e = { $_.Members.count } }, @{l = 'Domain'; e = { $tDomain } } }

"$Spacer Tier 0 Groups $Spacer" | Out-File -FilePath $SavePath -Append
Write-Host "Tier 0 Groups"
$T0Groups | Format-Table -AutoSize | Out-File -FilePath $SavePath -Append

#Time Service
"$Spacer Time Service $Spacer" | Out-File -FilePath $SavePath -Append
$NTPServers = Invoke-Command -ComputerName $DomainControllers.Name -ScriptBlock {
                $w32tmOutput = & 'w32tm' "/query" "/configuration"
                [PSCustomObject] @{
                    NTPType = ($w32tmOutput | Select-String "Type:") -replace "`n","" -replace "`n","" -replace "Type: "
                    NtpServer = ($w32tmOutput | Select-String "ntpserver:") -replace "`n","" -replace "`n","" -replace "NtpServer: "
              }
} | Select NTPType, NtpServer, PSComputerName
$NTPServers | Select NTPType, NtpServer, PSComputerName | FT -AutoSize | Out-File -FilePath $SavePath -Append
notepad $SavePath


