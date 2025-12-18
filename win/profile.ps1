# keybinds
# Install-Module -name PSReadLine -AllowClobber -Force -Scope CurrentUser
Set-PSReadLineOption -BellStyle None -EditMode Emacs
Set-PSReadlineKeyHandler -Chord Tab -Function Complete

# encoding
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

# others
$MaximumHistoryCount = 10000;

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
    if ($fullPath.StartsWith($HOME))
    {
        $displayPath = $fullPath.Replace($HOME, "~")
    } else
    {
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
function prompt
{
    if (-not $Global:IsClearScreenAction)
    {
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
    if ($isSuccess)
    {
        # Write-Host "(*'▽')" -NoNewline -ForegroundColor Green
        # Write-Host "(o^~^o)" -NoNewline -ForegroundColor Green
        # Write-Host "(o・∇・o)" -NoNewline -ForegroundColor Green
        Write-Host "(o·∇·o)" -NoNewline -ForegroundColor Green
    } else
    {
        # Write-Host "(=>_<)" -NoNewline -ForegroundColor Red
        Write-Host "(*>△<)" -NoNewline -ForegroundColor Red
    }

    # prompt
    return " < "
}
# # ==============================================================================
# # PowerShell Async Git Prompt
# # ==============================================================================
#
# # Initialize global state
# $Global:AsyncPromptState = [hashtable]::Synchronized(@{
#         Path          = ""
#         GitBranch     = ""
#         IsCalculating = $false
#         Runspace      = $null
#         PowerShell    = $null
#     })
#
# # Cleanup and create timer
# if ($Global:AsyncPromptTimer)
# { 
#     $Global:AsyncPromptTimer.Stop()
#     $Global:AsyncPromptTimer.Dispose() 
# }
# $Global:AsyncPromptTimer = New-Object System.Timers.Timer
# $Global:AsyncPromptTimer.Interval = 50
# $Global:AsyncPromptTimer.AutoReset = $true
#
# # Action when timer fires
# $OnTimerElapsed = {
#     # Process only if Runspace exists and is completed
#     if ($Global:AsyncPromptState.Runspace -and $Global:AsyncPromptState.Runspace.IsCompleted)
#     {
#         $Global:AsyncPromptTimer.Stop()
#
#         try
#         {
#             # Get results (returns a collection, so get the first element)
#             $results = $Global:AsyncPromptState.PowerShell.EndInvoke($Global:AsyncPromptState.Runspace)
#             
#             if ($results -and $results.Count -gt 0)
#             {
#                 $Global:AsyncPromptState.GitBranch = $results[0]
#             } else
#             {
#                 $Global:AsyncPromptState.GitBranch = ""
#             }
#         } catch
#         {
#             # Silently clear Git info on error (Use Write-Host $_ for debugging)
#             $Global:AsyncPromptState.GitBranch = ""
#         } finally
#         {
#             # Resource cleanup
#             $Global:AsyncPromptState.PowerShell.Dispose()
#             $Global:AsyncPromptState.Runspace = $null
#             $Global:AsyncPromptState.PowerShell = $null
#             $Global:AsyncPromptState.IsCalculating = $false
#         }
#
#         # Redraw prompt
#         [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
#     }
# }
#
# Register-ObjectEvent -InputObject $Global:AsyncPromptTimer -EventName Elapsed -Action $OnTimerElapsed -SourceIdentifier "AsyncPromptTimer" | Out-Null
#
# # ==============================================================================
# # Prompt Function
# # ==============================================================================
# function prompt
# {
#     $currentPath = $PWD.ProviderPath
#     $esc = [char]27
#
#     # Color settings
#     $colorPath   = "$esc[34;1m" 
#     $colorGit    = "$esc[90m"   
#     $colorSymbol = "$esc[35m"   
#     $colorReset  = "$esc[0m"
#
#     # Start async task if path changed
#     if ($Global:AsyncPromptState.Path -ne $currentPath)
#     {
#         $Global:AsyncPromptState.Path = $currentPath
#         $Global:AsyncPromptState.GitBranch = "" # Clear display while calculating
#         
#         if (-not $Global:AsyncPromptState.IsCalculating)
#         {
#             $Global:AsyncPromptState.IsCalculating = $true
#             
#             # Create a new Runspace for each execution (Stable approach)
#             $Global:AsyncPromptState.Runspace = [runspacefactory]::CreateRunspace()
#             $Global:AsyncPromptState.Runspace.Open()
#             $Global:AsyncPromptState.PowerShell = [powershell]::Create()
#             $Global:AsyncPromptState.PowerShell.Runspace = $Global:AsyncPromptState.Runspace
#             
#             # Script block running in background
#             $Global:AsyncPromptState.PowerShell.AddScript({
#                     param($targetPath)
#                 
#                     # Error avoidance: Exit if path does not exist
#                     if (-not (Test-Path -LiteralPath $targetPath))
#                     { return "" 
#                     }
#                 
#                     # Move to path (Use LiteralPath to handle symbols like [])
#                     Set-Location -LiteralPath $targetPath
#                 
#                     # Encoding fix
#                     [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
#
#                     # Check if inside git work tree (judge by exit code)
#                     git rev-parse --is-inside-work-tree > $null 2>&1
#                     if ($LASTEXITCODE -eq 0)
#                     {
#                         # Get branch name
#                         $branch = git branch --show-current 2>$null
#                         if (-not $branch)
#                         { 
#                             $branch = (git rev-parse --short HEAD 2>$null) 
#                         }
#                     
#                         # Check dirty status
#                         $status = git status --porcelain 2>$null
#                         $symbol = if ($status)
#                         { "*" 
#                         } else
#                         { "" 
#                         }
#                     
#                         return "$branch$symbol"
#                     }
#                     return ""
#                 }).AddArgument($currentPath) | Out-Null
#
#             # Begin asynchronous execution
#             $Global:AsyncPromptState.Runspace = $Global:AsyncPromptState.PowerShell.BeginInvoke()
#             $Global:AsyncPromptTimer.Start()
#         }
#     }
#
#     # --- View Logic ---
#     $displayPath = $currentPath.Replace($HOME, "~")
#     
#     $gitPart = ""
#     if ($Global:AsyncPromptState.GitBranch)
#     {
#         $gitPart = " $colorGit" + $Global:AsyncPromptState.GitBranch
#     }
#
#     return "$colorPath$displayPath$gitPart $colorSymbol❯ $colorReset"
# }
