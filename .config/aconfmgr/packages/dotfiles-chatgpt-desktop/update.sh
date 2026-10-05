#!/usr/bin/env bash
# Bump PKGBUILD to the latest ChatGPT desktop .deb in OpenAI's apt repository.
#
#   packages/dotfiles-chatgpt-desktop/update.sh
#
# The version and sha256 are read from the repository's Packages index, so the
# (large) .deb itself is not downloaded here.  Also run by
# .github/workflows/update-chatgpt-desktop.yml.
set -euo pipefail

repo=${CHATGPT_APT_URL:-https://persistent.oaistatic.com/codex-app-prod/linux/deb}
dir=$(cd "$(dirname "$0")" && pwd)
pkgbuild="$dir/PKGBUILD"

# Highest "chatgpt" amd64 version and its sha256 ("<version> <sha256>").
latest=$(
    curl -sSfL --retry 3 "$repo/dists/stable/main/binary-amd64/Packages" |
        awk -F': ' '
            /^Package: / { pkg = $2 }
            /^Version: / { ver = $2 }
            /^SHA256: /  { sha = $2 }
            /^$/ { if (pkg == "chatgpt") print ver, sha; pkg = ver = sha = "" }
            END  { if (pkg == "chatgpt") print ver, sha }
        ' |
        sort -V -k1,1 | tail -n1
)
read -r version sha256 <<<"$latest"

# Sanity checks so a broken index never rewrites the PKGBUILD.
[[ $version =~ ^[0-9]+(\.[0-9]+)+$ ]] || { echo "unexpected version: '$version'" >&2; exit 1; }
[[ $sha256 =~ ^[0-9a-f]{64}$ ]] || { echo "unexpected sha256: '$sha256'" >&2; exit 1; }

current_ver=$(source "$pkgbuild" && echo "$pkgver")
current_sha=$(source "$pkgbuild" && echo "${sha256sums[1]}")

if [[ $version == "$current_ver" ]]; then
    echo "already up to date ($version)"
    exit 0
fi

sed -i \
    -e "s/^pkgver=.*/pkgver=$version/" \
    -e "s/^pkgrel=.*/pkgrel=1/" \
    -e "s/'$current_sha'/'$sha256'/" \
    "$pkgbuild"

grep -q "'$sha256'" "$pkgbuild" || { echo "failed to update sha256sums" >&2; exit 1; }
echo "updated $current_ver -> $version"
