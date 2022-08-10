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
Remove-Alias -Force -Name sp

if ( Test-Path env:NVIM )
{
    . _nvim_hooks.ps1
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

function ln($target, $link)
{
    New-Item -ItemType SymbolicLink -Path $link -Value $target
}

function df
{
    get-volume
}

