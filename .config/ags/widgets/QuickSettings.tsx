import { createBinding, createState, onCleanup, With } from "ags";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
import AstalBrightness from "gi://AstalBrightness";
import AstalNetwork from "gi://AstalNetwork";
import AstalWp from "gi://AstalWp";
import Gtk from "gi://Gtk?version=4.0";
import { AudioPage, AudioRow } from "./Audio";
import { BluetoothPage, BluetoothRow } from "./Bluetooth";
import { WifiPage, WifiRow } from "./Network";
import { togglePowerMenu } from "./PowerMenu";
import { nowDateTime } from "../lib/clock";

function run(command: string[]) {
  execAsync(command).catch((error) => console.error(error));
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
            valign={Gtk.Align.CENTER}
            tooltipText="ミュート切り替え"
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
        <box cssClasses={["control-icon-slot"]} valign={Gtk.Align.CENTER} hexpand={false}>
          <image hexpand iconName="display-brightness-symbolic" />
        </box>
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

function QuickMain({
  onOpenPage,
  onTakeScreenshot,
}: {
  onOpenPage: (page: QuickPage) => void;
  onTakeScreenshot: () => void;
}) {
  const network = AstalNetwork.get_default();
  const wifi = createBinding(network, "wifi");
  const time = createPoll(
    "",
    1000,
    () => nowDateTime().format("%H:%M:%S")!,
  );
  const date = createPoll(
    "",
    60_000,
    () => {
      const now = nowDateTime();
      const weekday = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"][
        now.get_day_of_week() - 1
      ];
      return `${now.format("%Y年%m月%d日")!} ${weekday}`;
    },
  );

  return (
    <box cssClasses={["quick-main"]} orientation={Gtk.Orientation.VERTICAL} spacing={14}>
      <box cssClasses={["quick-head"]}>
        <box hexpand orientation={Gtk.Orientation.VERTICAL}>
          <label cssClasses={["quick-time"]} xalign={0} label={time} />
          <label cssClasses={["quick-date"]} xalign={0} label={date} />
        </box>
        <box cssClasses={["quick-actions"]} spacing={6} valign={Gtk.Align.CENTER}>
          <button
            cssClasses={["round-button"]}
            tooltipText="Take a screenshot"
            onClicked={onTakeScreenshot}
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
      <box cssClasses={["connections"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <With value={wifi}>
          {(device) => device && <WifiRow wifi={device} onOpen={() => onOpenPage("wifi")} />}
        </With>
        <BluetoothRow onOpen={() => onOpenPage("bluetooth")} />
        <AudioRow onOpen={() => onOpenPage("audio")} />
      </box>
    </box>
  );
}

export type QuickPage = "main" | "wifi" | "bluetooth" | "audio";
const pageSetters = new Set<(page: QuickPage, animate: boolean) => void>();

export function showQuickPage(page: QuickPage, animate = true) {
  pageSetters.forEach((set) => set(page, animate));
}

export default function QuickSettings({
  onTakeScreenshot,
}: {
  onTakeScreenshot: () => void;
}) {
  const [page, setPage] = createState<QuickPage>("main");
  const showPage = (next: QuickPage) => setPage(next);
  let stack: Gtk.Stack;
  const setter = (next: QuickPage, animate: boolean) => {
    const duration = stack.transitionDuration;
    if (!animate) stack.transitionDuration = 0;
    setPage(next);
    stack.transitionDuration = duration;
  };
  pageSetters.add(setter);
  onCleanup(() => pageSetters.delete(setter));

  return (
    <box cssClasses={["quick-settings"]}>
      <Gtk.Stack
        $={(self) => (stack = self)}
        cssClasses={["quick-pages"]}
        visibleChildName={page}
        transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
        transitionDuration={160}
        hhomogeneous
        vhomogeneous={false}
        interpolateSize
      >
        <box $type="named" name="main">
          <QuickMain onOpenPage={showPage} onTakeScreenshot={onTakeScreenshot} />
        </box>
        <box $type="named" name="wifi">
          <WifiPage onBack={() => showPage("main")} active={page((name) => name === "wifi")} />
        </box>
        <box $type="named" name="bluetooth">
          <BluetoothPage onBack={() => showPage("main")} active={page((name) => name === "bluetooth")} />
        </box>
        <box $type="named" name="audio">
          <AudioPage onBack={() => showPage("main")} />
        </box>
      </Gtk.Stack>
    </box>
  );
}
