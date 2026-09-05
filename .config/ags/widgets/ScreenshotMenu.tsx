import { onCleanup } from "ags";
import app from "ags/gtk4/app";
import { execAsync } from "ags/process";
import Astal from "gi://Astal?version=4.0";
import AstalHyprland from "gi://AstalHyprland";
import Gdk from "gi://Gdk?version=4.0";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";

type CaptureMode = "region" | "window" | "full";

const hyprland = AstalHyprland.get_default();
let capturePending = false;

export function closeScreenshotMenu() {
  for (const window of app.get_windows()) {
    if (window.name.startsWith("screenshot-menu-")) window.visible = false;
  }
}

export function toggleScreenshotMenu(
  connector = hyprland.focusedMonitor?.name,
) {
  const target = connector && app.get_window(`screenshot-menu-${connector}`);
  const shouldShow = target ? !target.visible : false;
  closeScreenshotMenu();
  if (target) target.visible = shouldShow;
}

function capture(mode: CaptureMode) {
  if (capturePending) return;

  capturePending = true;
  closeScreenshotMenu();
  GLib.timeout_add(GLib.PRIORITY_DEFAULT, 150, () => {
    execAsync(["screenshot", mode]).catch((error) => console.error(error));
    capturePending = false;
    return GLib.SOURCE_REMOVE;
  });
}

function CaptureButton({
  icon,
  label,
  shortcut,
  mode,
}: {
  icon: string;
  label: string;
  shortcut: string;
  mode: CaptureMode;
}) {
  return (
    <button cssClasses={["screenshot-button"]} onClicked={() => capture(mode)}>
      <box orientation={Gtk.Orientation.VERTICAL} spacing={3}>
        <image iconName={icon} pixelSize={24} />
        <label cssClasses={["screenshot-label"]} label={label} />
        <label cssClasses={["screenshot-shortcut"]} label={shortcut} />
      </box>
    </button>
  );
}

export default function ScreenshotMenu({
  gdkmonitor,
}: {
  gdkmonitor: Gdk.Monitor;
}) {
  let window: Astal.Window;
  const connector =
    gdkmonitor.connector ||
    `${gdkmonitor.get_model()}-${gdkmonitor.get_manufacturer()}`;
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  onCleanup(() => window.destroy());

  return (
    <window
      $={(self) => {
        window = self;
        const keys = new Gtk.EventControllerKey();
        keys.connect("key-pressed", (_controller, keyval) => {
          switch (keyval) {
            case Gdk.KEY_Escape:
              closeScreenshotMenu();
              return true;
            case Gdk.KEY_r:
            case Gdk.KEY_R:
              capture("region");
              return true;
            case Gdk.KEY_w:
            case Gdk.KEY_W:
              capture("window");
              return true;
            case Gdk.KEY_f:
            case Gdk.KEY_F:
              capture("full");
              return true;
            default:
              return false;
          }
        });
        self.add_controller(keys);
      }}
      visible={false}
      name={`screenshot-menu-${connector}`}
      namespace="ags-screenshot-menu"
      gdkmonitor={gdkmonitor}
      anchor={TOP | LEFT | RIGHT}
      keymode={Astal.Keymode.EXCLUSIVE}
      application={app}
    >
      <box cssClasses={["screenshot-bar"]} halign={Gtk.Align.CENTER}>
        <box cssClasses={["screenshot-card"]} spacing={4}>
          <CaptureButton
            icon="edit-select-all-symbolic"
            label="Region"
            shortcut="R"
            mode="region"
          />
          <CaptureButton
            icon="window-new-symbolic"
            label="Window"
            shortcut="W"
            mode="window"
          />
          <CaptureButton
            icon="view-fullscreen-symbolic"
            label="Fullscreen"
            shortcut="F"
            mode="full"
          />
          <button
            cssClasses={["screenshot-close"]}
            tooltipText="Close (Esc)"
            onClicked={closeScreenshotMenu}
          >
            <image iconName="window-close-symbolic" />
          </button>
        </box>
      </box>
    </window>
  );
}
