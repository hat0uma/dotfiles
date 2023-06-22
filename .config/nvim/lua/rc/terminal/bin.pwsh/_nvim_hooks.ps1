# chpwd functions
$Script:OLDPWD=$PWD

function _cd_nvim_hook()
{
    Invoke-Expression "Set-Location $args"
    if( "$PWD" -ne "$Script:OLDPWD" )
    {
        nvim -u NONE -i NORC --server $env:PARENT_NVIM_ADDRESS --remote-send "<Cmd>lua require('rc.terminal.dir').notify_cwd_changed([[$PWD]])<CR>" | Out-Null
        $Script:OLDPWD=$PWD
    }
}

Remove-Item alias:cd
Set-Alias -Name cd -Value _cd_nvim_hook

