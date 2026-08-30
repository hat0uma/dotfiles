import { createBinding, createComputed, For, onCleanup, With } from "ags";
import app from "ags/gtk4/app";
import { createPoll } from "ags/time";
import Astal from "gi://Astal?version=4.0";
import AstalApps from "gi://AstalApps";
import AstalBattery from "gi://AstalBattery";
import AstalHyprland from "gi://AstalHyprland";
import AstalNetwork from "gi://AstalNetwork";
import AstalTray from "gi://AstalTray";
import AstalWp from "gi://AstalWp";
import Gdk from "gi://Gdk?version=4.0";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import QuickSettings from "./QuickSettings";

const hyprland = AstalHyprland.get_default();
const apps = AstalApps.Apps.new();

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

function Workspaces({ connector }: { connector: string }) {
  const workspaces = createBinding(
    hyprland,
    "workspaces",
  )((items) =>
    items
      .filter(
        (workspace) =>
          workspace.id > 0 && workspace.monitor?.name === connector,
      )
      .sort((a, b) => a.id - b.id),
  );

  return (
    <box cssClasses={["module", "workspaces"]}>
      <For each={workspaces}>
        {(workspace) => {
          const active = workspace.monitor
            ? createBinding(
              workspace.monitor,
              "activeWorkspace",
            )((current) => current?.id === workspace.id)
            : false;
          const classes =
            typeof active === "boolean"
              ? ["workspace"]
              : active((value) => ["workspace", value ? "active" : ""]);

          return (
            <button
              cssClasses={classes}
              tooltipText={`Workspace ${workspace.name}`}
              onClicked={() => workspace.focus()}
            >
              <label label={workspace.name} />
            </button>
          );
        }}
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
    <box cssClasses={["module", "active-window"]}>
      <image iconName={client(appIcon)} />
      <label
        maxWidthChars={56}
        ellipsize={3}
        label={client((item) => item?.title || "Desktop")}
      />
    </box>
  );
}

function Battery() {
  const battery = AstalBattery.get_default();
  return (
    <box
      cssClasses={["module", "battery"]}
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

function StatusIcons() {
  const network = AstalNetwork.get_default();
  const wireplumber = AstalWp.get_default();
  const wifi = createBinding(network, "wifi");

  return (
    <menubutton cssClasses={["module", "status"]}>
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
      </box>
      <popover>
        <QuickSettings />
      </popover>
    </menubutton>
  );
}

function Tray() {
  const tray = AstalTray.get_default();
  const items = createBinding(tray, "items");

  const setup = (button: Gtk.MenuButton, item: AstalTray.TrayItem) => {
    button.menuModel = item.menuModel;
    button.insert_action_group("dbusmenu", item.actionGroup);
    item.connect("notify::action-group", () =>
      button.insert_action_group("dbusmenu", item.actionGroup),
    );
  };

  return (
    <box
      cssClasses={["module", "tray"]}
      visible={items((value) => value.length > 0)}
    >
      <For each={items}>
        {(item) => (
          <menubutton
            tooltipText={createBinding(item, "tooltipMarkup")}
            $={(self) => setup(self, item)}
          >
            <image gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  );
}

function Clock() {
  const time = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%b%d日 %H:%M")!,
  );
  return <label cssClasses={["module", "clock"]} label={time} />;
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
      <centerbox cssClasses={["bar"]}>
        <box $type="start" halign={Gtk.Align.START}>
          <Workspaces connector={connector} />
        </box>
        <box $type="center" halign={Gtk.Align.CENTER}>
          <ActiveWindow connector={connector} />
        </box>
        <box $type="end" halign={Gtk.Align.END} spacing={6}>
          <Battery />
          <StatusIcons />
          <Tray />
          <Clock />
        </box>
      </centerbox>
    </window>
  );
}
