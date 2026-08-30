import { createBinding, With } from "ags";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import AstalBluetooth from "gi://AstalBluetooth";
import AstalBrightness from "gi://AstalBrightness";
import AstalNetwork from "gi://AstalNetwork";
import AstalWp from "gi://AstalWp";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import { togglePowerMenu } from "./PowerMenu";

function run(command: string[]) {
  execAsync(command).catch((error) => console.error(error));
}

function StatusRow() {
  const network = AstalNetwork.get_default();
  const bluetooth = AstalBluetooth.get_default();
  const wifi = createBinding(network, "wifi");

  return (
    <box cssClasses={["status-row"]} spacing={8}>
      <With value={wifi}>
        {(device) =>
          device && (
            <box
              cssClasses={["status-chip"]}
              tooltipText={createBinding(device, "ssid")}
            >
              <image iconName={createBinding(device, "iconName")} />
              <label
                label={createBinding(device, "ssid")((ssid) =>
                  ssid || "Offline"
                )}
              />
            </box>
          )}
      </With>
      <box cssClasses={["status-chip"]}>
        <image
          iconName={createBinding(bluetooth, "isPowered")((on) =>
            on ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
          )}
        />
        <label
          label={createBinding(bluetooth, "isConnected")((on) =>
            on ? "Connected" : "Bluetooth"
          )}
        />
      </box>
    </box>
  );
}

function Controls() {
  const wireplumber = AstalWp.get_default();
  const speaker = wireplumber?.defaultSpeaker;
  const brightness = AstalBrightness.get_default().screen;

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      {speaker && (
        <box cssClasses={["control"]} spacing={10}>
          <button
            cssClasses={["icon-button"]}
            onClicked={() => speaker.set_mute(!speaker.mute)}
          >
            <image iconName={createBinding(speaker, "volumeIcon")} />
          </button>
          <slider
            hexpand
            value={createBinding(speaker, "volume")}
            onChangeValue={({ value }) => speaker.set_volume(value)}
          />
          <label
            label={createBinding(speaker, "volume")((value) =>
              `${Math.round(value * 100)}%`
            )}
          />
        </box>
      )}
      <box
        cssClasses={["control"]}
        spacing={10}
        visible={createBinding(brightness, "maxBrightness")((value) =>
          value > 0
        )}
      >
        <image iconName="display-brightness-symbolic" />
        <slider
          hexpand
          value={createBinding(brightness, "brightness")}
          onChangeValue={({ value }) => brightness.set_brightness(value)}
        />
        <label
          label={createBinding(brightness, "brightness")((value) =>
            `${Math.round(value * 100)}%`
          )}
        />
      </box>
    </box>
  );
}

export default function QuickSettings() {
  const time = createPoll(
    "",
    1000,
    () => GLib.DateTime.new_now_local().format("%H:%M:%S")!,
  );
  const date = createPoll(
    "",
    60_000,
    () => GLib.DateTime.new_now_local().format("%Y年%m月%d日 %A")!,
  );

  return (
    <box
      cssClasses={["quick-settings"]}
      orientation={Gtk.Orientation.VERTICAL}
      spacing={14}
    >
      <box>
        <box hexpand orientation={Gtk.Orientation.VERTICAL}>
          <label cssClasses={["quick-time"]} xalign={0} label={time} />
          <label cssClasses={["quick-date"]} xalign={0} label={date} />
        </box>
        <box spacing={6} valign={Gtk.Align.CENTER}>
          <button
            cssClasses={["round-button"]}
            tooltipText="Take a screenshot"
            onClicked={() =>
              run(["screenshot", "--fullscreen", "--delay", "0.5"])}
          >
            <image iconName="camera-photo-symbolic" />
          </button>
          <button
            cssClasses={["round-button", "danger"]}
            tooltipText="Open power menu"
            onClicked={() => {
              run(["hyprctl", "dispatch", "submap", "powermenu"]);
              togglePowerMenu();
            }}
          >
            <image iconName="system-shutdown-symbolic" />
          </button>
        </box>
      </box>
      <Controls />
      <StatusRow />
    </box>
  );
}
