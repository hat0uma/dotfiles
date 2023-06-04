Set-StrictMode -Version Latest

# install git and other apps
Invoke-WebRequest -useb raw.githubusercontent.com/rikuma-t/dotfiles/main/win/setup_apps.ps1 | Invoke-Expression

Set-Location $HOME
git clone https://github.com/rikuma-t/dotfiles

Set-Location dotfiles
.\win\setup_envs.ps1
.\win\setup_links.ps1
make neovim

