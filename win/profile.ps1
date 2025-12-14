# keybinds
# Install-Module -name PSReadLine -AllowClobber -Force -Scope CurrentUser
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
    # Remove-Alias -Force -Name sp
    Remove-Item -Force Alias:\sp
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

# Remove-Alias -Force -Name nv
Remove-Item -Force Alias:\nv
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

function Get-ShortenCwd()
{
    $fullPath = (Get-Location).Path
    if ($fullPath.StartsWith($HOME)) {
        $displayPath = $fullPath.Replace($HOME, "~")
    } else {
        $displayPath = $fullPath
    }
    return $displayPath
}

$Global:IsClearScreenAction = $false
Set-PSReadLineKeyHandler -Chord Ctrl+l -ScriptBlock {
    $Global:IsClearScreenAction = $true
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
    $Global:IsClearScreenAction = $false
}

$Global:LastPromptStatus = $true
function prompt {
    if (-not $Global:IsClearScreenAction) {
        $Global:LastPromptStatus = $?
    }
    $isSuccess = $Global:LastPromptStatus

    # $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    # $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    # Write-Host "┌──" -NoNewline -ForegroundColor Blue
    Write-Host "╭─" -NoNewline -ForegroundColor Blue

    # ---------------------------------
    # # (username@computername)-
    # ---------------------------------
    # Write-Host "(" -NoNewline -ForegroundColor Blue
    # Write-Host "$($env:USERNAME)@$($env:COMPUTERNAME))-" -NoNewline -ForegroundColor Yellow
    
    # ---------------------------------
    # [cwd]
    # ---------------------------------
    Write-Host "[" -NoNewline -ForegroundColor Blue
    Write-Host (Get-ShortenCwd) -NoNewline -ForegroundColor Cyan
    Write-Host "]" -NoNewline -ForegroundColor Blue

    # ---------------------------------
    # └─(^_^) < 
    # ---------------------------------
    # Write-Host "`n└─" -NoNewline -ForegroundColor Blue
    Write-Host "`n╰──" -NoNewline -ForegroundColor Blue
    if ($isSuccess) {
        # Write-Host "(*'▽')" -NoNewline -ForegroundColor Green
        # Write-Host "(o^~^o)" -NoNewline -ForegroundColor Green
        # Write-Host "(o・∇・o)" -NoNewline -ForegroundColor Green
        Write-Host "(o·∇·o)" -NoNewline -ForegroundColor Green
    } else {
        # Write-Host "(=>_<)" -NoNewline -ForegroundColor Red
        Write-Host "(*>△<)" -NoNewline -ForegroundColor Red
    }

    # prompt
    return " < "
}

# others
$MaximumHistoryCount = 10000;

