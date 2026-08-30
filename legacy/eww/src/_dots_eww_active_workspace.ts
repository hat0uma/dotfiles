#!/usr/bin/env -S deno run -A --unstable

import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";

// initial value
const monitors = await hyprctl.fetchMonitors();
const focusedmon = monitors.find((mon) => mon.focused);
if (focusedmon) {
  console.log(focusedmon.activeWorkspace.name);
}

// on event
await listenHyprlandSocketEvent(async function (event) {
  if (event.eventType === "workspace" || event.eventType === "focusedmon") {
    console.log(event.workspaceName);
  }
});
