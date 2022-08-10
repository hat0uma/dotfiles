#!/usr/bin/env zsh
_nvim_autocd(){
    nvim --server "$PARENT_NVIM_ADDRESS" --remote-send "<Cmd>lcd $PWD<CR>"
}

add-zsh-hook chpwd _nvim_autocd

