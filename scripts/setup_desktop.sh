#!/usr/bin/env bash

########################
# window manager
########################
# install wm,dm
yay -S --noconfirm \
	acpi \
	brightnessctl \
	eww-hyprland-tray \
	gobject-introspection \
	hyprland-git \
	network-manager-applet \
	otf-font-awesome \
	qt5-wayland \
	qt6-wayland \
	swaybg \
	ttf-twemoji-color \
	papirus-icon-theme \
	pop-icon-theme \
	xdg-desktop-portal-hyprland

########################
# display manager
########################
say -S --noconfirm \
	greetd \
	greetd-tuigreet

sudo systemctl enable --now greetd
cat <<EOF | sudo tee /etc/greetd/config.toml
[terminal]
vt = 1
[default_session]
command = "tuigreet --time --time-format='%Y/%m/%d %H:%M' --remember --remember-session --asterisks --cmd='zsh --login -c Hyprland'"
EOF

########################
# ime
########################
# install ime
# and also see https://github.com/hyprwm/Hyprland/issues/2433#issuecomment-1807419531
yay -S --noconfirm \
	fcitx5 \
	fcitx5-configtool \
	fcitx5-gtk \
	fcitx5-mozc \
	fcitx5-qt

########################
# other applications
########################
# install applications
yay -S --noconfirm \
	wl-clipboard \
	firefox \
	foot \
	wezterm \
	wofi \
	slurp \
	webcord-bin \
	grim \
	swaync \
	swappy \
	kvantum \
	libnotify \
	1password \
	pcmanfm-qt \
	file-roller \
	visual-studio-code-insiders-bin \
	neofetch \
	easyeffects \
	swaylock \
	mpv

# gh auth login
# gh auth setup-git

# install themes
yay -S --noconfirm \
	catppuccin-gtk-theme-frappe \
	catppuccin-cursors-frappe \
	catppuccin-fcitx5-git \
	kvantum-theme-catppuccin-git

# add flags
flags='s/^\(Exec=[^ ]\+\)/\1 --ozone-platform=wayland --enable-wayland-ime/g'
sed "${flags}" /usr/share/applications/webcord.desktop | tee ~/.local/share/applications/webcord.desktop
sed "${flags}" /usr/share/applications/visual-studio-code-insiders.desktop | tee ~/.local/share/applications/visual-studio-code-insiders.desktop

########################
# nvidia
########################
yay -S --noconfirm \
	nvidia-dkms

# steam
# yay -S steam
