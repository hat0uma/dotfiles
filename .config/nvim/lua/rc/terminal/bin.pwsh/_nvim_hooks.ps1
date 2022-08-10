# chpwd functions
$OldPromptBlock = $(Get-Command prompt).ScriptBlock
function prompt()
{
    $(nvim --server $env:PARENT_NVIM_ADDRESS --remote-send "<Cmd>lcd $PWD<CR>")
    Invoke-Expression "$OldPromptBlock"
}
