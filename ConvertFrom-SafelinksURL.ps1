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
    }

    Process
    {
        Foreach ($URL in $SafeLinkURL)
        {
            $URLData = ((([System.Web.HttpUtility]::UrlDecode($url) -split "url=")[1])  -split '&data')[0]
            $URLUserData = (((([System.Web.HttpUtility]::UrlDecode($url) -split "url=")[1])  -split '&data')[1] -split "\|")[2]
            $ConvertedURLData = [PSCustomObject]@{
                URL = $URLData
                User = $URLUserData
            }
            [void]$ConvertedURLs.Add($ConvertedURLData)
        }
    }

    End
    {
        Return $ConvertedURLs
    }
}