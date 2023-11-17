#!/usr/bin/env bash

# install ime
yay -S --noconfirm \
	fcitx5 \
	fcitx5-configtool \
	fcitx5-gtk \
	fcitx5-mozc \
	fcitx5-qt

# add sway envs
cat <<EOF | sudo tee /usr/local/bin/start-sway
#!/bin/env bash
swayenv="\$XDG_CONFIG_HOME/sway/env"
if [[ -f \$swayenv ]]; then
	source \$swayenv
fi
sway
EOF
sudo chmod +x /usr/local/bin/start-sway

sudo mkdir -p /usr/local/share/wayland-sessions
cat <<EOF | sudo tee /usr/share/wayland-sessions/sway-envs.desktop
[Desktop Entry]
Name=Sway(with envs)
Comment=An i3-compatible Wayland compositor
Exec=start-sway
Type=Application
EOF

# chrome settings
cat <<EOF >"$XDG_CONFIG_HOME/chrome-flags.conf"
--enable-features=UseOzonePlatform
--ozone-platform=wayland
--gtk-version=4
EOF
