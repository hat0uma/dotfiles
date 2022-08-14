@echo off

SETLOCAL
SET NVIM_RESTART_ENABLE=1
:Do
    nvim -c "lua require'rc.terminal'.show {start_in_insert = false} "
    if errorLevel 1 ( goto Do )

ENDLOCAL

