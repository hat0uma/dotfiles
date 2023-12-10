#!/usr/bin/env -S deno run -A --unstable

import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";

const windows = new Map<string, {
  ownerWorkspace: string;
  class: string;
}>();

async function getWorkspaces() {
  const workspaces = await hyprctl.fetchWorkspaces();
  return workspaces.sort((a, b) => a.id - b.id);
}

// initial value
const workspaces = await getWorkspaces();
console.log(JSON.stringify(workspaces));

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
      window && (window.ownerWorkspace = event.workspaceName);
      break;
    }
  }
  // TODO: handle another event
  const workspaces = await getWorkspaces();
  console.log(JSON.stringify(workspaces));
});
