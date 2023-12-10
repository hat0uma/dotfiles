#!/usr/bin/env -S deno run -A --unstable

import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import * as gtk from "/lib/gtk.ts";

// initialize
gtk.initGtk();

// initial value
const window = await hyprctl.fetchActiveWindow();
console.log(window.class);

// on changed
await listenHyprlandSocketEvent(async (event) => {
  if (event.eventType === "activewindow") {
    console.log(event.windowTitle);
    // const icon = gtk.getIconPath(event.windowClass, 128, gtk.IconLookupFlags.None);
    // console.log(icon);
  }
});
