# Visual regression tests

Widget-level screenshots of the bar and its popovers, diffed against committed
baselines. The PNGs are rendered by the running AGS instance itself
(`Gtk.WidgetPaintable` → `GskRenderer.render_texture`), so they do not contain
the wallpaper or windows behind the bar.

## Requirements

- the bar running from this config (`ags run`) in a Hyprland session
- `notify-send`, `gdbus`, `python-pillow`

## Usage

```sh
cd ~/.config/ags
tests/visual/run.sh                  # capture + diff against baseline/
tests/visual/run.sh wifi audio       # only some targets
tests/visual/run.sh --update         # accept the current look as the new baseline
```

`ags run` must be restarted after editing the config, before capturing
(`ags quit; ags run`).

Results:

- `current/<target>.png` – fresh snapshots
- `report/<target>.side.png` – baseline | current | diff (changed pixels in pink)
- exit code 1 if any target changed more than its threshold (0.2% of pixels;
  bar 2%, wifi/bluetooth 1% because of live data; override all with
  `AGS_VISUAL_MAX_RATIO=0.01`), changed size, or has no baseline

`current/`, `report/` and `baseline/` are git-ignored: the snapshots contain
real SSIDs, Bluetooth/audio device names and battery state, and this repo is
public. Create the baseline locally with `--update` before starting a change,
then run without it after the change.

## Targets

| target          | what                                                  |
| --------------- | ----------------------------------------------------- |
| `bar`           | bar window (capsule incl. shadow)                     |
| `status`        | quick settings popover, main page                     |
| `wifi`          | quick settings → Wi-Fi page                           |
| `bluetooth`     | quick settings → Bluetooth page                       |
| `audio`         | quick settings → sound (output/input device) page     |
| `notifications` | calendar + notification center popover                |
| `toast`         | notification popup                                    |

Use `AGS_VISUAL_CONNECTOR=HDMI-A-1` to capture the bar of a specific monitor.

## Determinism

While capturing, `capture.sh`

- freezes the displayed clock at 2026-09-15 00:00:30 (`ags request visual-freeze <unix>`),
  so the calendar always shows September 2026 (敬老の日 / 国民の休日 / 秋分の日),
- posts two fixture notifications (app name `visual-test`: a critical one and
  one with long text + markup) and closes them afterwards,
- shows only those fixtures in the notification center and a fixed
  "Visual test" title in the bar's active-window slot.

Live data that still varies between runs: workspace minimaps, Wi-Fi access
points / signal strength, Bluetooth devices, audio devices, battery, volume and brightness.
Small Wi-Fi icon changes stay under the default threshold; when your
environment changes (new AP list, different devices), check
`report/*.side.png` and re-run with `--update`.

## Low-level requests

```sh
ags request snapshot <target> <out.png> [connector]   # render one target
ags request snapshot-tree <target> - [connector]      # widget tree with allocations
ags request visual-freeze <unix-seconds>|off
```

`snapshot-tree` is useful to see why a widget got an unexpected size (for
example a CSS `min-width` that never applied).

## Unit tests

```sh
cd ~/.config/ags
node --test lib/*.test.mjs workspaces/*.test.mjs
```

`lib/holidays.test.mjs` checks the Japanese holiday calculation
(`lib/holidays.ts`) against published lists, including 振替休日, 国民の休日 and
the 2019-2021 special cases.
