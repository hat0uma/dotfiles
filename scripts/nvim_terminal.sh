#!/usr/bin/env bash
while ! NVIM_RESTART_ENABLE=1 nvim -c "lua require'rc.terminal'.show()"; do :; done
