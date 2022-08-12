# export envs
function ExportEnvs([hashtable]$newEnvs)
{
    foreach ($key in $newEnvs.Keys)
    {
        [Environment]::SetEnvironmentVariable($key, $newEnvs[$key] , 'Process')
        [Environment]::SetEnvironmentVariable($key, $newEnvs[$key] , 'User')
    }
}

# create link
function MakeLink([string]$linkto , [string]$target)
{
    # Symbolic links cannot be used due to permissions
    if ( (Get-Item $target) -is [System.IO.DirectoryInfo] )
    {
        cmd /c "mklink" /J $linkto $target
    }
    else
    {
        cmd /c "mklink" /h $linkto $target
    }
}

function UnLink([string]$link)
{
    cmd /c "rmdir" $link
}

# deploy
function DeployDotfiles([hashtable]$dotfiles)
{
    foreach ($linkto in $dotfiles.Keys)
    {
        $target = $dotfiles[$linkto]
        UnLink $linkto
        MakeLink $linkto $target
    }
}


function main
{
    $env:DOTFILES_PATH = "$PSScriptRoot\.."
    # import
    Import-Module .\vars\exports.psm1
    Import-Module .\vars\dotfiles.psm1

    ExportEnvs $exports
    DeployDotfiles $dotfiles

    # install vscode extentions
    # Get-Content .\vscode\extentions | ForEach-Object{ code --install-extension $_ }
}

main

