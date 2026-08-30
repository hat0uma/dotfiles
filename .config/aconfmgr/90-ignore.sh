IgnorePath '/lost+found'

IgnorePath "*.cache"
IgnorePath "*.lock"
IgnorePath "*.bak"

# Includes generated kernels, random seeds, credentials, and keys.
IgnorePath '/boot'
IgnorePath '/boot/*'

IgnorePath "/opt/*"
IgnorePath '/var/*'

IgnorePath '/usr/lib*/*'
IgnorePath '/usr/share/fonts/*'
IgnorePath '/usr/share/icons/*'
IgnorePath '/usr/share/glib-2.0/*'
IgnorePath '/usr/share/info/*'
IgnorePath '/usr/share/mime/*'
IgnorePath '/usr/local/bin/*'
IgnorePath '/usr/local/share/*'
IgnorePath '/usr/local/lib/**'
IgnorePath '/usr/local/man/**'

# pacman
IgnorePath '/etc/pacman.d/gnupg/**'
IgnorePath '/etc/pacman.d/mirrorlist'

IgnorePath '/etc/.updated'
IgnorePath '/etc/machine-id'
IgnorePath '/etc/os-release'
IgnorePath '/etc/mkinitcpio.d/*'
IgnorePath '/etc/kernel/*'

# Generated caches and indexes
IgnorePath '/etc/ca-certificates/**'
IgnorePath '/etc/fonts/**'
IgnorePath '/etc/ssl/**'

# Accounts, secrets, and machine-local state
IgnorePath '/etc/*-'
IgnorePath '/etc/fstab'
IgnorePath '/etc/hostname'
IgnorePath '/etc/passwd'
IgnorePath '/etc/group'
IgnorePath '/etc/shadow'
IgnorePath '/etc/gshadow'
IgnorePath '/etc/subuid'
IgnorePath '/etc/subgid'
IgnorePath '/etc/NetworkManager/system-connections/**'
IgnorePath '/etc/resolv.conf'
IgnorePath '/etc/shells'

# Known package/runtime artifacts which are not useful configuration
IgnorePath '/etc/audisp'
IgnorePath '/etc/audit'

IgnorePath '/etc/sudoers.d/00_hat0uma'
