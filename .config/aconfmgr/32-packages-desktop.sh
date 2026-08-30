# Hyprland session
AddPackage acpi
AddPackage brightnessctl # Lightweight brightness control tool
AddPackage gobject-introspection
AddPackage hyprland
AddPackage network-manager-applet # provides nm-connection-editor, used from the AGS bar's Wi-Fi panel
AddPackage qt5-wayland
AddPackage qt6-wayland
AddPackage swaybg
AddPackage swaylock
AddPackage xdg-desktop-portal-hyprland

# Astal/AGS desktop shell
AddPackage --foreign aylurs-gtk-shell-git
AddPackage --foreign libastal-meta
AddPackage --foreign libastal-brightness-git

# Input method
AddPackage fcitx5
AddPackage fcitx5-configtool
AddPackage fcitx5-gtk
AddPackage fcitx5-mozc
AddPackage fcitx5-qt

# Applications and Wayland utilities
AddPackage easyeffects
AddPackage file-roller
AddPackage firefox
AddPackage foot
AddPackage grim
AddPackage kvantum
AddPackage libnotify
AddPackage mpv
AddPackage pcmanfm-qt
AddPackage slurp
AddPackage swappy
AddPackage wezterm
AddPackage wl-clipboard
AddPackage wofi

# Fonts and icons
AddPackage noto-fonts-cjk
AddPackage noto-fonts-emoji
AddPackage otf-font-awesome
AddPackage papirus-icon-theme
AddPackage pop-icon-theme
AddPackage ttf-nerd-fonts-symbols # High number of extra glyphs from popular 'iconic fonts'
AddLocalPackage ttf-plemoljp

AddPackage gnome-keyring # Stores passwords and encryption keys

# applications
AddPackage --foreign 1password
AddPackage --foreign 1password-cli # 1Password command line tool
AddPackage --foreign google-chrome
AddPackage --foreign visual-studio-code-insiders-bin
AddPackage --foreign webcord-bin

# Appearance
AddPackage --foreign catppuccin-cursors-frappe
AddPackage --foreign catppuccin-fcitx5-git
AddPackage --foreign catppuccin-gtk-theme-frappe
AddPackage --foreign kvantum-theme-catppuccin-git
