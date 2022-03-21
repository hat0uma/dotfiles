$local:dotfiles = @{
    # NOTE: linkto = src
    "$env:XDG_CONFIG_HOME\nvim\"              = "$env:DOTFILES_PATH\.config\nvim"
    "$env:APPDATA\alacritty\"                 = "$env:DOTFILES_PATH\.config\alacritty"
    "$env:USERPROFILE\.goneovim\"             = "$env:DOTFILES_PATH\.config\goneovim"
    "$env:USERPROFILE\.config\wezterm"        = "$env:DOTFILES_PATH\.config\wezterm"
    # "$env:APPDATA\Code\User\keybindings.json" = "$env:DOTFILES_PATH\.config\Code\User\keybindings.json"
    # "$env:APPDATA\Code\User\settings.json"    = "$env:DOTFILES_PATH\.config\Code\User\settings.json"
}

Export-ModuleMember -Variable dotfiles

