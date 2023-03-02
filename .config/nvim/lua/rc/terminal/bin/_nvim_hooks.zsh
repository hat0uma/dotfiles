#!/usr/bin/env zsh

# change terminal buffer pwd
function _nvim_autocd(){
    nvim --server "$PARENT_NVIM_ADDRESS" --remote-send "<Cmd>lua require('rc.terminal.dir').notify_cwd_changed('$PWD')<CR>"
}

add-zsh-hook chpwd _nvim_autocd

# notify long command finished
function _notify (){
    local last_command="$1"
    local last_command_status="$2"
    local time_elapsed="$3"

    local level msg
    if (( last_command_status == 0 )); then
        level="info"
        msg="$_nvim_last_command completed"
    else
        level="error"
        msg="$_nvim_last_command failed"
    fi

    nvim --server "$PARENT_NVIM_ADDRESS" --remote-send "<Cmd>lua vim.notify('$msg','$level')<CR>"
}

function _notify_before_command(){
    declare -g _nvim_last_command="$1"
    declare -g _nvim_command_starttime="$EPOCHSECONDS"
}

function _notify_after_command(){
    local command_status="$?"
    if [[ -n $_nvim_last_command && -n $_nvim_command_starttime ]]; then
        local time_elapsed=$(( EPOCHSECONDS - _nvim_command_starttime ))
        local threshold="${NVIM_NOTIFY_THRESHOLD:-2}"
        if ((  time_elapsed >= threshold  )); then
            _notify "$_nvim_last_command" "$command_status" "$time_elapsed"
        fi
    fi
    unset _nvim_last_command _nvim_command_starttime
}

add-zsh-hook preexec _notify_before_command
add-zsh-hook precmd _notify_after_command
