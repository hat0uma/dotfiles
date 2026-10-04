import { createState } from "ags";
import GLib from "gi://GLib";

// Wall clock used by the displayed times.  The visual regression capture
// freezes it (`ags request visual-freeze <unix-seconds>`) so clocks render
// the same in every snapshot; while frozen the bar is in "visual test" mode.
const [frozen, setFrozen] = createState<number | null>(null);

export const visualTestMode = frozen((value) => value !== null);

// Notifications posted by tests/visual/capture.sh use this app name.
export const VISUAL_TEST_APP = "visual-test";

export function freezeClock(unixSeconds: number | null) {
  setFrozen(unixSeconds);
}

export function nowDateTime() {
  const value = frozen();
  return value === null
    ? GLib.DateTime.new_now_local()
    : GLib.DateTime.new_from_unix_local(value);
}

export function nowDate() {
  const value = frozen();
  return value === null ? new Date() : new Date(value * 1000);
}
