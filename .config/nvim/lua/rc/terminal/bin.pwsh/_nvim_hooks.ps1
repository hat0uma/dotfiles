# chpwd functions
function _cd_nvim_hook()
{
    Invoke-Expression "Set-Location $args"
    if( $PWD -ne $OLDPWD )
    {
        $(nvim --server $env:PARENT_NVIM_ADDRESS --remote-send "<Cmd>lcd $PWD<CR>")
        $OldPWD=$PWD
    }
}

Remove-Item alias:cd
Set-Alias -Name cd -Value _cd_nvim_hook

