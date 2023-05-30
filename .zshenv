export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export MANPAGER=${MANPAGER:="nvim +Man!"}
export EDITOR=${EDITOR:="nvim"}
export BROWSER=/usr/bin/google-chrome-stable

# --- xdg ---#
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

export PATH="$HOME/.local/bin:$HOME/.deno/bin:$HOME/.cargo/bin:$PATH:$HOME/go/bin"
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

if infocmp wezterm >/dev/null 2>&1; then
    export TERM=wezterm
fi
