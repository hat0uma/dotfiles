#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";

let timer = -1;
await listenHyprlandSocketEvent(async (ev) => {
  if (ev.eventType === "activewindow") {
    if (timer === -1 && ev.windowClass === "1Password" && ev.windowTitle === "クイックアクセス — 1Password") {
      console.log("1password window activated");
      timer = setInterval(async () => {
        await $`hyprctl dispatch centerwindow`;
      }, 100);
    }
  } else {
    const activeWindow = await hyprctl.fetchActiveWindow();
    if (activeWindow.class !== "1Password" && timer !== -1) {
      console.log("1password window deactivated");
      clearInterval(timer);
      timer = -1;
    }
  }
});
