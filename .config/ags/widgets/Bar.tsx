import { createBinding, createComputed, For, onCleanup, With } from "ags";
import app from "ags/gtk4/app";
import { createPoll } from "ags/time";
import Astal from "gi://Astal?version=4.0";
import AstalApps from "gi://AstalApps";
import AstalBattery from "gi://AstalBattery";
import AstalHyprland from "gi://AstalHyprland";
import AstalNetwork from "gi://AstalNetwork";
import AstalNotifd from "gi://AstalNotifd";
import AstalWp from "gi://AstalWp";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";
import Ime from "./Ime";
import Workspaces from "./Workspaces";
import NotificationCenter, { resetCalendar } from "./Notifications";
import QuickSettings, { showQuickPage, type QuickPage } from "./QuickSettings";
import { getToastWindow } from "./NotificationPopups";
import { nowDateTime, visualTestMode } from "../lib/clock";
import { describeTree, renderWidgetToPng, wait } from "../lib/snapshot";
import { toggleScreenshotMenu } from "./ScreenshotMenu";

const hyprland = AstalHyprland.get_default();
const apps = AstalApps.Apps.new();
const notificationButtons = new Map<string, Gtk.MenuButton>();
const statusButtons = new Map<string, Gtk.MenuButton>();
const capsules = new Map<string, Gtk.Widget>();

export function toggleNotifications(connector?: string) {
  const button = connector
    ? notificationButtons.get(connector)
    : notificationButtons.values().next().value;
  if (button) button.active = !button.active;
}

export function toggleStatus(connector?: string) {
  const button = connector
    ? statusButtons.get(connector)
    : statusButtons.values().next().value;
  if (button) button.active = !button.active;
}

function pick<T>(map: Map<string, T>, connector?: string) {
  return (connector && map.get(connector)) || map.values().next().value;
}

const popoverTargets: Record<string, { buttons: Map<string, Gtk.MenuButton>; page?: QuickPage }> = {
  status: { buttons: statusButtons, page: "main" },
  wifi: { buttons: statusButtons, page: "wifi" },
  bluetooth: { buttons: statusButtons, page: "bluetooth" },
  audio: { buttons: statusButtons, page: "audio" },
  notifications: { buttons: notificationButtons },
};

// The Wi-Fi page does not scan during visual tests (a scan briefly empties
// the list), and right after startup only the connected AP is known: run one
// full scan per process before the first Wi-Fi capture.
let accessPointsReady = false;
async function ensureAccessPoints() {
  const wifi = AstalNetwork.get_default().wifi;
  if (accessPointsReady || !wifi?.enabled) return;
  wifi.scan();
  let started = false;
  for (let tries = 0; tries < 150; tries++) {
    await wait(100);
    started ||= wifi.scanning;
    if (started && !wifi.scanning) break;
  }
  await wait(500);
  accessPointsReady = true;
}

export const snapshotTargetNames = ["bar", "toast", ...Object.keys(popoverTargets)];

// Renders one bar widget (or popover) to a PNG; used by tests/visual.
// mode "tree" returns the widget tree with allocations instead.
export async function snapshotTarget(
  target: string,
  path: string,
  connector?: string,
  mode: "png" | "tree" = "png",
) {
  const output = (widget: Gtk.Widget) =>
    mode === "tree" ? describeTree(widget) : renderWidgetToPng(widget, path);

  if (target === "bar") {
    const capsule = pick(capsules, connector);
    if (!capsule) throw new Error("no bar");
    // The window, not the capsule, so the offset shadow is included.
    return output(capsule.get_root() as Gtk.Widget);
  }

  if (target === "toast") {
    const toast = getToastWindow();
    if (!toast) throw new Error("no toast is showing");
    return output(toast);
  }

  const spec = popoverTargets[target];
  if (!spec) throw new Error(`unknown target: ${target} (${snapshotTargetNames.join(", ")})`);
  const button = pick(spec.buttons, connector);
  const popover = button?.get_popover();
  if (!button || !popover) throw new Error(`no popover for ${target}`);

  if (target === "wifi") await ensureAccessPoints();

  const wasActive = button.active;
  if (spec.page) showQuickPage(spec.page, false);
  button.active = true;
  try {
    // Let the popover map and allocate, and 1s clock polls pick up a frozen clock.
    await wait(1200);
    // Re-opening right after the previous capture closed it can leave the
    // popover unmapped for a moment; wait for it to come back.
    for (let tries = 0; popover.get_width() <= 0 && tries < 20; tries++) {
      button.active = true;
      await wait(100);
    }
    return output(popover);
  } finally {
    button.active = wasActive;
    if (spec.page) showQuickPage("main", false);
    await wait(150);
  }
}

function appIcon(client: AstalHyprland.Client | null | undefined) {
  if (!client) return "application-x-executable-symbolic";

  const normalize = (value: string) =>
    value.toLowerCase().replace(/\.desktop$/, "");
  const classes = [client.initialClass, client.class]
    .filter(Boolean)
    .map(normalize);
  const application =
    apps.list.find((item) => {
      const executable =
        item.executable.trim().split(/\s+/)[0].split("/").pop() || "";
      return [item.wmClass, item.entry, executable]
        .filter(Boolean)
        .map(normalize)
        .some((value) => classes.includes(value));
    }) || classes.flatMap((name) => apps.fuzzy_query(name))[0];

  return application?.iconName || "application-x-executable-symbolic";
}

function ActiveWindow({ connector }: { connector: string }) {
  const monitor = hyprland.get_monitor_by_name(connector);
  const focusedClient = createBinding(hyprland, "focusedClient");

  const client = monitor
    ? (() => {
      const activeWorkspace = createBinding(monitor, "activeWorkspace");
      return createComputed(() => {
        const focused = focusedClient();
        const workspace = activeWorkspace();

        return focused?.monitor?.name === connector
          ? focused
          : workspace.lastClient;
      });
    })()
    : focusedClient;

  return (
    <box cssClasses={["active-window"]} widthRequest={380}>
      <image
        iconName={createComputed(() =>
          visualTestMode() ? "application-x-executable-symbolic" : appIcon(client()))}
      />
      <label
        hexpand
        xalign={0}
        maxWidthChars={1}
        ellipsize={3}
        label={createComputed(() =>
          visualTestMode() ? "Visual test" : client()?.title || "Desktop")}
      />
    </box>
  );
}

function Battery() {
  const battery = AstalBattery.get_default();
  const low = createBinding(battery, "percentage")((value) => value < 0.2);

  return (
    <box
      cssClasses={low((value) =>
        ["battery", value ? "low" : ""].filter(Boolean),
      )}
      visible={createBinding(battery, "isPresent")}
      tooltipText={createBinding(battery, "state")((state) => `${state}`)}
    >
      <image iconName={createBinding(battery, "iconName")} />
      <label
        label={createBinding(
          battery,
          "percentage",
        )((value) => `${Math.round(value * 100)}%`)}
      />
    </box>
  );
}

function StatusIcons({ connector }: { connector: string }) {
  const network = AstalNetwork.get_default();
  const wireplumber = AstalWp.get_default();
  const wifi = createBinding(network, "wifi");
  onCleanup(() => statusButtons.delete(connector));

  return (
    <menubutton
      cssClasses={["status"]}
      valign={Gtk.Align.CENTER}
      $={(self) => {
        statusButtons.set(connector, self);
      }}
    >
      <box spacing={6}>
        <With value={wifi}>
          {(device) =>
            device && <image iconName={createBinding(device, "iconName")} />
          }
        </With>
        {wireplumber?.defaultSpeaker && (
          <image
            iconName={createBinding(wireplumber.defaultSpeaker, "volumeIcon")}
          />
        )}
        <Battery />
      </box>
      <popover onClosed={() => showQuickPage("main", false)}>
        <QuickSettings
          onTakeScreenshot={() => {
            const button = statusButtons.get(connector);
            if (button) button.active = false;
            toggleScreenshotMenu(connector);
          }}
        />
      </popover>
    </menubutton>
  );
}

function Clock({ connector }: { connector: string }) {
  const notifd = AstalNotifd.get_default();
  const hasUnread = createBinding(
    notifd,
    "notifications",
  )((list) => list.length > 0);
  const time = createPoll("", 1000, () => {
    const now = nowDateTime();
    const weekday = ["月", "火", "水", "木", "金", "土", "日"][
      now.get_day_of_week() - 1
    ];
    return `${now.format("%-m月%-d日")!} (${weekday}) ${now.format("%H:%M")!}`;
  });
  onCleanup(() => notificationButtons.delete(connector));

  return (
    <menubutton
      cssClasses={["clock"]}
      valign={Gtk.Align.CENTER}
      $={(self) => {
        notificationButtons.set(connector, self);
      }}
    >
      <box spacing={6}>
        <label label={time} />
        <box
          cssClasses={["dot"]}
          visible={hasUnread}
          valign={Gtk.Align.CENTER}
        />
      </box>
      <popover cssClasses={["notification-popover"]} onShow={() => resetCalendar()}>
        <NotificationCenter />
      </popover>
    </menubutton>
  );
}

function Separator() {
  return <box cssClasses={["sep"]} />;
}

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let window: Astal.Window;
  const connector =
    gdkmonitor.connector ||
    `${gdkmonitor.get_model()}-${gdkmonitor.get_manufacturer()}`;
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  onCleanup(() => {
    capsules.delete(connector);
    window.destroy();
  });

  return (
    <window
      $={(self) => (window = self)}
      layer={Astal.Layer.BOTTOM}
      visible
      name={`bar-${connector}`}
      namespace="ags-bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <box
        cssClasses={["bar"]}
        halign={Gtk.Align.CENTER}
        orientation={Gtk.Orientation.VERTICAL}
      >
        <box cssClasses={["capsule"]} $={(self) => capsules.set(connector, self)}>
          <Workspaces connector={connector} />
          <Separator />
          <ActiveWindow connector={connector} />
          <Separator />
          <box cssClasses={["chips"]} valign={Gtk.Align.CENTER} spacing={0}>
            <Ime />
            <StatusIcons connector={connector} />
            <Clock connector={connector} />
          </box>
        </box>
        <box cssClasses={["accent-line"]} />
      </box>
    </window>
  );
}
