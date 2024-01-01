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

export type HyprlandEventListener = (ev: HyprlandEvent) => Promise<void>;

function splitData<T extends string>(rawData: string, ...argNames: T[]): { [key in T]: string } {
  const data: { [key in T]?: string } = {};
  for (let i = 0; i < argNames.length; i++) {
    const delimIdx = rawData.indexOf(",");
    if (delimIdx === -1 && i !== argNames.length - 1) {
      // not last argument
      throw new Error(`fewer arguments: ${rawData}`);
    } else if (delimIdx === -1) {
      // last argument
      data[argNames[i]] = rawData;
    } else {
      data[argNames[i]] = rawData.substring(0, delimIdx);
      rawData = rawData.substring(delimIdx + 1);
    }
  }
  return data as { [key in T]: string };
}

function parseHyprlandEvent(eventString: string): HyprlandEvent | null {
  const eventTypeMatch = eventString.match(/^(.*?)>>/);
  if (!eventTypeMatch) {
    return null;
  }
  const eventType = eventTypeMatch[1];
  const rawData = eventString.substring(eventTypeMatch[0].length);

  switch (eventType) {
    case "workspace":
      return { eventType, ...splitData(rawData, "workspaceName") };
    case "focusedmon":
      return { eventType, ...splitData(rawData, "monName", "workspaceName") };
    case "activewindow":
      return { eventType, ...splitData(rawData, "windowClass", "windowTitle") };
    case "activewindowv2":
      return { eventType, ...splitData(rawData, "windowAddress") };
    case "fullscreen": {
      const data = splitData(rawData, "state");
      return { eventType, state: data.state === "1" ? "1" : "0" };
    }
    case "monitorremoved":
    case "monitoradded":
      return { eventType, ...splitData(rawData, "monitorName") };
    case "createworkspace":
    case "destroyworkspace":
      return { eventType, ...splitData(rawData, "workspaceName") };
    case "moveworkspace":
    case "renameworkspace":
      return { eventType, ...splitData(rawData, "workspaceName", "additionalData") };
    case "activespecial":
      return { eventType, ...splitData(rawData, "workspaceName", "monName") };
    case "activelayout":
      return { eventType, ...splitData(rawData, "keyboardName", "layoutName") };
    case "openwindow":
      return {
        eventType,
        ...splitData(
          rawData,
          "windowAddress",
          "workspaceName",
          "windowClass",
          "windowTitle",
        ),
      };
    case "closewindow":
      return { eventType, ...splitData(rawData, "windowAddress") };
    case "movewindow":
      return { eventType, ...splitData(rawData, "windowAddress", "workspaceName") };
    case "openlayer":
    case "closelayer":
      return { eventType, ...splitData(rawData, "namespace") };
    case "submap":
      return { eventType, ...splitData(rawData, "submapName") };
    case "changefloatingmode": {
      const data = splitData(rawData, "windowAddress", "floating");
      return { eventType, windowAddress: data.windowAddress, floating: data.floating === "1" ? "1" : "0" };
    }
    case "urgent":
      return { eventType, ...splitData(rawData, "windowAddress") };
    case "minimize": {
      const data = splitData(rawData, "windowAddress", "minimized");
      return { eventType, windowAddress: data.windowAddress, minimized: data.minimized === "1" ? "1" : "0" };
    }
    case "screencast": {
      const data = splitData(rawData, "state", "owner");
      return { eventType, state: data.state === "1" ? "1" : "0", owner: data.owner === "1" ? "1" : "0" };
    }
    case "windowtitle":
      return { eventType, ...splitData(rawData, "windowAddress") };
    case "ignoregrouplock":
    case "lockgroups": {
      const data = splitData(rawData, "state");
      return { eventType, state: data.state === "1" ? "1" : "0" };
    }
    case "configreloaded":
      return { eventType };
    default:
      return null;
  }
}

async function readFromSocket(socket: Deno.Conn, onEvent: HyprlandEventListener) {
  const decoder = new TextDecoder();
  for await (const d of socket.readable) {
    const rawData = decoder.decode(d).trim().split("\n");
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

export async function listenHyprlandSocketEvent(onEvent: HyprlandEventListener) {
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
