import { onCleanup } from "ags";
import app from "ags/gtk4/app";
import { execAsync } from "ags/process";
import Astal from "gi://Astal?version=4.0";
import AstalHyprland from "gi://AstalHyprland";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";

const hyprland = AstalHyprland.get_default();

export function closePowerMenu() {
  for (const window of app.get_windows()) {
    if (window.name.startsWith("power-menu-")) window.visible = false;
  }
  execAsync(["hyprctl", "dispatch", "submap", "reset"]).catch(console.error);
}

export function togglePowerMenu(connector = hyprland.focusedMonitor?.name) {
  const target = connector && app.get_window(`power-menu-${connector}`);
  const shouldShow = target ? !target.visible : false;
  closePowerMenu();
  if (target) target.visible = shouldShow;
}

function action(command: string[]) {
  closePowerMenu();
  execAsync(command).catch((error) => console.error(error));
}

function PowerButton({ icon, label, shortcut, command }: {
  icon: string;
  label: string;
  shortcut: string;
  command: string[];
}) {
  return (
    <button
      cssClasses={["power-button"]}
      onClicked={() => action(command)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
        <image iconName={icon} pixelSize={52} />
        <label cssClasses={["power-label"]} label={label} />
        <label cssClasses={["power-shortcut"]} label={shortcut} />
      </box>
    </button>
  );
}

export default function PowerMenu({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let window: Astal.Window;
  const connector = gdkmonitor.connector ||
    `${gdkmonitor.get_model()}-${gdkmonitor.get_manufacturer()}`;
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;

  onCleanup(() => window.destroy());

  return (
    <window
      $={(self) => (window = self)}
      visible={false}
      name={`power-menu-${connector}`}
      namespace="ags-power-menu"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      keymode={Astal.Keymode.EXCLUSIVE}
      application={app}
    >
      <box
        cssClasses={["power-backdrop"]}
        hexpand
        vexpand
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
      >
        <box cssClasses={["power-card"]} spacing={6}>
          <PowerButton
            icon="system-reboot-symbolic"
            label="Reboot"
            shortcut="Shift+R"
            command={["systemctl", "reboot"]}
          />
          <PowerButton
            icon="system-shutdown-symbolic"
            label="Poweroff"
            shortcut="Shift+S"
            command={["systemctl", "poweroff"]}
          />
          <PowerButton
            icon="system-suspend-symbolic"
            label="Suspend"
            shortcut="Shift+Z"
            command={["systemctl", "suspend"]}
          />
          <PowerButton
            icon="system-lock-screen-symbolic"
            label="Lock"
            shortcut="Shift+L"
            command={["swaylock", "-f", "-c", "000000"]}
          />
          <PowerButton
            icon="system-log-out-symbolic"
            label="Logout"
            shortcut="Shift+Q"
            command={["hyprctl", "dispatch", "exit"]}
          />
        </box>
      </box>
    </window>
  );
}
