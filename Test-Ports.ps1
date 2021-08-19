Function Test-Ports
{
    [CmdletBinding()]
    Param
    (
        [String[]]
        $ComputerName = $env:COMPUTERNAME,

        [int[]]
        $Ports,

        [Switch]
        $ADPorts
    )

    Begin
    {
        If ($ADPorts)
        {
            $Ports += @(42, 53, 88, 135, 139, 389, 445, 464, 636, 3268, 3269, 5985, 9389)
        }
        $PortLookup = [Ordered]@{
            "42"    = "WINS"
            "53"    = "DNS"
            "88"    = "Kerberos"
            "123"   = "NTP (Network Time Protocol)"
            "135"   = "RPC Replication"
            "137"   = "NetBIOS Name Resolution"
            "139"   = "NetLogon"
            "389"   = "LDAP"
            "445"   = "SMB"
            "464"   = "Kerberos Password Set/Change"
            "636"   = "LDAP SSL"
            "3268"  = "LDAP Global Catalog"
            "3269"  = "LDAP Global Catalog SSL"
            "5722"  = "SYSVOL Replication"
            "5985"  = "PowerShell Remoting"
            "9389"  = "Microsoft AD DS Web Services"
        }
        $Results = @()
    }

    Process
    {
        Foreach ($Computer in $ComputerName)
        {
            Foreach ($Port in $Ports)
            {
                Write-Verbose "Testing Port [$Port] on Computer $Computer"
                $Results += Test-NetConnection -ComputerName $Computer -Port $Port | Select-Object ComputerName, NameResolutionSucceeded, PingSucceeded, RemoteAddress, RemotePort, TcpTestSucceeded, @{n = 'PortUse'; e = { $PortLookup["$($_.RemotePort)"] } }
            }
        }
    }

    End
    {
        Return $Results
    }
}