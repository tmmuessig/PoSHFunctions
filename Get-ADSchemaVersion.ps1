Function Get-ADSchemaVersion
{
    [CmdletBinding()]
    Param ()
    Begin 
    {
        Import-Module ActiveDirectory
        $Domain = Get-ADDomain
    }

    Process 
    {
        $Schema = (Get-ADObject (Get-ADRootDSE).SchemaNamingContext -Properties objectVersion).ObjectVersion
        Switch ($Schema)
        {
            13 { $Label = "Windows Server 2000" }
            30 { $Label = "Windows Server 2003" }
            31 { $Label = "Windows Server 2003 R2" }
            44 { $Label = "Windows Server 2008" }
            47 { $Label = "Windows Server 2008 R2" }
            56 { $Label = "Windows Server 2012" }
            69 { $Label = "Windows Server 2012 R2" }
            87 { $Label = "Windows Server 2016" }
            88 { $Label = "Windows Server 2019" }
            88 { $Label = "Windows Server 2022" }
        }
        Write-Host "The Domain $($Domain.name) is running Schema Version $Schema ($Label) in the Forest $($Domain.forest)"
    }

    End { }
}