#!/bin/bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APPLICATIONS_DIR="$SCRIPT_DIR/../applications"
DEST="$HOME/.local/share/applications"

mkdir -p "$DEST"

echo "[INFO] source: $APPLICATIONS_DIR"
echo "[INFO] dest:   $DEST"

shopt -s nullglob

for file in "$APPLICATIONS_DIR"/*.desktop; do
    name="$(basename "$file")"
    src="$(realpath "$file")"
    dst="$DEST/$name"

    if [[ -L "$dst" ]] && [[ "$(realpath "$dst")" == "$src" ]]; then
        echo "[SKIP] $name"
        continue
    fi

    if [[ -e "$dst" || -L "$dst" ]]; then
        echo "[UPDATE] $name -> $src"
    else
        echo "[CREATE] $name -> $src"
    fi

    ln -sfn "$src" "$dst"
done

echo "[DONE]"
