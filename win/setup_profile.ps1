Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Resolve the absolute path to the profile inside your dotfiles
$dotfilesRoot = Resolve-Path "$PSScriptRoot\.."
$sourceProfilePath = "$dotfilesRoot\win\profile.ps1"

# The command string to inject into local profiles
# We use quotes to handle paths with spaces
$injectString = ". `"$sourceProfilePath`""

# 2. Define target profile paths for both PowerShell Core (pwsh) and Windows PowerShell
$targets = @(
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",       # PowerShell 7+ (pwsh)
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"  # Windows PowerShell 5.1
)

# -----------------------------------------------------------------------------
# Main Logic
# -----------------------------------------------------------------------------

foreach ($targetProfile in $targets)
{
    try
    {
        # Ensure the parent directory exists
        $parentDir = Split-Path -Parent $targetProfile
        if (-not (Test-Path $parentDir))
        {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Host "Created directory: $parentDir"
        }

        # Create the profile file if it does not exist
        if (-not (Test-Path $targetProfile))
        {
            New-Item -ItemType File -Path $targetProfile -Force | Out-Null
            Write-Host "Created new profile file: $targetProfile"
        }

        # Read current content to check for duplicates
        $content = Get-Content -Path $targetProfile -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content)
        { $content = "" 
        }

        # Check if the source path is already configured
        if ($content.Contains($sourceProfilePath))
        {
            Write-Host "Skip: Configuration already exists in $targetProfile" -ForegroundColor Gray
        } else
        {
            # Append the source command to the end of the file
            # Prepend a newline to ensure it doesn't merge with the last line
            $appendLine = "`r`n# Load shared profile from dotfiles`r`n$injectString"
            Add-Content -Path $targetProfile -Value $appendLine -Encoding UTF8
            Write-Host "Success: Added source command to $targetProfile" -ForegroundColor Green
        }
    } catch
    {
        Write-Error "Failed to process $targetProfile. Reason: $_"
    }
}

Write-Host "`nSetup completed successfully." -ForegroundColor Cyan
