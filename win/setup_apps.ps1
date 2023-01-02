Set-StrictMode -Version Latest
$scoopApps = @(
    "deno"
    # "dotnet-sdk"
    "gcc"
    "git"
    "go"
    "jq"
    "make"
    "neovim-nightly"
    "nodejs"
    "pwsh"
    "python"
    "ripgrep"
    "rust"
    "sarasa-mono-j-nerd-font"
    "sarasa-term-j-nerd-font"
    "unzip"
)
if(!(get-command scoop -errorAction SilentlyContinue ))
{
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}

scoop install git

# add buckets
scoop bucket add "main"
scoop bucket add "versions"
scoop bucket add "extras"
scoop bucket add "sarasa-nerd-fonts" "https://github.com/jonz94/scoop-sarasa-nerd-fonts"

scoop install $( $scoopApps -join " " )
