#!/usr/bin/env bash
# Visual regression check for the AGS bar.
#
#   tests/visual/run.sh            capture current snapshots and diff them against baseline/
#   tests/visual/run.sh --update   capture and overwrite baseline/ (commit the result)
#   tests/visual/run.sh [--update] <target...>   limit to some targets
#
# Needs a running `ags run` instance of this config (Hyprland session), plus
# notify-send, gdbus and python-pillow.  See tests/visual/README.md.
set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd)
update=0
if [[ ${1:-} == --update ]]; then
  update=1
  shift
fi

current="$dir/current"
rm -rf "$current" "$dir/report"
"$dir/capture.sh" "$current" "$@"

if [[ $update -eq 1 ]]; then
  mkdir -p "$dir/baseline"
  cp "$current"/*.png "$dir/baseline/"
  echo "baseline updated: $dir/baseline"
  exit 0
fi

exec python3 "$dir/compare.py" "$dir/baseline" "$current" "$dir/report" \
  ${AGS_VISUAL_MAX_RATIO:+--max-ratio "$AGS_VISUAL_MAX_RATIO"}
