#!/usr/bin/env bash

########################
# window manager
########################
# install wm,dm
yay -S --noconfirm \
	hyprland \
	xdg-desktop-portal-hyprland \
	otf-font-awesome \
	gobject-introspection \
	network-manager-applet \
	eww-hyprland-tray \
	ttf-twemoji-color \
	swaybg \
	brightnessctl \
	acpi

########################
# display manager
########################
say -S --noconfirm \
	sddm \
	rsync \
	qt5-graphicaleffects \
	qt5-svg \
	qt5-suickcontrols2

sudo systemctl enable sddm

git clone https://github.com/catppuccin/sddm /tmp/catppuccin-sddm
cd /tmp/catppuccin-sddm || exit
git pull
sudo rsync -av src/ /usr/share/sddm/themes/

sudo mkdir -p /etc/sddm.conf.d/
cat <<EOF | sudo tee /etc/sddm.conf.d/user.conf
[Autologin]
User=$(whoami)
Session=hyprland
[Theme]
Current=catppuccin-frappe
[wayland]
EnableHiDPI=true
EOF
# edit /usr/share/sddm/themes/catppuccin-frappe/theme.conf
# Font="UDEV Gothic NF"
# FontSize=14

########################
# ime
########################
# install ime
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
	1password

# gh auth login
# gh auth setup-git

# install themes
yay -S --noconfirm \
	catppuccin-gtk-theme-frappe \
	catppuccin-cursors-frappe \
	catppuccin-fcitx5-git \
	kvantum-theme-catppuccin-git
