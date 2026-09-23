#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APPLICATIONS_DIR="$SCRIPT_DIR/../applications"
DEST="$HOME/.local/share/applications"

mkdir -p "$DEST"

for file in "$APPLICATIONS_DIR"/*.desktop; do
    ln -sf "$(realpath "$file")" "$DEST/"
done
