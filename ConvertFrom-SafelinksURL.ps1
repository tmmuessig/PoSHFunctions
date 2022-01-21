Function ConvertFrom-SafelinksURL
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [String[]]
        $SafeLinkURL
    )

    Begin
    {
        Add-Type -AssemblyName System.Web
    }

    Process
    {
        Foreach ($URL in $SafeLinkURL)
        {
            $BaseURLData = [System.Web.HttpUtility]::UrlDecode($url) -split "\|"
             [PSCustomObject]@{
                URL  = ($BaseURLData[0] -split "=")[1] -replace "&amp" -replace "[&;]data"
                User = $BaseURLData[2]
            }
        }
    }
}