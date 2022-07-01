################## Load Functions ##################
function New-CommentBox () {
    param([string]$titleText)
    $lines = $titleText.Split("`n")
    $output = "$("#"*70)`n"
    $output += "#$(" "*68)#`n"

    foreach($line in $lines){
        if($line.Length -gt 65){
            $line = $line.Substring(0,66)
        }
        $line = $line.Trim()
        $lspaces = ([math]::Floor((68-$line.trim().Length)/2))
        $rspaces = (68-$lspaces-$line.Length)
        $output += "#$(" "*$lspaces)$($line.trim())$(" "*$rspaces)#`n"

    }
    $output += "#$(" "*68)#`n"
    $output += "$("#"*70)`n"
    return $output
}

################## Set Theme Options ##################
#Powerline setup https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup
#Nerd Font: https://www.nerdfonts.com/font-downloads
# - Nerd font used: Hack Nerd Font

If ((Get-Host).Name -ne 'Visual Studio Code Host') {
    Import-Module posh-git
    Import-Module oh-my-posh
    Import-Module -Name Terminal-Icons
    Set-PoshPrompt powerlevel10k_rainbow
    #Set-PoshPrompt C:\Users\timuessi\Documents\PowerShell\Modules\oh-my-posh\themes\My-Aliens.omp.json
    #Set-PoshPrompt C:\Users\timuessi\Documents\PowerShell\Modules\oh-my-posh\themes\blue-owl.omp.json
    #Set-PoshPrompt -Theme Blue-Owl #Aliens #Paradox
}

################## Set PSReadline Options ##################
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView  # InLineView  or ListView
Set-PSReadLineOption -Colors @{ InLinePrediction = "`e[36;7;238m" }

Write-Host "PowerShell "  -ForegroundColor Green -noNewLine
Write-Host "$($PSVersionTable.PSEdition)"  -ForegroundColor Red -NoNewLine

Write-Host " "

Set-Location C:\
