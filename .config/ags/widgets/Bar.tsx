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
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import Ime from "./Ime";
import NotificationCenter from "./Notifications";
import QuickSettings from "./QuickSettings";

const hyprland = AstalHyprland.get_default();
const apps = AstalApps.Apps.new();
const notificationButtons = new Map<string, Gtk.MenuButton>();
const statusButtons = new Map<string, Gtk.MenuButton>();

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

// Workspaces 1..N are always shown, even when empty; any occupied
// workspace beyond that is appended.
const PERSISTENT_WORKSPACES = 5;

function Workspaces({ connector }: { connector: string }) {
  const monitor = hyprland.get_monitor_by_name(connector);
  const activeId = monitor
    ? createBinding(
      monitor,
      "activeWorkspace",
    )((workspace) => workspace?.id ?? -1)
    : createBinding(
      hyprland,
      "focusedWorkspace",
    )((workspace) => workspace?.id ?? -1);

  const workspaces = createBinding(hyprland, "workspaces");
  const clients = createBinding(hyprland, "clients");

  const slots = createComputed(() => {
    const own = workspaces().filter(
      (workspace) => workspace.id > 0 && workspace.monitor?.name === connector,
    );
    const windows = clients();
    const ids = new Set(own.map((workspace) => workspace.id));
    for (let id = 1; id <= PERSISTENT_WORKSPACES; id++) ids.add(id);

    return [...ids]
      .sort((a, b) => a - b)
      .map((id) => ({
        id,
        name: own.find((workspace) => workspace.id === id)?.name || `${id}`,
        occupied: windows.some((client) => client.workspace?.id === id),
      }));
  });

  return (
    <box cssClasses={["workspaces"]}>
      <For each={slots}>
        {(slot) => (
          <button
            cssClasses={activeId((id) =>
              [
                "workspace",
                slot.occupied ? "occupied" : "empty",
                id === slot.id ? "active" : "",
              ].filter(Boolean),
            )}
            tooltipText={`Workspace ${slot.name}`}
            onClicked={() =>
              hyprland.dispatch(`hl.dsp.focus({ workspace = ${slot.id} })`, "")
            }
          >
            <label label={slot.name} />
          </button>
        )}
      </For>
    </box>
  );
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
      <image iconName={client(appIcon)} />
      <label
        hexpand
        xalign={0}
        maxWidthChars={1}
        ellipsize={3}
        label={client((item) => item?.title || "Desktop")}
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
      <popover>
        <QuickSettings />
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
    const now = GLib.DateTime.new_now_local();
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
      <popover>
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

  onCleanup(() => window.destroy());

  return (
    <window
      $={(self) => (window = self)}
      visible
      name={`bar-${connector}`}
      namespace="ags-bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <box cssClasses={["bar"]} halign={Gtk.Align.CENTER}>
        <box cssClasses={["capsule"]}>
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
      </box>
    </window>
  );
}
