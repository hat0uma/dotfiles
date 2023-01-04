#!/bin/env bash
set -e
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

# checkout
if [[ ! -d "$neovim_tmp_dir" ]]; then
    git clone https://github.com/neovim/neovim "$neovim_tmp_dir" || { echo "failed to clone."; exit 1; }
else
    git pull --all
fi
cd "$neovim_tmp_dir"
git checkout "$version"

# build & install
make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)"
sudo make install

echo "*** finish install neovim@${version} ***"
