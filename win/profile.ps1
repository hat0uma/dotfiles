# keybinds
Set-PSReadLineOption -BellStyle None -EditMode Emacs
Set-PSReadlineKeyHandler -Chord Tab -Function Complete

# encoding
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

# aliases and functions
Set-Alias -Name ll -Value Get-ChildItem

if ( Test-Path env:NVIM )
{
    Remove-Alias -Force -Name sp
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

function ln($target, $link)
{
    New-Item -ItemType SymbolicLink -Path $link -Value $target
}

Remove-Alias -Force -Name nv
function nv()
{
    $env:NVIM_RESTART_ENABLE = 1
    nvim $args
    while( $LASTEXITCODE -eq 1 )
    {
        nvim +RestoreSession
    }
    Remove-Item env:NVIM_RESTART_ENABLE
}

# others
$MaximumHistoryCount = 10000;

