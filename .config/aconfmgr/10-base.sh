# Keep the root directory permissions explicit. aconfmgr otherwise reports this
# as an unmanaged difference on systems installed with a restrictive umask.
SetFileProperty / mode 555

# Machine identity and boot configuration
#CopyFile /etc/kernel/cmdline
CopyFile /etc/mkinitcpio.conf

# Locale and keyboard
CopyFile /etc/locale.conf
CopyFile /etc/locale.gen
CopyFile /etc/vconsole.conf
CopyFile /etc/X11/xorg.conf.d/00-keyboard.conf
CreateLink /etc/localtime /usr/share/zoneinfo/Asia/Tokyo

# Package manager and local policy
CopyFile /etc/pacman.conf
CopyFile /etc/systemd/zram-generator.conf

# power management
CopyFile /etc/tlp.conf
CopyFile /etc/systemd/system/battery-threshold.service
