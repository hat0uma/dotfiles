#!/bin/bash
version=${1:-"master"}
neovim_tmp_dir=${2:-"/tmp/nvim"}
echo "*** start install neovim@${version} ***"

prerequisites_packages=(
    "base-devel"
    "cmake"
    "unzip"
    "ninja"
    "tree-sitter"
    "curl"
)
yay -S --noconfirm "${prerequisites_packages[@]}"

# install
git clone https://github.com/neovim/neovim -b "$version" "$neovim_tmp_dir" || :
cd "$neovim_tmp_dir" || exit
git pull origin "$version"
make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)
sudo make install -j$(nproc)

echo "*** finish install neovim@${version} ***"
