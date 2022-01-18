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
            $URL = (($URL.Remove(0, 52) -replace '%3A', ':' -replace '%2F', "/") -split "&")[0] 
            [void]$ConvertedURLs.Add($URL)
        }
    }

    End
    {
        $ConvertedURLs
    }
}
