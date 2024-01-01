import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

export type Workspace = {
  id: number;
  name: string;
  monitor: string;
  windows: number;
  hasfullscreen: boolean;
  lastwindow: string;
  lastwindowtitle: string;
};
export type Workspaces = Workspace[];

export type WorkspaceName = {
  id: number;
  name: string;
};

export type Monitor = {
  id: number;
  name: string;
  description: string;
  make: string;
  model: string;
  serial: string;
  width: number;
  height: number;
  refreshRate: number;
  x: number;
  y: number;
  activeWorkspace: WorkspaceName;
  specialWorkspace: WorkspaceName;
  reserved: number[];
  scale: number;
  transform: number;
  focused: boolean;
  dpmsStatus: boolean;
  vrr: boolean;
};

export type Monitors = Monitor[];

export type Window = {
  address: string;
  mapped: boolean;
  hidden: boolean;
  at: [number, number];
  size: [number, number];
  workspace: WorkspaceName;
  floating: boolean;
  monitor: number;
  class: string;
  title: string;
  initialClass: string;
  initialTitle: string;
  pid: number;
  xwayland: boolean;
  pinned: boolean;
  fullscreen: boolean;
  fullscreenMode: number;
  fakeFullscreen: boolean;
  grouped: string[];
  swallowing: string;
};

export type Client = {
  address: string;
  mapped: boolean;
  hidden: boolean;
  at: [number, number];
  size: [number, number];
  workspace: { id: number; name: string };
  floating: boolean;
  monitor: number;
  class: string;
  title: string;
  initialClass: string;
  initialTitle: string;
  pid: number;
  xwayland: boolean;
  pinned: boolean;
  fullscreen: boolean;
  fullscreenMode: number;
  fakeFullscreen: boolean;
  grouped: string[];
  swallowing: string;
  focusHistoryID: number;
};

type Clients = Client[];

export async function fetchMonitors() {
  return await $`hyprctl monitors -j`.json<Monitors>();
}

export async function fetchWorkspaces() {
  return await $`hyprctl workspaces -j`.json<Workspaces>();
}

export async function fetchActiveWindow() {
  return await $`hyprctl activewindow -j`.json<Window>();
}

export async function fetchClients() {
  return await $`hyprctl clients -j`.json<Clients>();
}
