$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Keybinds
# Install-Module -name PSReadLine -AllowClobber -Force -Scope CurrentUser
Set-PSReadLineOption -BellStyle None -EditMode Emacs
Set-PSReadlineKeyHandler -Chord Tab -Function Complete
# Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
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
    start-process ms-settings:
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
$esc = [char]0x1b
$bel = [char]0x07

# Prompt Lines
Set-PSReadLineOption -ExtraPromptLineCount 1
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1

function Format-WeztermUserVar ($key, $val)
{
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($val)
    $b64 = [System.Convert]::ToBase64String($bytes)
    return "$esc]1337;SetUserVar=$key=$b64$bel" # OSC 1337
}

function Get-DetailedExitCode
{
    if ($? -eq $true)
    {
        return 0
    }

    $LastHistoryEntry = $(Get-History -Count 1)
    if (-not $LastHistoryEntry)
    { 
        return 1 
    }
    
    # powershell error
    $IsPowerShellError = $Error.Count -gt 0 -and $Error[0].InvocationInfo.HistoryId -eq $LastHistoryEntry.Id
    if ($IsPowerShellError)
    {
        return -1
    }
    # exit code of external command
    return $LastExitCode
}

function Get-CommandNameFromLine($line)
{
    # remove whitespaces
    $line = $line.Trim()
    
    # Get command
    if ([string]::IsNullOrEmpty($line))
    {
        $cmdName = ""
    } else
    {
        # Get first element splitted by whitespace ("git commit" -> "git")
        $cmdName = $line -split '\s+', 2 | Select-Object -First 1
    }
    return $cmdName
}

$Global:StatusUpdateAllowed = $true
$Global:LastPromptExitCode = 0
$Global:IsClearScreenRunning = $false

Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # OSC Sequences
    $cmdName = Get-CommandNameFromLine $line
    $WEZTERM_PROG = Format-WeztermUserVar "WEZTERM_PROG" "${cmdName}"
    $OSC133C = "$esc]133;C$bel" # FTCS_COMMAND_EXECUTED

    Write-Host -NoNewline "${WEZTERM_PROG}${OSC133C}"
    $Global:StatusUpdateAllowed = $true
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key Ctrl+l -ScriptBlock {
    $Global:IsClearScreenRunning = $true
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
    $Global:IsClearScreenRunning = $false
}

function prompt
{
    $__savedLastPromptExitCode = Get-DetailedExitCode

    # Path
    $currentPath = $PWD.ProviderPath
    $displayPath = $currentPath.Replace($HOME, "~")

    # Error status
    if ($Global:StatusUpdateAllowed)
    {
        # Save Exit status
        $Global:LastPromptExitCode = $__savedLastPromptExitCode

        # Start update git status
        Start-UpdateGitPrompt $PWD.ProviderPath

        $Global:StatusUpdateAllowed = $false
    }

    # OSC Sequences
    $shellName = (Get-Process -Id $PID).ProcessName
    $WEZTERM_PROG = Format-WeztermUserVar "WEZTERM_PROG" "${shellName}"
    $OSC133A = "$esc]133;A$bel" # FTCS_PROMPT
    $OSC133B = "$esc]133;B$bel" # FTCS_COMMAND_START
    $OSC133D = "$esc]133;D;$Global:LastPromptExitCode$bel" # FTCS_COMMAND_FINISHED
    $OSC7 = "" # change working directory
    if ($PWD.Provider.Name -eq "FileSystem") # ignore HKLM:\, Env:\, Cert:\ and others.
    {
        $esc = [char]27
        $uri = ([System.Uri]$PWD.ProviderPath).AbsoluteUri
        $OSC7 = "${esc}]7;${uri}${esc}\"
    }

    # Color settings
    $esc = [char]27
    $colorPath      = "$esc[36m" # cyan
    $colorGit       = "$esc[90m" # black(bright)
    $colorBorder    = "$esc[34m" # blue
    $colorSuccess   = "$esc[32m" # green
    $colorError     = "$esc[31m" # red
    $colorReset     = "$esc[0m"
    $colorVenv      = "$esc[33m" # yellow

    # venv
    $venv = ""
    if ($env:VIRTUAL_ENV)
    {
        $venvName = Split-Path $env:VIRTUAL_ENV -Leaf
        $venv = " $colorVenv ($venvName)$colorReset"
    }

    # Git
    $gitBranch = Get-GitPrompt $currentPath
    $gitPart = ""
    if ($gitBranch)
    {
        $gitPart = " $colorGit" + $gitBranch
    }

    # Face
    $isSuccess = $Global:LastPromptExitCode -eq 0
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
        $face=" (*>△<)"
        # $face=" (*>∆<)"
        $faceColor=$colorError
    }

    # User & Computer
    # Write-Host "(" -NoNewline -ForegroundColor Blue
    # Write-Host "$($env:USERNAME)@$($env:COMPUTERNAME))-" -NoNewline -ForegroundColor Yellow

    return (
        "${OSC133D}${WEZTERM_PROG}${OSC7}${OSC133A}"+
        "${colorBorder}╭─[${colorPath}${displayPath}${colorBorder}]${venv}${gitPart}`n"+
        "${colorBorder}╰──${faceColor}${face}${colorReset} < "+
        "${OSC133B}"
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
    if ($Global:GitPromptRunspace)
    {
        $Global:GitPromptRunspace.Dispose()
    }
    $Global:GitPromptRunspace = [runspacefactory]::createRunspace()
    $Global:GitPromptRunspace.Open()

    # create timer
    if ($Global:GitPromptTimer)
    {
        $Global:GitPromptTimer.Stop()
        $Global:GitPromptTimer.Dispose()
    }
    $Global:GitPromptTimer = New-Object System.Timers.Timer
    $Global:GitPromptTimer.Interval = 50
    $Global:GitPromptTimer.AutoReset = $true

    # Action when timer fires
    $OnTimerElapsed = {
        # Wait ClearScreen ends
        if ($Global:IsClearScreenRunning)
        {
            return
        }

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

    # Unregister previous timer callback for safely
    Unregister-Event -SourceIdentifier "GitPromptTimer" -ErrorAction SilentlyContinue

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

    $Global:GitPromptTimer.Stop()

    # Refresh state
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
