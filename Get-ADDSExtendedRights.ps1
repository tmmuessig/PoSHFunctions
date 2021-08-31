Function Get-ADDSRightsAssignment
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [ValidateScript( { if ($_ -notmatch "DC=") { throw "Not a legal DN: $_" } Else { Return $True } })]
        [string[]]
        $ADObjectDN,

        [String]
        $IdentityReference = '*'
    )
    
    begin
    {
        $rootDSE = Get-ADRootDSE
        $SchemaLookup = @{ }
        $paramGetADObject = @{
            SearchBase = $rootDSE.SchemaNamingContext
            LDAPFilter = "(schemaIdguid=*)"
            Properties = 'LdapDisplayName', 'SchemaIdGuid'
        }
        Get-ADObject @paramGetADObject | ForEach-Object {
            $SchemaLookup.Add(([Guid]$_.SchemaIdGuid).tostring(), $_.LdapDisplayName)
        }
        $ExtendedRights = @{ }
        $paramGetADObject = @{
            SearchBase  = ("CN=Extended-Rights," + $rootDSE.configurationNamingContext)
            LDAPFilter  = "(ObjectClass=controlAccessRight)"
            Properties  = 'rightsGuid', 'Name'
            ErrorAction = 'SilentlyContinue'
        }
        Get-ADObject @paramGetADObject | ForEach-Object {
            try { $ExtendedRights.Add(([Guid]$_.rightsGuid).tostring(), $_.Name) }
            catch { }
        }
    }
    
    process
    {
        foreach ($distinguishedName in $ADObjectDN)
        {
            foreach ($accessItem in (Get-Acl -Path "AD:$distinguishedName").Access)
            {
                If ($accessItem.IdentityReference -notlike $IdentityReference)
                { Continue }
                $mappedRight = $SchemaLookup.Item($accessItem.ObjectType.guid)
                if (-not ($mappedRight))
                {
                    $mappedRight = $ExtendedRights.Item($accessItem.ObjectType.Guid)
                    if (-Not ($mappedRight)) { $mappedRight = 'All' }
                }
                
                $InheritedObjType = $accessItem.InheritedObjectType
                
                [PSCustomObject] @{
                    ActiveDirectoryRights = $accessItem.ActiveDirectoryRights
                    InheritanceType       = $accessItem.InheritanceType
                    ObjectType            = $mappedRight
                    InheritedObjectType   = $SchemaLookup."$InheritedObjType"
                    ObjectFlags           = $accessItem.ObjectFlags
                    AccessControlType     = $accessItem.AccessControlType
                    IdentityReference     = $accessItem.IdentityReference
                    IsInherited           = $accessItem.IsInherited
                    InheritanceFlags      = $accessItem.InheritanceFlags
                    PropagationFlags      = $accessItem.PropagationFlags
                    DistinguishedName     = $distinguishedName
                }
            }
        }
    }
} 