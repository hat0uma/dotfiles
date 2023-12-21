#!/usr/bin/env -S deno run -A --unstable

import { lookupIcon } from "/lib/iconfont.ts";
import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import type { Workspace } from "/lib/hyprctl.ts";

const windows = new Map<string, {
  ownerWorkspace: string;
  class: string;
}>();

async function getWorkspaces(): Promise<(Workspace & { icon: string })[]> {
  const workspaces = (await hyprctl.fetchWorkspaces()).sort((a, b) => a.id - b.id);
  return workspaces.map((w) => {
    const lastwindow = windows.get(w.lastwindow);
    if (lastwindow) {
      const icon = lookupIcon(lastwindow.class);
      return { ...w, icon: icon };
    } else {
      return { ...w, icon: "" };
    }
  });
}

async function initWindows() {
  const clients = await hyprctl.fetchClients();
  for (const client of clients) {
    if (client.workspace.id === -1) continue;
    if (client.workspace.name === "") continue;
    if (client.class === "") continue;
    windows.set(client.address, { ownerWorkspace: client.workspace.name, class: client.class });
  }
}

// initial value
await initWindows();
console.log(JSON.stringify(await getWorkspaces()));

// on changed
await listenHyprlandSocketEvent(async (event) => {
  switch (event.eventType) {
    case "openwindow": {
      windows.set(event.windowAddress, { ownerWorkspace: event.workspaceName, class: event.windowClass });
      break;
    }
    case "closewindow": {
      windows.delete(event.windowAddress);
      break;
    }
    case "movewindow": {
      const window = windows.get(event.windowAddress);
      if (window) window.ownerWorkspace = event.workspaceName;
      break;
    }
  }
  // TODO: handle another event
  console.log(JSON.stringify(await getWorkspaces()));
});
