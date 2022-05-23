#Install New apps
$apps = @(
    @{name = "Microsoft.PowerShell" },
    @{name = "Microsoft.VisualStudioCode" },
    @{name = "Microsoft.AzureStorageExplorer" },
    @{name = "Git.Git" },
    @{name = "Microsoft.dotnet" },
    @{name = "GitHub.cli" }
);
Foreach ($app in $apps)
{
    #check if the app is already installed
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name))
    {
        Write-host "Installing:" $app.name
        if ($app.source -ne $null)
        {
            winget install --exact --silent $app.name --source $app.source
        }
        else
        {
            winget install --exact --silent $app.name
        }
    }
    else
    {
        Write-host "Skipping Install of " $app.name
    }
}

# VSCode Extensions to install
$VSCodeExtensions = @"
bencoleman.armview
codezombiech.gitignore
DavidAnson.vscode-markdownlint
docsmsft.docs-visual-areas
eamodio.gitlens
eriklynd.json-tools
GitHub.vscode-pull-request-github
mhutchie.git-graph
ms-azuretools.vscode-bicep
ms-dotnettools.csharp
ms-dotnettools.vscode-dotnet-runtime
ms-vscode.live-server
ms-vscode.powershell
msazurermtools.azurerm-vscode-tools
redhat.vscode-yaml
samcogan.arm-snippets
vector-of-bool.gitflow
vscode-icons-team.vscode-icons
"@ 
$VSCodeExtensions = $VSCodeExtensions.Split(@(“`r”, “`n”), [StringSplitOptions]::RemoveEmptyEntries)
Foreach ($Extension in $VSCodeExtensions)
{
    code --install-extension $Extension
}

