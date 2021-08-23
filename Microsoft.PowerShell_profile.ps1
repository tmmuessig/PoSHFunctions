#Jumping off point for a PowerShell Console Profile

#Ensure the console is set to desired size
$Width = 160
$Height = 55
$Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($Width, 3000)
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($Width, $Height)

Write-Host "PowerShell "  -ForegroundColor Green -noNewLine
Write-Host "$($PSVersionTable.PSEdition)"  -ForegroundColor Red -NoNewLine

#Powerline setup https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

If (-not($PSVersionTable.PSVersion -like "7.2*"))
{
    import-module az.tools.predictor # Used for the PredictionSource plugin
}


Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView # InLineView  or ListView
Set-PSReadLineOption -Colors @{ InLinePrediction = "`e[36;7;238m" }