Set-StrictMode -Version Latest

# install git and other apps
Invoke-WebRequest -useb raw.githubusercontent.com/hat0uma/dotfiles/main/win/setup_apps.ps1 | Invoke-Expression

Set-Location $HOME
git clone https://github.com/hat0uma/dotfiles

Set-Location dotfiles
.\win\setup_envs.ps1
.\win\setup_links.ps1
make neovim

