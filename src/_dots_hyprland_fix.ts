#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { HyprlandEvent, HyprlandEventListener, listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";

/**
 * fix 1password quick access's window position.
 */
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

const trackedWindows = new Map<string, string[]>();
function windowTracker(): HyprlandEventListener {
  return async (ev: HyprlandEvent) => {
    if (ev.eventType === "openwindow") {
      if (trackedWindows.has(ev.workspaceName)) {
        trackedWindows.get(ev.workspaceName)?.push(ev.windowAddress);
      } else {
        trackedWindows.set(ev.workspaceName, [ev.windowAddress]);
      }
    } else if (ev.eventType === "closewindow") {
      for (const [_, windows] of trackedWindows) {
        if (windows.includes(ev.windowAddress)) {
          windows.splice(windows.indexOf(ev.windowAddress), 1);
        }
      }
    } else if (ev.eventType === "movewindow") {
      for (const [_, windows] of trackedWindows) {
        if (windows.includes(ev.windowAddress)) {
          windows.splice(windows.indexOf(ev.windowAddress), 1);
        }
      }
      if (trackedWindows.has(ev.workspaceName)) {
        trackedWindows.get(ev.workspaceName)?.push(ev.windowAddress);
      } else {
        trackedWindows.set(ev.workspaceName, [ev.windowAddress]);
      }
    }
    console.log(trackedWindows);
  };
}

async function isolateSpecial(targetWorkspace: string, className: string): Promise<HyprlandEventListener> {
  async function getActiveWindow() {
    const monitors = await hyprctl.fetchMonitors();
    const focusedmon = monitors.find((mon) => mon.focused);
    if (focusedmon) {
      return focusedmon.activeWorkspace.name;
    }
    return null;
  }

  let currentSpecial = "";
  let activeWorkspace = await getActiveWindow();
  return async (ev: HyprlandEvent) => {
    if (ev.eventType === "activespecial") {
      // NOTE: workspaceName is empty when deactivating special workspace.
      currentSpecial = ev.workspaceName;
    } else if (ev.eventType === "urgent" && currentSpecial !== "") {
      await $`hyprctl dispatch togglespecialworkspace`;
    } else if (ev.eventType === "workspace") {
      activeWorkspace = ev.workspaceName;
    } else if (
      ev.eventType === "openwindow" &&
      ev.workspaceName === currentSpecial &&
      currentSpecial === targetWorkspace &&
      ev.windowClass.toLowerCase() !== className
    ) {
      await $`hyprctl dispatch movetoworkspace ${activeWorkspace},address:0x${ev.windowAddress}`;
    }
  };
}

$.setPrintCommand(true);
const listeners: HyprlandEventListener[] = [
  windowTracker(),
  opWindowFixer(),
  await isolateSpecial("special", "webcord"),
];

await listenHyprlandSocketEvent(async (ev) => {
  for (const listener of listeners) {
    await listener(ev);
  }
});
