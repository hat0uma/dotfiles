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
      const icons = windows.map((c) => getWindowIcon(c)).filter((i) => i !== "");
      return { ...w, icons: [...new Set(icons)].join("  ") };
    });
}

function getWindowIcon(c: hyprctl.Client): string {
  if (c.class.startsWith("FFPWA") && c.title.startsWith("Discord")) {
    return lookupIcon("discord");
  }
  return lookupIcon(c.class);
}

// initial value
console.log(JSON.stringify(await getWorkspaces()));

// on changed
await listenHyprlandSocketEvent(async (_) => {
  console.log(JSON.stringify(await getWorkspaces()));
});
