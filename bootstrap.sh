#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC_DIR="${DOTFILES_DIR}/.config"
CONFIG_DEST_DIR="${HOME}/.config"
BIN_DIR="${HOME}/.local/bin"

log() {
    echo -e "\033[1;32m[+] $1\033[0m"
}

error() {
    echo -e "\033[1;31m[!] $1\033[0m"
}

# ------------------------------------------------------------------------------
# Link
# ------------------------------------------------------------------------------
setup_links() {
    log "Setting up symlinks..."
    mkdir -p "${CONFIG_DEST_DIR}"
    mkdir -p "${BIN_DIR}"

    # .config
    for dir in "${CONFIG_SRC_DIR}"/*/; do
        dirname=$(basename "${dir}")
        log "Linking ${dirname} to ${CONFIG_DEST_DIR}/"
        ln -sf "${dir}" "${CONFIG_DEST_DIR}/"
    done

    log "Linking .zshrc, .zshenv, .xprofile"
    ln -sf "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
    ln -sf "${DOTFILES_DIR}/.zshenv" "${HOME}/.zshenv"
    ln -sf "${DOTFILES_DIR}/.xprofile" "${HOME}/.xprofile"
}

# ------------------------------------------------------------------------------
# Install Packages (Arch/Yay)
# ------------------------------------------------------------------------------
install_arch() {
    log "Detected Arch Linux (yay)."
    if ! command -v yay &>/dev/null; then
        error "yay is not installed. Please install yay first."
        exit 1
    fi

    log "Installing CLI tools..."
    yay -S --noconfirm \
        expac \
        unzip \
        xsel \
        tmux \
        github-cli \
        nodejs \
        npm \
        go \
        ripgrep \
        zsh
}

# ------------------------------------------------------------------------------
# Install Packages (Debian/Apt)
# ------------------------------------------------------------------------------
install_debian() {
    log "Detected Debian/Ubuntu based system (apt)."

    log "Updating apt..."
    sudo apt update

    log "Installing dependencies..."
    sudo apt install -y \
        curl \
        unzip \
        build-essential

    log "Installing CLI tools..."
    sudo apt install -y \
        xsel \
        ripgrep \
        jq \
        tmux \
        nodejs \
        npm \
        golang \
        zsh \
        git
}

# ------------------------------------------------------------------------------
# Common Setup
# ------------------------------------------------------------------------------
setup_common() {
    log "Installing Deno..."
    if ! command -v deno &>/dev/null; then
        curl -fsSL https://deno.land/x/install/install.sh | sh
    else
        log "Deno is already installed."
    fi

    log "Installing Rust (rustup)..."
    if ! command -v rustup &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
        log "Rust is already installed."
    fi

    log "Installing WezTerm terminfo..."
    tempfile=$(mktemp)
    curl -s https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo >"$tempfile"
    tic -x "$tempfile"
    rm "$tempfile"

    log "Installing global npm packages (SDK)..."
    sudo npm install -g \
        vscode-langservers-extracted \
        typescript

    log "Installing cargo packages..."
    cargo install --locked tree-sitter-cli
}

# ------------------------------------------------------------------------------
# Neovim Setup
# ------------------------------------------------------------------------------
setup_neovim() {
    log "Installing Neovim..."
    "${DOTFILES_DIR}/scripts/install_neovim.sh"

    log "Setting up Neovim plugins and parsers..."

    log "Syncing Lazy.nvim..."
    nvim --headless "+Lazy! sync" +qa

    log "Installing Treesitter parsers..."
    nvim --headless '+TSUpdate' +qa

    log "Installing LSP servers..."
    nvim --headless '+lua require("plugins.lsp.server").install()' +qa
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# 1. Link Configs
setup_links

# 2. Detect OS and Install Packages
if command -v yay &>/dev/null; then
    install_arch
elif command -v apt-get &>/dev/null; then
    install_debian
else
    error "Unsupported package manager. Only yay (Arch) and apt (Debian/Ubuntu) are supported."
    exit 1
fi

# 3. Common Setup (Deno, Rust, etc.)
setup_common

# 4. Neovim Setup
setup_neovim

log "Bootstrap completed successfully!"
