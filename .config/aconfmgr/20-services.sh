# Core system services
SystemdEnable --name getty@tty1.service /usr/lib/systemd/system/getty@.service
SystemdEnable /usr/lib/systemd/system/remote-fs.target
SystemdEnable /usr/lib/systemd/system/systemd-userdbd.socket
SystemdEnable /usr/lib/systemd/system/systemd-timesyncd.service
SystemdEnable /usr/lib/systemd/system/fstrim.timer

# Networking and Bluetooth
SystemdEnable /usr/lib/systemd/system/bluetooth.service
# SystemdEnable intentionally does not follow Also= dependencies.
SystemdEnable /usr/lib/systemd/system/NetworkManager.service
SystemdEnable /usr/lib/systemd/system/NetworkManager-dispatcher.service
SystemdEnable /usr/lib/systemd/system/NetworkManager-wait-online.service

# User session services and sockets
SystemdEnable --type user /usr/lib/systemd/user/wireplumber.service
SystemdEnable --type user /usr/lib/systemd/user/p11-kit-server.socket
SystemdEnable --type user /usr/lib/systemd/user/pipewire-pulse.socket
SystemdEnable --type user /usr/lib/systemd/user/pipewire.socket
