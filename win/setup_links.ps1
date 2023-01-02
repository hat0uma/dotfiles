Set-StrictMode -Version Latest
$env:DOTFILES_PATH = "$PSScriptRoot\.."
$links = @{
    # NOTE: linkto = src
    "$env:XDG_CONFIG_HOME\nvim\"              = "$env:DOTFILES_PATH\.config\nvim"
    "$env:APPDATA\alacritty\"                 = "$env:DOTFILES_PATH\.config\alacritty"
    "$env:USERPROFILE\.goneovim\"             = "$env:DOTFILES_PATH\.config\goneovim"
    "$env:USERPROFILE\.config\wezterm"        = "$env:DOTFILES_PATH\.config\wezterm"
    "$profile"                                = "$env:DOTFILES_PATH\win\profile.ps1"
    # "$env:APPDATA\Code\User\keybindings.json" = "$env:DOTFILES_PATH\.config\Code\User\keybindings.json"
    # "$env:APPDATA\Code\User\settings.json"    = "$env:DOTFILES_PATH\.config\Code\User\settings.json"
}

function MakeLink([string]$linkto , [string]$target)
{
    # Symbolic links cannot be used due to permissions
    if ( (Get-Item $target) -is [System.IO.DirectoryInfo] )
    {
        cmd /c "mklink" /J $linkto $target
    } else
    {
        cmd /c "mklink" /h $linkto $target
    }
}

function UnLink([string]$link)
{
    cmd /c "rmdir" $link
}

# link
foreach ($linkto in $links.Keys)
{
    $target = $links[$linkto]
    UnLink $linkto
    MakeLink $linkto $target
}

