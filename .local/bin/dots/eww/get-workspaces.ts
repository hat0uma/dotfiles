#!/usr/bin/env -S deno run -A --unstable

import { lookupIcon } from "/lib/iconfont.ts";
import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import type { Workspace } from "/lib/hyprctl.ts";

// fetch workspaces from hyprland
// Ideally, we should use `openwindow`, `closewindow`, and other events to update windows.
// However, fetching clients is easier compared to handling these events.
async function getWorkspaces(): Promise<(Workspace & { icon: string })[]> {
  const clients = await hyprctl.fetchClients();
  const workspaces = await hyprctl.fetchWorkspaces();
  return workspaces
    .sort((a, b) => a.id - b.id)
    .map((w) => {
      const lastwindow = clients.find((c) => c.address === w.lastwindow);
      return { ...w, icon: lastwindow ? lookupIcon(lastwindow.class) : "" };
    });
}

// initial value
console.log(JSON.stringify(await getWorkspaces()));

// on changed
await listenHyprlandSocketEvent(async (_) => {
  console.log(JSON.stringify(await getWorkspaces()));
});
