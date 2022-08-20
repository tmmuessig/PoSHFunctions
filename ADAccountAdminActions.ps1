Function Get-ADAccountAdminActions
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [String[]]
        $SamAccountName,

        [Parameter()]
        [Switch]
        $UsePDC

    )

    Begin
    {
        $Data = [System.Collections.ArrayList]::new()
        Write-Verbose "Getting PDC Emulator"
        If ($UsePDC)
        {
            $Server = (Get-ADDomain).PDCEmulator
        }
        Else
        {
            $Server = (Get-ADDomainController).HostName
        }
        Write-Verbose "Using Domain Controller - $Server"
    }

    Process
    {
        
        Foreach ($Account in $SamAccountName) 
        {
            Try 
            {
                Write-Verbose "Getting $Account from $Server to determine object type"
                $Object = Get-ADObject -Filter { SamAccountName -eq $Account } -Properties *
                If (-not($Object))
                {
                    $pcName = $Account + '$'
                    $Object = Get-ADObject -Filter { SamAccountName -eq $pcName } -Properties *
                }
                Switch ($Object.ObjectClass)
                {
                    'User' { $Attribute = 'Drink' }
                    'Computer' { $Attribute = 'CarLicense' }
                }
                Write-Verbose "Using Attribute - $Attribute"
                $tData = $Object.$Attribute -split "~" | ForEach-Object { ConvertFrom-Csv $_ -Header "ActionDate", "Action", "Name" } | Select-Object @{l = 'Account'; e = { $Object.Name } }, @{l = 'SamAccountName'; e = { $Object.SamAccountName } }, @{l = 'ActionDate'; e = { [DateTime]$_.ActionDate } }, Action, Name | Sort-Object ActionDate -Descending
                [Void]$Data.Add($tData)
        
            }
            Catch 
            {
                Write-Warning "$Account not found on $Server"        
            }
        }
    }

    End
    {
        Return ($Data)
    }
}

Function Set-ADAccountAdminActions
{
    [CmdletBinding()]
    Param
    (
        
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $SamAccountName,

        [Parameter()]
        [String]
        $Action

    )
    Begin
    {
        $Data = [System.Collections.ArrayList]::new()
        Write-Verbose "Getting PDC Emulator"
        $Server = (Get-ADDomain).PDCEmulator
        Write-Verbose "Found PDC Emulator - $Server"
    }

    Process
    {
        Foreach ($Account in $SamAccountName) 
        {
            $EntryDate = Get-Date -Format 'MM/dd/yyyy hh:mm:ss'
            Try 
            {
                Write-Verbose "Attempting to get $Account from $Server"
                $Object = Get-ADObject -Filter { SamAccountName -eq $Account } -Properties *
                If (-not($Object))
                {
                    $pcName = $Account + '$'
                    $Object = Get-ADObject -Filter { SamAccountName -eq $pcName } -Properties *
                }
            }
            Catch 
            {
                Write-Warning "$Account was not found!"
                return
            }

            Switch ($Object.ObjectClass)
            {
                'User' { $Attribute = 'Drink' }
                'Computer' { $Attribute = 'carLicense' }
            }
            $isSingleValued = Get-ADObject -Filter { lDAPDisplayName -eq $Attribute } -SearchBase $(Get-ADRootDSE).schemaNamingContext -Properties isSingleValued | Select-Object -ExpandProperty isSingleValued

            $Action = $Action -replace ",", ";" # replace any commas entered by the user to preserve the CSV separator
            $ExistingData = $false
            If (($Object.$Attribute).Length -gt 0)
            {
                Write-Verbose "$($Object.Name) has existing Attribute Data"
                $ExistingData = $true
            }
            if ($ExistingData)
            {
                if ($isSingleValued -eq 'true')
                {
                    $NewData = "$EntryDate" + "," + "$Action" + "," + "$env:USERNAME" + "~" + $Object.$Attribute
                }
                Else
                {
                    $NewData = "$EntryDate" + "," + "$Action" + "," + "$env:USERNAME"
                }
            }
            Else
            {
                Write-Verbose "$($Object.Name) existing data not found"
                $NewData = "$EntryDate" + "," + "$Action" + "," + "$env:USERNAME"
            }
        
            Write-Verbose "Setting $($Object.Name) with $NewData"
            If ($isSingleValued -eq 'true')
            {
                Set-ADObject $Object -Replace @{$Attribute = $NewData }
            }
            Else
            {
                Set-ADObject $Object -Add @{$Attribute = $NewData }
            }
            
        }
    }

    End
    {

    }
}
