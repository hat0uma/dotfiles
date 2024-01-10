#!/bin/bash

# This script serves as a wrapper for executing Deno scripts and is designed to address
# the issue of resolving relative imports when the script is executed via a symbolic link. It dynamically
# resolves the absolute path of the target Deno script based on the symbolic link's target location
# and executes it. This ensures that even when the script is called through a symlink placed
# in a different directory, the relative imports in the Deno script work correctly.
# The script assumes that the Deno scripts have the same name as the symlink but with a .ts extension.
# Usage:
# 1. Place your Deno scripts (.ts files) in the same directory as this wrapper script.
# 2. Create a symbolic link to this script in a directory that's in your PATH, like ~/.local/bin.
#    The name of the symlink should match the name of the target Deno script without the .ts extension.
# 3. Now, you can execute the script from anywhere using the symlink.
#    The script automatically resolves and runs the corresponding Deno script, ensuring relative
#    imports are correctly resolved based on the actual script's location.
#
# Example:
# If you have a Deno script named hello.ts in the same directory as this wrapper,
# create a symlink named 'hello' to this script in ~/.local/bin.
# You can then execute the script anywhere by simply calling 'hello' in the terminal.
# The relative imports in the hello.ts script will be correctly resolved regardless of the symlink's location.

scriptDir="$(dirname "$(readlink -f "$0")")"
targetScript="$scriptDir/$(basename "$0").ts"
deno run -A --unstable "$targetScript" "$@"
