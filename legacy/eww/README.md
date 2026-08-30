# Legacy eww configuration

This directory contains the eww configuration and its dedicated Deno helpers
from before the desktop shell was migrated to Astal/AGS.

It is kept as a reference snapshot only. It is not linked into `~/.config`, its
helper scripts are no longer installed into `~/.local/bin`, and its runtime
dependencies are intentionally not part of the active package lists.

The archived helpers still refer to the shared `src/lib/event.ts` and
`src/lib/hyprctl.ts` modules in their original source tree.
