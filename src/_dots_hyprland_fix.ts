#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { HyprlandEvent, HyprlandEventListener, listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";

function opWindowFixer(): HyprlandEventListener {
  let timer = -1;
  return async (ev: HyprlandEvent) => {
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
  };
}

async function isolateSpecial(className: string): Promise<HyprlandEventListener> {
  async function getActiveWindow() {
    const monitors = await hyprctl.fetchMonitors();
    const focusedmon = monitors.find((mon) => mon.focused);
    if (focusedmon) {
      return focusedmon.activeWorkspace.name;
    }
    return null;
  }

  let specialWorkspace = "";
  let activeWorkspace = await getActiveWindow();
  return async (ev: HyprlandEvent) => {
    if (ev.eventType === "activespecial") {
      specialWorkspace = ev.workspaceName;
    } else if (ev.eventType === "urgent" && specialWorkspace !== "") {
      await $`hyprctl dispatch togglespecialworkspace`;
    } else if (ev.eventType === "workspace") {
      activeWorkspace = ev.workspaceName;
    } else if (
      ev.eventType === "openwindow" && ev.workspaceName === specialWorkspace &&
      ev.windowClass.toLowerCase() !== className
    ) {
      await $`hyprctl dispatch movetoworkspace ${activeWorkspace},address:0x${ev.windowAddress}`;
    }
  };
}

$.setPrintCommand(true);
const listeners: HyprlandEventListener[] = [
  opWindowFixer(),
  await isolateSpecial("webcord"),
];

await listenHyprlandSocketEvent(async (ev) => {
  for (const listener of listeners) {
    await listener(ev);
  }
});
