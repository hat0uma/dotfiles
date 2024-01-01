// https://wiki.hyprland.org/IPC/

interface WorkspaceEvent {
  eventType: "workspace";
  workspaceName: string;
}

interface FocusedMonEvent {
  eventType: "focusedmon";
  monName: string;
  workspaceName: string;
}

interface ActiveWindowEvent {
  eventType: "activewindow";
  windowClass: string;
  windowTitle: string;
}

interface ActiveWindowV2Event {
  eventType: "activewindowv2";
  windowAddress: string;
}

interface FullscreenEvent {
  eventType: "fullscreen";
  state: "0" | "1";
}

interface MonitorEvent {
  eventType: "monitorremoved" | "monitoradded";
  monitorName: string;
}

interface CreateDestroyWorkspaceEvent {
  eventType: "createworkspace" | "destroyworkspace";
  workspaceName: string;
}

interface MoveRenameWorkspaceEvent {
  eventType: "moveworkspace" | "renameworkspace";
  workspaceName: string;
  additionalData: string;
}

interface ActiveSpecialEvent {
  eventType: "activespecial";
  workspaceName: string;
  monName: string;
}

interface ActiveLayoutEvent {
  eventType: "activelayout";
  keyboardName: string;
  layoutName: string;
}

interface OpenWindowEvent {
  eventType: "openwindow";
  windowAddress: string;
  workspaceName: string;
  windowClass: string;
  windowTitle: string;
}
interface CloseWindowEvent {
  eventType: "closewindow";
  windowAddress: string;
}

interface MoveWindowEvent {
  eventType: "movewindow";
  windowAddress: string;
  workspaceName: string;
}

interface OpenCloseLayerEvent {
  eventType: "openlayer" | "closelayer";
  namespace: string;
}

interface SubmapEvent {
  eventType: "submap";
  submapName: string;
}

interface ChangeFloatingModeEvent {
  eventType: "changefloatingmode";
  windowAddress: string;
  floating: "0" | "1";
}

interface UrgentEvent {
  eventType: "urgent";
  windowAddress: string;
}

interface MinimizeEvent {
  eventType: "minimize";
  windowAddress: string;
  minimized: "0" | "1";
}

interface ScreencastEvent {
  eventType: "screencast";
  state: "0" | "1";
  owner: "0" | "1";
}

interface WindowTitleEvent {
  eventType: "windowtitle";
  windowAddress: string;
}

interface IgnoreGroupLockEvent {
  eventType: "ignoregrouplock";
  state: "0" | "1";
}

interface LockGroupsEvent {
  eventType: "lockgroups";
  state: "0" | "1";
}

interface ConfigReloadedEvent {
  eventType: "configreloaded";
}

export type HyprlandEvent =
  | WorkspaceEvent
  | FocusedMonEvent
  | ActiveWindowEvent
  | ActiveWindowV2Event
  | FullscreenEvent
  | MonitorEvent
  | CreateDestroyWorkspaceEvent
  | MoveRenameWorkspaceEvent
  | ActiveSpecialEvent
  | ActiveLayoutEvent
  | OpenWindowEvent
  | CloseWindowEvent
  | MoveWindowEvent
  | OpenCloseLayerEvent
  | SubmapEvent
  | ChangeFloatingModeEvent
  | UrgentEvent
  | MinimizeEvent
  | ScreencastEvent
  | WindowTitleEvent
  | IgnoreGroupLockEvent
  | LockGroupsEvent
  | ConfigReloadedEvent;

function parseHyprlandEvent(eventString: string): HyprlandEvent | null {
  const eventTypeMatch = eventString.match(/^(.*?)>>/);
  if (!eventTypeMatch) {
    return null;
  }
  const eventType = eventTypeMatch[1];
  const rawData = eventString.substring(eventTypeMatch[0].length);

  const [data1, ...rest] = rawData.split(",");

  switch (eventType) {
    case "workspace":
      return { eventType, workspaceName: data1 };
    case "focusedmon":
      return { eventType, monName: data1, workspaceName: rest.join("") };
    case "activewindow":
      return { eventType, windowClass: data1, windowTitle: rest.join("") };
    case "activewindowv2":
      return { eventType, windowAddress: data1 };
    case "fullscreen":
      return { eventType, state: data1 as "0" | "1" };
    case "monitorremoved":
    case "monitoradded":
      return { eventType, monitorName: data1 };
    case "createworkspace":
    case "destroyworkspace":
      return { eventType, workspaceName: data1 };
    case "moveworkspace":
    case "renameworkspace":
      return { eventType, workspaceName: data1, additionalData: rest.join("") };
    case "activespecial":
      return { eventType, workspaceName: data1, monName: rest.join("") };
    case "activelayout":
      return { eventType, keyboardName: data1, layoutName: rest.join("") };
    case "openwindow":
      return {
        eventType,
        windowAddress: data1,
        workspaceName: rest[0] || "",
        windowClass: rest[1] || "",
        windowTitle: rest.slice(2).join(""),
      };
    case "closewindow":
      return { eventType, windowAddress: data1 };
    case "movewindow":
      return { eventType, windowAddress: data1, workspaceName: rest.join("") };
    case "openlayer":
    case "closelayer":
      return { eventType, namespace: data1 };
    case "submap":
      return { eventType, submapName: data1 };
    case "changefloatingmode":
      return { eventType, windowAddress: data1, floating: rest.join("") as "0" | "1" };
    case "urgent":
      return { eventType, windowAddress: data1 };
    case "minimize":
      return { eventType, windowAddress: data1, minimized: rest.join("") as "0" | "1" };
    case "screencast":
      return { eventType, state: data1 as "0" | "1", owner: rest.join("") as "0" | "1" };
    case "windowtitle":
      return { eventType, windowAddress: data1 };
    case "ignoregrouplock":
    case "lockgroups":
      return { eventType, state: data1 as "0" | "1" };
    case "configreloaded":
      return { eventType };
    default:
      return null;
  }
}

async function readFromSocket(socket: Deno.Conn, onEvent: (event: HyprlandEvent) => Promise<void>) {
  const decoder = new TextDecoder();
  const buf = new Uint8Array(1024);
  while (true) {
    const n = await socket.read(buf);
    if (n === null) {
      break; // if socket was closed.
    }
    const rawData = decoder.decode(buf.subarray(0, n)).trim().split("\n");
    for (const text of rawData) {
      const event = parseHyprlandEvent(text);
      if (!event) {
        console.error(`Failed to parse event: ${text}`);
        continue;
      }
      await onEvent(event);
    }
  }
}

export async function listenHyprlandSocketEvent(onEvent: (event: HyprlandEvent) => Promise<void>) {
  const instanceSignature = Deno.env.get("HYPRLAND_INSTANCE_SIGNATURE");
  if (!instanceSignature) {
    console.error("$HYPRLAND_INSTANCE_SIGNATURE is not defined.");
    return;
  }

  const socketPath = `/tmp/hypr/${instanceSignature}/.socket2.sock`;
  const socket = await Deno.connect({ path: socketPath, transport: "unix" });
  try {
    await readFromSocket(socket, onEvent);
  } finally {
    socket.close();
  }
}
