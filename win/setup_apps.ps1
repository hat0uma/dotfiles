Set-StrictMode -Version Latest

function skkdict
{
    mkdir -ErrorAction SilentlyContinue "$HOME/.eskk"

    $utf8=[System.Text.Encoding]::UTF8
    $eucjp=[System.Text.Encoding]::GetEncoding("EUC-JP")

    $response = (Invoke-WebRequest "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L").RawContentStream.ToArray()
    $utf8Bytes=[System.Text.Encoding]::Convert($eucjp, $utf8, $response)
    [System.IO.File]::WriteAllBytes("$HOME/.eskk/SKK-JISYO.L", $utf8Bytes)
}

$scoopApps = @(
    "deno"
    "dotnet-sdk"
    "vcredist2022"
    "gcc"
    "git"
    # "go"
    "jq"
    "make"
    "neovim-nightly"
    "nodejs"
    "pwsh"
    "python"
    "ripgrep"
    # "rust"
    "sarasa-mono-j-nerd-font"
    "sarasa-term-j-nerd-font"
    "unzip"
    "sed"
    "wezterm-nightly"
    "bottom"
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
scoop update $( $scoopApps -join " " )

skkdict

