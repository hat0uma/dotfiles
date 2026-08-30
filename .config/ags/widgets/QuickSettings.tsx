import { createBinding, createState, With } from "ags";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import AstalBluetooth from "gi://AstalBluetooth";
import AstalBrightness from "gi://AstalBrightness";
import AstalNetwork from "gi://AstalNetwork";
import AstalWp from "gi://AstalWp";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import { WifiPage, WifiRow } from "./Network";
import { togglePowerMenu } from "./PowerMenu";

function run(command: string[]) {
  execAsync(command).catch((error) => console.error(error));
}

function BluetoothRow() {
  const bluetooth = AstalBluetooth.get_default();
  const powered = createBinding(bluetooth, "isPowered");

  return (
    <box cssClasses={["conn-row"]} spacing={10}>
      <box spacing={11} hexpand>
        <image
          iconName={powered((on) =>
            on ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
          )}
        />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
          <label cssClasses={["conn-name"]} xalign={0} label="Bluetooth" />
          <label
            cssClasses={["conn-sub"]}
            xalign={0}
            label={createBinding(bluetooth, "isConnected")((on) => (on ? "接続済み" : "オフ"))}
          />
        </box>
      </box>
      <switch
        valign={Gtk.Align.CENTER}
        active={powered}
        onNotifyActive={(self: Gtk.Switch) => (bluetooth.isPowered = self.active)}
      />
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

function QuickMain({ onOpenWifi }: { onOpenWifi: () => void }) {
  const network = AstalNetwork.get_default();
  const wifi = createBinding(network, "wifi");
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
    <box orientation={Gtk.Orientation.VERTICAL} spacing={14}>
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
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <With value={wifi}>
          {(device) => device && <WifiRow wifi={device} onOpen={onOpenWifi} />}
        </With>
        <BluetoothRow />
      </box>
    </box>
  );
}

export default function QuickSettings() {
  const [page, setPage] = createState<"main" | "wifi">("main");

  return (
    <box cssClasses={["quick-settings"]}>
      <With value={page}>
        {(current) =>
          current === "wifi" ? (
            <WifiPage onBack={() => setPage("main")} />
          ) : (
            <QuickMain onOpenWifi={() => setPage("wifi")} />
          )
        }
      </With>
    </box>
  );
}
