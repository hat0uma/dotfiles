#!/usr/bin/env bash
# Capture widget-level snapshots from the running AGS instance.
#
#   tests/visual/capture.sh <out-dir> [target...]
#
# Targets: bar status wifi bluetooth audio notifications toast (default: all).
# Snapshots are rendered by AGS itself (`ags request snapshot ...`), so they do
# not include the wallpaper or windows behind the bar.  Fixture notifications
# are posted for the notification targets and closed again afterwards.
set -euo pipefail

out=${1:?usage: capture.sh <out-dir> [target...]}
shift
targets=("$@")
[[ ${#targets[@]} -gt 0 ]] || targets=(bar status wifi bluetooth audio notifications toast)
connector=${AGS_VISUAL_CONNECTOR:-}

mkdir -p "$out"
out=$(realpath "$out")

# Freeze displayed clocks at 00:00:30 today so time labels are stable (and the
# fixture notifications, posted "later", read as "たった今").
ags request visual-freeze "$(date -d 'today 00:00:30' +%s)" >/dev/null
# The bar clock polls every second; give it a tick to pick up the frozen time.
sleep 1.1

fixture_ids=()
cleanup() {
  ags request visual-freeze off >/dev/null 2>&1 || true
  for id in "${fixture_ids[@]}"; do
    gdbus call --session --dest org.freedesktop.Notifications \
      --object-path /org/freedesktop/Notifications \
      --method org.freedesktop.Notifications.CloseNotification "$id" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT

post_fixtures() {
  [[ ${#fixture_ids[@]} -eq 0 ]] || return 0
  # Long, unbreakable text and Pango-style markup, the cases that used to overflow.
  fixture_ids+=("$(notify-send -p -a "visual-test" -u critical -t 0 \
    "Critical: バッテリー残量が少なくなっています" "残り 5% です。電源に接続してください。")")
  fixture_ids+=("$(notify-send -p -a "visual-test" -t 0 \
    "とても長い通知タイトルがここに入ります。画面からはみ出さずに折り返されることを確認するためのテキストです" \
    "本文には <b>マークアップ</b> と <a href=\"https://www.youtube.com/\">www.youtube.com</a> と長い URL https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa が含まれます")")
  sleep 0.3
}

status=0
for target in "${targets[@]}"; do
  case $target in
    notifications | toast) post_fixtures ;;
  esac
  result=$(ags request snapshot "$target" "$out/$target.png" $connector)
  echo "$target: $result"
  [[ $result == error:* ]] && status=1
done
exit $status
