switch ($args[0])
{
    "-e"
    {
        $opener="TEdit"
        $optind=1
    }
    "-v"
    {
        $opener="TVsplit"
        $optind=1
    }
    "-s"
    {
        $opener="TSplit"
        $optind=1
    }
    default
    {
        $opener="TEdit"
        $optind=0
    }
}
# Write-Output "opener:$opener , files:$files"
$files=$args | Select-Object -Skip $optind
$stdinPiped = ( $input.Clone() ).MoveNext()
if( -not $stdinPiped )
{
    nvim --server $env:PARENT_NVIM_ADDRESS --remote-send "<Cmd>$opener $files<CR>"
} else
{
    $tmpFile=(New-TemporaryFile).FullName
    $input |Out-File -FilePath $tmpFile -Append 
    nvim --server "$env:PARENT_NVIM_ADDRESS" --remote-send "<Cmd>$opener $tmpFile | au VimLeave * call delete('$tmpFile')<CR>"
}

