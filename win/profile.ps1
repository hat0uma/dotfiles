$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Keybinds
# Install-Module -name PSReadLine -AllowClobber -Force -Scope CurrentUser
Set-PSReadLineOption -BellStyle None -EditMode Emacs
Set-PSReadlineKeyHandler -Chord Tab -Function Complete
# Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

# Encoding
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Others
$MaximumHistoryCount = 10000;

# aliases and functions
Set-Alias -Name ll -Value Get-ChildItem
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

# ==============================================================================
# Neovim
# ==============================================================================
if ( Test-Path env:NVIM )
{
    # Remove-Alias -Force -Name sp
    Remove-Item -Force Alias:\sp -ErrorAction SilentlyContinue
    . _nvim_hooks.ps1
}

# # Git completion
# # Lazy load posh-git
# Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)
#     # Install-Module posh-git -Scope CurrentUser
#     Import-Module posh-git
#     $GitPromptSettings.EnablePromptConnection = $false
#     $realCompleter = Get-ArgumentCompleter -Native -CommandName git
#     & $realCompleter.ScriptBlock $wordToComplete $commandAst $cursorPosition
# }

# ==============================================================================
# Prompt Function
# ==============================================================================
# Prompt Lines
Set-PSReadLineOption -ExtraPromptLineCount 1

$Global:StatusUpdateAllowed = $true
Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    $Global:StatusUpdateAllowed = $true
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

$Global:LastPromptStatus = $true
function prompt
{
    # Error status
    if ($Global:StatusUpdateAllowed)
    {
        # Save Exit status
        $Global:LastPromptStatus = $?

        # Start update git status
        Start-UpdateGitPrompt $PWD.ProviderPath

        $Global:StatusUpdateAllowed = $false
    }

    # Path
    $currentPath = $PWD.ProviderPath
    $displayPath = $currentPath.Replace($HOME, "~")

    # Color settings
    $esc = [char]27
    $colorPath      = "$esc[36m" # cyan
    $colorGit       = "$esc[90m" # black(bright)
    $colorBorder    = "$esc[34m" # blue
    $colorSuccess   = "$esc[32m" # green
    $colorError     = "$esc[31m" # red
    $colorReset     = "$esc[0m"

    # Git
    $gitBranch = Get-GitPrompt $currentPath
    $gitPart = ""
    if ($gitBranch)
    {
        $gitPart = " $colorGit" + $gitBranch
    }

    # Face
    $isSuccess = $Global:LastPromptStatus
    if($isSuccess)
    {
        #$face="(*'▽')"
        #$face="(o^~^o)"
        #$face="(o・∇・o)"
        $face="(o·∇·o)"
        $faceColor=$colorSuccess
    } else
    {
        $face=# "(=>_<)"
        $face="(*>△<)"
        $faceColor=$colorError
    }

    # User & Computer
    # Write-Host "(" -NoNewline -ForegroundColor Blue
    # Write-Host "$($env:USERNAME)@$($env:COMPUTERNAME))-" -NoNewline -ForegroundColor Yellow

    return (
        "$colorBorder╭─[$colorPath$displayPath$colorBorder]$gitPart$colorReset`n"+
        "$colorBorder╰──$faceColor$face$colorReset < "
    )
}


###############################################
# Git
###############################################

$Global:GitPromptInitialized = $false
$Global:GitPromptTimer = $null
$Global:GitPromptRunspace = $null

# Initialize global state
$Global:GitPromptState = [hashtable]::Synchronized(@{
        Path          = ""
        Prompt        = ""
        PowerShell    = $null
        AsyncResult   = $null # IAsyncResult from BeginInvoke()
    })

function Initialize-GitBackend
{
    # Create Runspace
    $Global:GitPromptRunspace = [runspacefactory]::createRunspace()
    $Global:GitPromptRunspace.Open()

    # create timer
    $Global:GitPromptTimer = New-Object System.Timers.Timer
    $Global:GitPromptTimer.Interval = 50
    $Global:GitPromptTimer.AutoReset = $true

    # Action when timer fires
    $OnTimerElapsed = {
        # Wait Event Completion
        if (-not $Global:GitPromptState.AsyncResult -or -not( $Global:GitPromptState.AsyncResult.IsCompleted ))
        {
            return
        }

        $Global:GitPromptTimer.Stop()
        try
        {
            # Get results (returns a collection, so get the first element)
            $results = $Global:GitPromptState.PowerShell.EndInvoke($Global:GitPromptState.AsyncResult)
            if ($results -and $results.Count -gt 0)
            {
                $Global:GitPromptState.Prompt = $results[0]
            } else
            {
                $Global:GitPromptState.Prompt = ""
            }
        } catch
        {
            # Write-Host "$_"
            $Global:GitPromptState.Prompt = ""
        } finally
        {
            # Resource cleanup
            $Global:GitPromptState.PowerShell.Dispose()
            $Global:GitPromptState.PowerShell = $null
            $Global:GitPromptState.AsyncResult = $null
        }

        # Redraw prompt
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }


    # Register timer callback
    Register-ObjectEvent `
        -InputObject $Global:GitPromptTimer `
        -EventName Elapsed `
        -Action $OnTimerElapsed `
        -SourceIdentifier "GitPromptTimer" | Out-Null
}

function Start-UpdateGitPrompt
{
    param([Parameter(Mandatory)][string]$CurrentPath)

    # Initialize
    if (-not $Global:GitPromptInitialized)
    {
        Initialize-GitBackend
        $Global:GitPromptInitialized = $true
    }

    # Path chnaged
    $Global:GitPromptState.Path = $CurrentPath
    $Global:GitPromptState.Prompt = "" # Clear display while calculating

    # Dispose old instances
    if ($Global:GitPromptState.PowerShell)
    { 
        $Global:GitPromptState.PowerShell.Dispose() 
    }

    # Create a new instance
    $Global:GitPromptState.PowerShell = [powershell]::Create()
    $Global:GitPromptState.PowerShell.Runspace = $Global:GitPromptRunspace

    # Register Background Job
    $Global:GitPromptState.PowerShell.AddScript({
            param($targetPath)

            # Exit if git missing
            if (-not (Get-Command git -ErrorAction SilentlyContinue))
            { 
                return ""
            }

            # Exit if path does not exist
            if (-not (Test-Path -LiteralPath $targetPath))
            { 
                return ""
            }
    
            # Check if inside git work tree
            git -C "$targetPath" rev-parse --is-inside-work-tree > $null 2>&1
            if ($LASTEXITCODE -ne 0)
            { 
                return ""
            }

            # Get branch name
            $branch = git -C "$targetPath" branch --show-current 2>$null
            if (-not $branch)
            { 
                $branch = (git -C "$targetPath" rev-parse --short HEAD 2>$null) 
            }
        
            # Check dirty status
            $status = git -C "$targetPath" status --porcelain 2>$null
            $dirty = if ($status)
            { "*" 
            } else
            { "" 
            }

            $counts = git -C "$targetPath" rev-list --left-right --count HEAD...@`{u`} 2>$null
            $aheadBehind = ""
            if ($counts)
            {
                # split ahead/behind
                $parts = $counts -split '\s+'
                $aheadCount = [int]$parts[0]
                $behindCount = [int]$parts[1]

                # Ahead(push waiting)
                if ($aheadCount -gt 0)
                {
                    $aheadBehind += " ↑$aheadCount"
                }

                # Behind(pull waiting)
                if ($behindCount -gt 0)
                {
                    $aheadBehind += " ↓$behindCount"
                }
            }

            return "$branch$dirty$aheadBehind"
        }).AddArgument($CurrentPath) | Out-Null

    # Begin asynchronous execution
    $Global:GitPromptState.AsyncResult = $Global:GitPromptState.PowerShell.BeginInvoke()
    $Global:GitPromptTimer.Start()
}

function Get-GitPrompt
{
    return $Global:GitPromptState.Prompt
}

$sw.Stop()
# Write-Host "Profile Load Time: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Green
