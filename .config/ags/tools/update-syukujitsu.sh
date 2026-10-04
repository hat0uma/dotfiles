#!/usr/bin/env bash
# Refresh data/syukujitsu.csv from the Cabinet Office (内閣府) holiday list.
#
#   tools/update-syukujitsu.sh
#
# The source is Shift_JIS with CRLF; it is stored as UTF-8 / LF so it can be
# read directly by the bar (lib/holidays.ts) and diffed in git.  Also run by
# .github/workflows/update-syukujitsu.yml.
set -euo pipefail

url=${SYUKUJITSU_URL:-https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv}
dir=$(cd "$(dirname "$0")/.." && pwd)
out="$dir/data/syukujitsu.csv"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

curl -sSfL --retry 3 "$url" | iconv -f CP932 -t UTF-8 | tr -d '\r' > "$tmp"

# Sanity checks so a broken download never replaces the data.
header=$(head -n1 "$tmp")
[[ $header == "国民の祝日・休日月日,国民の祝日・休日名称" ]] || { echo "unexpected header: $header" >&2; exit 1; }
rows=$(grep -cE '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2},.+$' "$tmp")
(( rows > 900 )) || { echo "too few rows: $rows" >&2; exit 1; }

mkdir -p "$(dirname "$out")"
mv "$tmp" "$out"
trap - EXIT
echo "updated $out ($rows holidays, last: $(tail -n1 "$out"))"
