#!/usr/bin/env bash
set -euo pipefail

vault="Personal"
item="desktop-wallpaper"

wallpaper_dir="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
mkdir -p "$wallpaper_dir"

op item get "${item}" --vault "${vault}" --format json |
    jq -r '.files[].name' |
    while IFS= read -r name; do
        op read "op://$vault/$item/$name" --out-file "$wallpaper_dir/$name"
    done
