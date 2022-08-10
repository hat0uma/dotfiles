# https://github.com/mikemaccana/powershell-profile
# use emacs keybind
Set-PSReadLineOption -BellStyle None -EditMode Emacs
# change tab completion style
Set-PSReadlineKeyHandler -Chord Tab -Function Complete

# encoding
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

$MaximumHistoryCount = 10000;

# aliases and functions
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name editor -Value nvim
Remove-Alias -Force -Name sp

if ( Test-Path env:NVIM )
{
    . _nvim_hooks.ps1
}

function edit($file)
{ 
    editor $file
}

function open($file)
{ 
    invoke-item $file
}

function settings
{
    start-process ms-setttings:
}

function pkill($name)
{
    get-process $name -ErrorAction SilentlyContinue | stop-process
}

function pgrep($name)
{
    get-process $name
}

function touch($file)
{
    if ( Test-Path $file )
    {
        Set-FileTime $file
    } else
    {
        New-Item $file -type file
    }
}

function ln($target, $link)
{
    New-Item -ItemType SymbolicLink -Path $link -Value $target
}

function df
{
    get-volume
}

function grep($regex, $dir)
{
    if ( $dir )
    {
        get-childitem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function cut()
{
    foreach ($part in $input)
    {
        $line = $part.ToString();
        $MaxLength = [System.Math]::Min(200, $line.Length)
        $line.subString(0, $MaxLength)
    }
}

function find-file($name)
{
    get-childitem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
        write-output($PSItem.FullName)
    }
}

set-alias find find-file
set-alias find-name find-file
