import { createBinding, createComputed, createState, For, onCleanup, type State, With } from "ags";
import { execAsync } from "ags/process";
import AstalNetwork from "gi://AstalNetwork";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";

function run(command: string[]) {
  execAsync(command).catch((error) => console.error(error));
}

function WiredRow({ wired }: { wired: AstalNetwork.Wired }) {
  const active = createBinding(
    wired,
    "state",
  )((state) => state === AstalNetwork.DeviceState.ACTIVATED);

  return (
    <box cssClasses={["ap", "wired"]} visible={active} spacing={11}>
      <image iconName={createBinding(wired, "iconName")} />
      <box orientation={Gtk.Orientation.VERTICAL} hexpand>
        <label cssClasses={["ap-name"]} xalign={0} label="有線 LAN" />
        <label cssClasses={["ap-sub"]} xalign={0} label="接続済み" />
      </box>
    </box>
  );
}

function AccessPointRow({
  ap,
  wifi,
  openSsid,
  setOpenSsid,
}: {
  ap: AstalNetwork.AccessPoint;
  wifi: AstalNetwork.Wifi;
  openSsid: State<string | null>[0];
  setOpenSsid: State<string | null>[1];
}) {
  const [connecting, setConnecting] = createState(false);
  const [error, setError] = createState("");
  let passwordEntry: Gtk.Entry;

  const isActive = createBinding(wifi, "ssid")((ssid) => !!ssid && ssid === ap.ssid);
  const isOpen = createComputed(() => openSsid() === ap.ssid);

  function connect(password: string | null) {
    setConnecting(true);
    setError("");
    ap.activate(password)
      .then(() => {
        setConnecting(false);
        setOpenSsid(null);
      })
      .catch((err: unknown) => {
        setConnecting(false);
        setError("接続できませんでした");
        console.error(err);
      });
  }

  function onRowClicked() {
    if (ap.ssid === wifi.ssid && wifi.enabled) {
      wifi.deactivate_connection().catch((err: unknown) => console.error(err));
      return;
    }
    if (openSsid() === ap.ssid) {
      setOpenSsid(null);
      return;
    }
    if (ap.get_connections().length > 0) {
      connect(null);
      return;
    }
    if (ap.requiresPassword) {
      setError("");
      setOpenSsid(ap.ssid);
      return;
    }
    connect(null);
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL}>
      <button cssClasses={["ap"]} onClicked={onRowClicked}>
        <box spacing={11}>
          <image iconName={createBinding(ap, "iconName")} />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label
              cssClasses={isActive((active) => ["ap-name", active ? "current" : ""].filter(Boolean))}
              xalign={0}
              label={ap.ssid ?? ""}
            />
            <label
              cssClasses={["ap-sub"]}
              xalign={0}
              visible={isActive}
              label="接続済み"
            />
          </box>
          <With value={isActive}>
            {(active) => active && <label cssClasses={["link"]} label="切断" />}
          </With>
          <image
            cssClasses={["lock"]}
            visible={ap.requiresPassword}
            iconName="channel-secure-symbolic"
          />
        </box>
      </button>
      <With value={isOpen}>
        {(open) =>
          open && (
            <box cssClasses={["pwd"]} orientation={Gtk.Orientation.VERTICAL} spacing={9}>
              <label cssClasses={["pwd-label"]} xalign={0} label={`${ap.ssid} のパスワード`} />
              <entry
                $={(self) => (passwordEntry = self)}
                visibility={false}
                placeholderText="パスワード"
                onActivate={() => connect(passwordEntry.get_text())}
              />
              <With value={error}>
                {(message) =>
                  message && <label cssClasses={["pwd-error"]} xalign={0} label={message} />
                }
              </With>
              <box spacing={8} halign={Gtk.Align.END}>
                <button cssClasses={["btn", "ghost"]} onClicked={() => setOpenSsid(null)}>
                  <label label="キャンセル" />
                </button>
                <button
                  cssClasses={["btn", "primary"]}
                  sensitive={connecting((busy) => !busy)}
                  onClicked={() => connect(passwordEntry.get_text())}
                >
                  <label label={connecting((busy) => (busy ? "接続中…" : "接続"))} />
                </button>
              </box>
            </box>
          )
        }
      </With>
    </box>
  );
}

export function WifiPage({ onBack }: { onBack: () => void }) {
  const network = AstalNetwork.get_default();
  const wifi = network.wifi;
  const [openSsid, setOpenSsid] = createState<string | null>(null);

  if (!wifi) {
    return (
      <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
        <box cssClasses={["pop-head"]} spacing={10}>
          <button cssClasses={["back"]} onClicked={onBack}>
            <image iconName="go-previous-symbolic" />
          </button>
          <label cssClasses={["pop-title"]} hexpand xalign={0} label="Wi-Fi" />
        </box>
        <label cssClasses={["cap"]} label="Wi-Fi デバイスが見つかりません" />
      </box>
    );
  }

  wifi.scan();
  const rescan = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 15_000, () => {
    wifi.scan();
    return GLib.SOURCE_CONTINUE;
  });
  onCleanup(() => GLib.source_remove(rescan));

  const enabled = createBinding(wifi, "enabled");
  const ssid = createBinding(wifi, "ssid");
  const scanning = createBinding(wifi, "scanning");
  const accessPoints = createBinding(wifi, "accessPoints");
  const wired = createBinding(network, "wired");

  const apRows = createComputed(() => {
    const points = accessPoints();
    const active = ssid();
    const bySsid = new Map<string, AstalNetwork.AccessPoint>();
    for (const ap of points) {
      if (!ap.ssid) continue;
      const current = bySsid.get(ap.ssid);
      if (!current || ap.strength > current.strength) bySsid.set(ap.ssid, ap);
    }
    return [...bySsid.values()].sort((a, b) => {
      if (a.ssid === active) return -1;
      if (b.ssid === active) return 1;
      return b.strength - a.strength;
    });
  });

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <box cssClasses={["pop-head"]} spacing={10}>
        <button cssClasses={["back"]} onClicked={onBack}>
          <image iconName="go-previous-symbolic" />
        </button>
        <label cssClasses={["pop-title"]} hexpand xalign={0} label="Wi-Fi" />
        <With value={scanning}>
          {(isScanning) => isScanning && <label cssClasses={["scanning"]} label="検索中" />}
        </With>
        <switch active={enabled} onNotifyActive={(self: Gtk.Switch) => wifi.set_enabled(self.active)} />
      </box>

      <box cssClasses={["ap-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={2}>
        <With value={wired}>{(w) => w && <WiredRow wired={w} />}</With>
        <For each={apRows}>
          {(ap) => (
            <AccessPointRow ap={ap} wifi={wifi} openSsid={openSsid} setOpenSsid={setOpenSsid} />
          )}
        </For>
      </box>

      <button cssClasses={["pop-foot"]} onClicked={() => run(["nm-connection-editor"])}>
        <box spacing={8}>
          <image iconName="preferences-system-symbolic" />
          <label hexpand xalign={0} label="詳細設定" />
        </box>
      </button>
    </box>
  );
}

export function WifiRow({
  wifi,
  onOpen,
}: {
  wifi: AstalNetwork.Wifi;
  onOpen: () => void;
}) {
  const enabled = createBinding(wifi, "enabled");
  const ssid = createBinding(wifi, "ssid");
  const scanning = createBinding(wifi, "scanning");

  const subtitle = createComputed(() => {
    if (!enabled()) return "オフ";
    if (ssid()) return ssid();
    if (scanning()) return "検索中…";
    return "接続なし";
  });

  return (
    <box cssClasses={["conn-row"]} spacing={10}>
      <button cssClasses={["conn-row-main"]} hexpand onClicked={onOpen}>
        <box spacing={11}>
          <image iconName={createBinding(wifi, "iconName")} />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label cssClasses={["conn-name"]} xalign={0} label="Wi-Fi" />
            <label cssClasses={["conn-sub"]} xalign={0} label={subtitle} />
          </box>
          <image cssClasses={["chev"]} iconName="go-next-symbolic" />
        </box>
      </button>
      <switch
        valign={Gtk.Align.CENTER}
        active={enabled}
        onNotifyActive={(self: Gtk.Switch) => wifi.set_enabled(self.active)}
      />
    </box>
  );
}
