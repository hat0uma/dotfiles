#!/usr/bin/env -S deno run -A --unstable

import { lookupIcon } from "/lib/iconfont.ts";
import { listenHyprlandSocketEvent } from "/lib/event.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import type { Workspace } from "/lib/hyprctl.ts";

// fetch workspaces from hyprland
// Ideally, we should use `openwindow`, `closewindow`, and other events to update windows.
// However, fetching clients is easier compared to handling these events.
async function getWorkspaces(): Promise<(Workspace & { icons: string })[]> {
  const clients = await hyprctl.fetchClients();
  const workspaces = await hyprctl.fetchWorkspaces();

  return workspaces
    .sort((a, b) => a.id - b.id)
    .map((w) => {
      const windows = clients.filter((c) => c.workspace.id === w.id);
      const icons = windows.map((c) => lookupIcon(c.class)).filter((i) => i !== "");
      return { ...w, icons: [...new Set(icons)].join("  ") };
    });
}

// initial value
console.log(JSON.stringify(await getWorkspaces()));

// on changed
await listenHyprlandSocketEvent(async (_) => {
  console.log(JSON.stringify(await getWorkspaces()));
});
