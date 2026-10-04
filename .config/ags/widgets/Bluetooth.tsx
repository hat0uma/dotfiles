import { type Accessor, createBinding, createComputed, For, onCleanup } from "ags";
import { execAsync } from "ags/process";
import AstalBluetooth from "gi://AstalBluetooth";
import Gtk from "gi://Gtk?version=4.0";
import PageHead, { EmptyRow, SectionLabel } from "./PageHead";

function deviceIcon(device: AstalBluetooth.Device) {
  return device.icon ? `${device.icon}-symbolic` : "bluetooth-active-symbolic";
}

function DeviceRow({ device }: { device: AstalBluetooth.Device }) {
  const connected = createBinding(device, "connected");
  const connecting = createBinding(device, "connecting");
  const paired = createBinding(device, "paired");
  const battery = createBinding(device, "batteryPercentage");

  const subtitle = createComputed(() => {
    if (connecting()) return "接続中…";
    if (connected()) {
      const level = battery();
      return level > 0 ? `接続済み · バッテリー ${Math.round(level * 100)}%` : "接続済み";
    }
    return paired() ? "ペアリング済み" : "未ペアリング";
  });

  function onClicked() {
    if (device.connecting) return;
    if (device.connected) {
      device.disconnect_device((_, result) => {
        try {
          device.disconnect_device_finish(result);
        } catch (error) {
          console.error(error);
        }
      });
    } else if (!device.paired) {
      device.pair();
      device.set_trusted(true);
    } else {
      device.connect_device((_, result) => {
        try {
          device.connect_device_finish(result);
        } catch (error) {
          console.error(error);
        }
      });
    }
  }

  return (
    <button
      cssClasses={connected((on) => ["ap", on ? "current" : ""].filter(Boolean))}
      onClicked={onClicked}
    >
      <box spacing={12}>
        <image iconName={deviceIcon(device)} />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
          <label cssClasses={["ap-name"]} xalign={0} ellipsize={3} maxWidthChars={1} hexpand label={createBinding(device, "alias")} />
          <label cssClasses={["ap-sub"]} xalign={0} label={subtitle} />
        </box>
        <label
          cssClasses={["link"]}
          visible={createComputed(() => connected() || paired())}
          label={connected((on) => (on ? "切断" : "接続"))}
        />
      </box>
    </button>
  );
}

export function BluetoothPage({
  onBack,
  active,
}: {
  onBack: () => void;
  active: Accessor<boolean>;
}) {
  const bluetooth = AstalBluetooth.get_default();
  const powered = createBinding(bluetooth, "isPowered");
  const devices = createBinding(bluetooth, "devices");
  const adapter = bluetooth.adapter;
  const discovering = adapter ? createBinding(adapter, "discovering") : undefined;

  // Scan only while the page is on screen.
  const unsubscribe = active.subscribe(() => {
    if (!adapter) return;
    try {
      if (active() && adapter.powered && !adapter.discovering) adapter.start_discovery();
      else if (!active() && adapter.discovering) adapter.stop_discovery();
    } catch (error) {
      console.error(error);
    }
  });
  onCleanup(unsubscribe);

  const named = createComputed(() =>
    powered() ? devices().filter((device) => device.alias || device.name) : []);
  const known = createComputed(() =>
    named()
      .filter((device) => device.paired)
      .sort((a, b) => Number(b.connected) - Number(a.connected) || a.alias.localeCompare(b.alias)));
  const nearby = createComputed(() =>
    named()
      .filter((device) => !device.paired)
      .sort((a, b) => b.rssi - a.rssi));

  return (
    <box cssClasses={["sub-page"]} orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <PageHead title="Bluetooth" onBack={onBack}>
        <label
          cssClasses={["scanning"]}
          label="検索中"
          opacity={discovering ? createComputed(() => (powered() && discovering() ? 1 : 0)) : 0}
        />
        <switch
          cssClasses={["compact-switch"]}
          valign={Gtk.Align.CENTER}
          active={powered}
          onNotifyActive={(self: Gtk.Switch) => {
            if (adapter && adapter.powered !== self.active) adapter.powered = self.active;
          }}
        />
      </PageHead>

      <scrolledwindow minContentHeight={320} maxContentHeight={320} propagateNaturalHeight={false}>
        <box cssClasses={["ap-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <label
            cssClasses={["cap", "list-empty"]}
            xalign={0}
            visible={powered((on) => !on)}
            label={adapter ? "Bluetooth はオフです" : "Bluetooth アダプタが見つかりません"}
          />
          <box orientation={Gtk.Orientation.VERTICAL} spacing={4} visible={powered}>
            <SectionLabel label="デバイス" />
            <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
              <For each={known}>{(device) => <DeviceRow device={device} />}</For>
            </box>
            <box visible={known((list) => list.length === 0)}>
              <EmptyRow label="ペアリング済みのデバイスはありません" />
            </box>
            <SectionLabel label="周辺のデバイス" />
            <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
              <For each={nearby}>{(device) => <DeviceRow device={device} />}</For>
            </box>
            <box visible={nearby((list) => list.length === 0)}>
              <EmptyRow label="見つかったデバイスはありません" />
            </box>
          </box>
        </box>
      </scrolledwindow>

      <button cssClasses={["pop-foot"]} onClicked={() => execAsync(["blueman-manager"]).catch(console.error)}>
        <box spacing={8}>
          <image iconName="preferences-system-symbolic" />
          <label hexpand xalign={0} label="詳細設定" />
          <label cssClasses={["mono"]} label="blueman-manager" />
        </box>
      </button>
    </box>
  );
}

export function BluetoothRow({ onOpen }: { onOpen: () => void }) {
  const bluetooth = AstalBluetooth.get_default();
  const powered = createBinding(bluetooth, "isPowered");
  const devices = createBinding(bluetooth, "devices");
  const subtitle = createComputed(() => {
    if (!powered()) return "オフ";
    const connected = devices().filter((device) => device.connected);
    if (connected.length === 0) return "接続なし";
    const [first] = connected;
    return connected.length > 1 ? `${first.alias} ほか ${connected.length - 1} 台` : first.alias;
  });

  return (
    <box cssClasses={powered((on) => ["conn-row", on ? "" : "off"].filter(Boolean))} spacing={10}>
      <button cssClasses={["conn-row-main"]} hexpand onClicked={onOpen}>
        <box spacing={12}>
          <image
            iconName={powered((on) => (on ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"))}
          />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label cssClasses={["conn-name"]} xalign={0} label="Bluetooth" />
            <label cssClasses={["conn-sub"]} xalign={0} ellipsize={3} maxWidthChars={1} hexpand label={subtitle} />
          </box>
          <image cssClasses={["chev"]} iconName="go-next-symbolic" />
        </box>
      </button>
      <switch
        cssClasses={["compact-switch"]}
        valign={Gtk.Align.CENTER}
        active={powered}
        onNotifyActive={(self: Gtk.Switch) => {
          const adapter = bluetooth.adapter;
          if (adapter && adapter.powered !== self.active) adapter.powered = self.active;
        }}
      />
    </box>
  );
}
