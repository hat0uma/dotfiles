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

# if ( Test-Path env:NVIM )
# {
#     $nvim_cmd=(gcm nvim).Definition
#     function nvim(){ $nvim_cmd }
# }

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

# https://gist.github.com/aroben/5542538
function pstree
{
    $ProcessesById = @{}
    foreach ($Process in (Get-WMIObject -Class Win32_Process))
    {
        $ProcessesById[$Process.ProcessId] = $Process
    }

    $ProcessesWithoutParents = @()
    $ProcessesByParent = @{}
    foreach ($Pair in $ProcessesById.GetEnumerator())
    {
        $Process = $Pair.Value

        if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId))
        {
            $ProcessesWithoutParents += $Process
            continue
        }

        if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId))
        {
            $ProcessesByParent[$Process.ParentProcessId] = @()
        }
        $Siblings = $ProcessesByParent[$Process.ParentProcessId]
        $Siblings += $Process
        $ProcessesByParent[$Process.ParentProcessId] = $Siblings
    }

    function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel)
    {
        $Process = $ProcessesById[$ProcessId]
        $Indent = " " * $IndentLevel
        if ($Process.CommandLine)
        {
            $Description = $Process.CommandLine
        } else
        {
            $Description = $Process.Caption
        }

        Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
        foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate))
        {
            Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
        }
    }

    Write-Output ("{0,6} {1}" -f "PID", "Command Line")
    Write-Output ("{0,6} {1}" -f "---", "------------")

    foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate))
    {
        Show-ProcessTree $Process.ProcessId 0
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
