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
        [System.Collections.ArrayList]$ConvertedURLs = @()
        Add-Type -AssemblyName System.Web
    }

    Process
    {
        Foreach ($URL in $SafeLinkURL)
        {
            $BaseURLData = [System.Web.HttpUtility]::UrlDecode($url) -split "\|"
            $URLData = ($BaseURLData[0] -split "=")[1] -replace "&amp" -replace "[&;]data"
            $ConvertedURLData = [PSCustomObject]@{
                URL  = $URLData
                User = $BaseURLData[2]
            }
            [void]$ConvertedURLs.Add($ConvertedURLData)
        }
    }

    End
    {
        Return $ConvertedURLs
    }
}