#!/bin/bash
version=$1
neovim_tmp_dir=${2:-"/tmp/nvim"}

prerequisites_packages=(
    "cmake"
    "pkg-config"
    "libtool-bin"
    "m4"
    "automake"
    "gettext"
    "build-essential"
    "unzip"
)
sudo apt-get update
sudo apt-get install -y "${prerequisites_packages[@]}"

# install
git clone https://github.com/neovim/neovim -b "$version" "$neovim_tmp_dir" || :
cd "$neovim_tmp_dir" || exit
git pull origin "$version"
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

