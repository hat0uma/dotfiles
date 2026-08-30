# Boot and base system
AddPackage base
AddPackage base-devel
AddPackage efibootmgr
AddPackage intel-ucode
AddPackage linux
AddPackage linux-firmware
AddPackage mkinitcpio
AddPackage sof-firmware
AddPackage sudo
AddPackage man-db # A utility for reading man pages

# Hardware, networking, and audio
AddPackage bluez
AddPackage bluez-utils
AddPackage gst-plugin-pipewire
AddPackage intel-media-driver
AddPackage libpulse
AddPackage networkmanager
AddPackage pipewire
AddPackage pipewire-alsa
AddPackage pipewire-jack
AddPackage pipewire-pulse
AddPackage vulkan-intel
AddPackage wireplumber
AddPackage wpa_supplicant
AddPackage zram-generator

# power management
AddPackage thermald # The Linux Thermal Daemon program from 01.org
AddPackage tlp      # Linux Advanced Power Management
AddPackage tlp-rdw  # Linux Advanced Power Management - Radio Device Wizard

# This repository manages aconfmgr itself.
AddPackage --foreign aconfmgr-git
AddPackage --foreign yay
AddPackage --foreign yay-debug
