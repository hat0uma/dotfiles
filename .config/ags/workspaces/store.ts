import AstalHyprland from "gi://AstalHyprland";
import GLib from "gi://GLib";

const hyprland = AstalHyprland.get_default();
const listeners = new Set<() => void>();
const events = new Set([
  "openwindow", "closewindow", "movewindowv2", "changefloatingmode", "fullscreen",
  "activewindowv2", "workspacev2", "focusedmon", "moveworkspacev2",
  "monitoradded", "monitorremoved", "togglegroup", "windowtitlev2", "configreloaded",
]);
let eventId = 0, pollId = 0, debounceId = 0;
let running = false, pending = false;

// Use explicit GI callbacks: generated Promise overloads do not promisify GI at runtime.
function syncClients() {
  return new Promise<void>((resolve, reject) => {
    hyprland.sync_clients((source, result) => {
      try { source!.sync_clients_finish(result); resolve(); } catch (error) { reject(error); }
    });
  });
}
function syncMonitors() {
  return new Promise<void>((resolve, reject) => {
    hyprland.sync_monitors((source, result) => {
      try { source!.sync_monitors_finish(result); resolve(); } catch (error) { reject(error); }
    });
  });
}
async function refresh() {
  if (running) { pending = true; return; }
  running = true;
  try {
    const results = await Promise.allSettled([syncClients(), syncMonitors()]);
    const failures = results.filter(r => r.status === "rejected");
    if (failures.length) failures.forEach(r => console.error("Workspace minimap sync:", r.reason));
    else for (const notify of listeners) notify();
  } catch (error) {
    console.error("Workspace minimap:", error);
  } finally {
    running = false;
    if (pending && listeners.size) { pending = false; void refresh(); }
  }
}

export function subscribe(callback: () => void) {
  listeners.add(callback);
  if (listeners.size === 1) {
    eventId = hyprland.connect("event", (_, name) => {
      if (!events.has(name)) return;
      if (debounceId) GLib.source_remove(debounceId);
      debounceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
        debounceId = 0;
        void refresh();
        return GLib.SOURCE_REMOVE;
      });
    });
    pollId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
      void refresh();
      return GLib.SOURCE_CONTINUE;
    });
    void refresh();
  } else callback();
  return () => {
    listeners.delete(callback);
    if (listeners.size) return;
    hyprland.disconnect(eventId);
    GLib.source_remove(pollId);
    if (debounceId) GLib.source_remove(debounceId);
    eventId = pollId = debounceId = 0;
    pending = false;
  };
}
