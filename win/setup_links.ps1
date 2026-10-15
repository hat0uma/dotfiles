Set-StrictMode -Version Latest
$env:DOTFILES_PATH = "$PSScriptRoot\.."
$links = @{
    # NOTE: linkto = src
    "$env:XDG_CONFIG_HOME\nvim\"              = "$env:DOTFILES_PATH\.config\nvim"
    "$env:APPDATA\alacritty\"                 = "$env:DOTFILES_PATH\.config\alacritty"
    "$env:USERPROFILE\.goneovim\"             = "$env:DOTFILES_PATH\.config\goneovim"
    "$env:USERPROFILE\.config\wezterm"        = "$env:DOTFILES_PATH\.config\wezterm"
    "$env:USERPROFILE\.glzr"                  = "$env:DOTFILES_PATH\.config\glzr"
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

function Unlink ([string]$path)
{
    if (-not (Test-Path $path))
    {
        # Write-Host "The specified path '$path' does not exist."
        return
    }
    
    $item = Get-Item $path
    
    if ($item.LinkType -eq "HardLink" -or $item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction")
    {
        Write-Host "Removing link at '$path'."
        Remove-Item $path
    } elseif ($item.PSIsContainer)
    {
        Write-Host "Skipping directory '$path'."
    } else
    {
        Write-Host "Skipping file '$path'."
    }
}

# create profile dir
$profileDir = Split-Path -Parent $PROFILE
mkdir -Force $profileDir > $null

# link
foreach ($linkto in $links.Keys)
{
    $target = $links[$linkto]
    UnLink $linkto
    MakeLink $linkto $target
}

# Windows Terminal
# Windows Terminal rewrites settings.json atomically, which breaks hard links.
# Use a symbolic link (requires Developer Mode or admin), otherwise fall back to copying.
$wtSettings = "$env:DOTFILES_PATH\.config\windows-terminal\settings.json"
$wtPackages = @(
    "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
    "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe"
)
foreach ($package in $wtPackages)
{
    $localState = "$env:LOCALAPPDATA\Packages\$package\LocalState"
    if (-not (Test-Path $localState))
    {
        continue
    }

    $linkto = "$localState\settings.json"
    if ((Test-Path $linkto) -and -not (Get-Item $linkto).LinkType)
    {
        Write-Host "Backing up '$linkto'."
        Move-Item -Force $linkto "$linkto.bak"
    }
    UnLink $linkto
    try
    {
        New-Item -ItemType SymbolicLink -Path $linkto -Target $wtSettings -ErrorAction Stop > $null
    } catch
    {
        Write-Warning "Cannot create symbolic link for '$linkto'. Copying instead."
        Copy-Item $wtSettings $linkto
    }
}
