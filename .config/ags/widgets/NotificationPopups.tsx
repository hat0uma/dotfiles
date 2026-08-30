import { createComputed, createState, onCleanup, With } from "ags";
import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import AstalHyprland from "gi://AstalHyprland";
import AstalNotifd from "gi://AstalNotifd";
import Gdk from "gi://Gdk?version=4.0";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";

const TOAST_DURATION = 6000;
type Toast = {
  id: number;
  notification: AstalNotifd.Notification;
  expiresAt: number | null;
};

const [toasts, setToasts] = createState<Toast[]>([]);
const timers = new Map<number, number>();

function clearTimer(id: number) {
  const source = timers.get(id);
  if (source !== undefined) {
    GLib.source_remove(source);
    timers.delete(id);
  }
}

function dismissToast(id: number) {
  clearTimer(id);
  setToasts((current) => current.filter((toast) => toast.id !== id));
}

function pushToast(notification: AstalNotifd.Notification) {
  const id = notification.id;
  const expiresAt = notification.urgency === AstalNotifd.Urgency.CRITICAL
    ? null
    : Date.now() + TOAST_DURATION;
  setToasts((current) => [
    { id, notification, expiresAt },
    ...current.filter((toast) => toast.id !== id),
  ]);

  clearTimer(id);
  if (expiresAt !== null) {
    const source = GLib.timeout_add(GLib.PRIORITY_DEFAULT, TOAST_DURATION, () => {
      timers.delete(id);
      dismissToast(id);
      return GLib.SOURCE_REMOVE;
    });
    timers.set(id, source);
  }
}

const notifd = AstalNotifd.get_default();
notifd.connect("notified", (_source, id) => {
  if (notifd.dontDisturb) return;
  const notification = notifd.get_notification(id);
  if (notification) pushToast(notification);
});
notifd.connect("resolved", (_source, id) => dismissToast(id));

function connectorOf(monitor: Gdk.Monitor) {
  return monitor.connector || `${monitor.get_model()}-${monitor.get_manufacturer()}`;
}

function ToastCard({ toast, now }: { toast: Toast; now: () => number }) {
  const { notification } = toast;
  const urgent = notification.urgency === AstalNotifd.Urgency.CRITICAL;
  const progress = createComputed(() => toast.expiresAt === null
    ? 0
    : Math.max(0, Math.min(1, (toast.expiresAt - now()) / TOAST_DURATION)));

  return (
    <box cssClasses={["toast", urgent ? "urgent" : ""].filter(Boolean)} orientation={Gtk.Orientation.VERTICAL}>
      <box cssClasses={["toast-content"]} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <box cssClasses={["note-meta"]} spacing={6}>
          <label cssClasses={["note-app"]} label={notification.appName || "通知"} />
          <label label="·" />
          <label label="今" />
          <box hexpand />
          <button cssClasses={["note-close"]} onClicked={() => dismissToast(notification.id)}>
            <image iconName="window-close-symbolic" />
          </button>
        </box>
        <label cssClasses={["note-sum"]} xalign={0} wrap label={notification.summary} />
        {notification.body && <label cssClasses={["note-body"]} xalign={0} wrap label={notification.body} />}
        {notification.actions.length > 0 && (
          <box cssClasses={["note-actions"]} spacing={6}>
            {notification.actions.map((action) => (
              <button cssClasses={["note-act"]} onClicked={() => {
                action.invoke();
                dismissToast(notification.id);
              }}>
                <label label={action.label} />
              </button>
            ))}
          </box>
        )}
      </box>
      {!urgent && <progressbar cssClasses={["toast-progress"]} fraction={progress} />}
    </box>
  );
}

export default function NotificationPopups() {
  let window: Astal.Window;
  const hyprland = AstalHyprland.get_default();
  const { TOP, RIGHT } = Astal.WindowAnchor;
  const [now, setNow] = createState(Date.now());
  const top = createComputed(() => toasts()[0] ?? null);
  const count = createComputed(() => toasts().length);

  const ticker = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
    setNow(Date.now());
    return GLib.SOURCE_CONTINUE;
  });
  const monitorFor = (connector: string | undefined) =>
    app.get_monitors().find((monitor) => connectorOf(monitor) === connector);
  const initial = monitorFor(hyprland.focusedMonitor?.name) ?? app.get_monitors()[0];
  const handler = hyprland.connect("notify::focused-monitor", () => {
    const monitor = monitorFor(hyprland.focusedMonitor?.name);
    if (monitor) window.set_gdkmonitor(monitor);
  });

  onCleanup(() => {
    GLib.source_remove(ticker);
    hyprland.disconnect(handler);
    window.destroy();
  });

  return (
    <window
      $={(self) => (window = self)}
      visible={count((value) => value > 0)}
      name="notification-popups"
      namespace="ags-notifications"
      gdkmonitor={initial}
      exclusivity={Astal.Exclusivity.NORMAL}
      anchor={TOP | RIGHT}
      keymode={Astal.Keymode.NONE}
      application={app}
    >
      <box cssClasses={["toast-stack"]} orientation={Gtk.Orientation.VERTICAL}>
        <box cssClasses={["toast-slot"]}>
          <With value={top}>{(toast) => toast && <ToastCard toast={toast} now={now} />}</With>
        </box>
        <box cssClasses={["toast-under"]} visible={count((value) => value > 1)} />
        <box cssClasses={["toast-under", "deep"]} visible={count((value) => value > 2)} />
        <label
          cssClasses={["toast-more"]}
          halign={Gtk.Align.CENTER}
          visible={count((value) => value > 1)}
          label={count((value) => `ほか ${value - 1} 件`)}
        />
      </box>
    </window>
  );
}
