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
- exit code 1 if any target changed more than `--max-ratio` (default 0.2% of
  pixels, override with `AGS_VISUAL_MAX_RATIO=0.01`), changed size, or has no baseline

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

- freezes the displayed clock at 00:00:30 today (`ags request visual-freeze <unix>`),
- posts two fixture notifications (app name `visual-test`: a critical one and
  one with long text + markup) and closes them afterwards,
- and the notification center shows only those fixtures during the capture.

Live data that still varies between runs: Wi-Fi access points / signal
strength, Bluetooth devices, audio devices, battery, volume and brightness.
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
