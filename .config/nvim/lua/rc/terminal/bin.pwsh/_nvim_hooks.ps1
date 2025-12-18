# chpwd functions
$Script:OLDPWD=$PWD

function _cd_nvim_hook
{
    # cd
    Set-Location @args

    # check pwd changed
    if ($PWD.ProviderPath -ne $Script:OLDPWD)
    {
        $Script:OLDPWD = $PWD.ProviderPath

        # 3. notify
        # nvim -u NONE -i NORC --server $env:PARENT_NVIM_ADDRESS --remote-send "<Cmd>lua require('rc.terminal.dir').notify_cwd_changed([[$PWD]])<CR>" | Out-Null
        $luaCmd = "<Cmd>lua require('rc.terminal.dir').notify_cwd_changed([[$($PWD.ProviderPath)]])<CR>"
        Start-Process -FilePath "nvim" -ArgumentList "-u", "NONE", "-i", "NORC", "--server", $env:PARENT_NVIM_ADDRESS, "--remote-send", $luaCmd -WindowStyle Hidden
    }
}

if (Test-Path alias:cd)
{ Remove-Item alias:cd 
}
Set-Alias -Name cd -Value _cd_nvim_hook
