import { type Accessor, createBinding, createComputed, createState, For, onCleanup, type State, With } from "ags";
import { execAsync } from "ags/process";
import AstalNetwork from "gi://AstalNetwork";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import PageHead from "./PageHead";

function run(command: string[]) {
  execAsync(command).catch((error) => console.error(error));
}

function WiredRow({ wired }: { wired: AstalNetwork.Wired }) {
  const active = createBinding(
    wired,
    "state",
  )((state) => state === AstalNetwork.DeviceState.ACTIVATED);

  return (
    <box cssClasses={["ap", "wired"]} visible={active} spacing={12}>
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
  const rowClasses = createComputed(() => [
    "ap",
    isActive() ? "current" : "",
    openSsid() !== null && openSsid() !== ap.ssid ? "dim" : "",
  ].filter(Boolean));

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
      <button cssClasses={rowClasses} onClicked={onRowClicked}>
        <box spacing={12}>
          <image iconName={createBinding(ap, "iconName")} />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label
              cssClasses={["ap-name"]}
              xalign={0}
              ellipsize={3}
              maxWidthChars={1}
              hexpand
              label={ap.ssid ?? ""}
            />
            <label
              cssClasses={["ap-sub"]}
              xalign={0}
              visible={isActive((active) => active || ap.get_connections().length > 0)}
              label={isActive((active) => active ? "接続済み" : "保存済み")}
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
                cssClasses={["password-field"]}
                $={(self) => (passwordEntry = self)}
                visibility={false}
                secondaryIconName="view-reveal-symbolic"
                placeholderText="パスワード"
                onActivate={() => connect(passwordEntry.get_text())}
              />
              <With value={error}>
                {(message) =>
                  message && <label cssClasses={["pwd-error"]} xalign={0} label={message} />
                }
              </With>
              <box cssClasses={["btns"]} spacing={8} halign={Gtk.Align.END}>
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

export function WifiPage({ onBack, active }: { onBack: () => void; active: Accessor<boolean> }) {
  const network = AstalNetwork.get_default();
  const wifi = network.wifi;
  const [openSsid, setOpenSsid] = createState<string | null>(null);

  if (!wifi) {
    return (
      <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
        <PageHead title="Wi-Fi" onBack={onBack} />
        <label cssClasses={["cap"]} label="Wi-Fi デバイスが見つかりません" />
      </box>
    );
  }

  // Scan when the page opens and every 15s while it stays open.
  const rescan = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 15_000, () => {
    if (active() && wifi.enabled) wifi.scan();
    return GLib.SOURCE_CONTINUE;
  });
  const unsubscribe = active.subscribe(() => {
    if (active() && wifi.enabled) wifi.scan();
    if (!active()) setOpenSsid(null);
  });
  onCleanup(() => {
    GLib.source_remove(rescan);
    unsubscribe();
  });

  const enabled = createBinding(wifi, "enabled");
  const ssid = createBinding(wifi, "ssid");
  const scanning = createBinding(wifi, "scanning");
  const showScanning = createComputed(() => enabled() && scanning());
  const accessPoints = createBinding(wifi, "accessPoints");
  const wired = createBinding(network, "wired");

  const apRows = createComputed(() => {
    if (!enabled()) return [];
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
    <box cssClasses={["sub-page", "wifi-page"]} orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      <PageHead title="Wi-Fi" onBack={onBack}>
        <label
          cssClasses={["scanning"]}
          label="検索中"
          opacity={showScanning((visible) => visible ? 1 : 0)}
        />
        <switch
          cssClasses={["compact-switch"]}
          valign={Gtk.Align.CENTER}
          active={enabled}
          onNotifyActive={(self: Gtk.Switch) => {
            wifi.set_enabled(self.active);
            if (self.active) wifi.scan();
          }}
        />
      </PageHead>

      <scrolledwindow
        minContentHeight={320}
        maxContentHeight={320}
        propagateNaturalHeight={false}
      >
        <box cssClasses={["ap-list"]} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
          <With value={wired}>{(w) => w && <WiredRow wired={w} />}</With>
          <For each={apRows}>
            {(ap) => (
              <AccessPointRow ap={ap} wifi={wifi} openSsid={openSsid} setOpenSsid={setOpenSsid} />
            )}
          </For>
        </box>
      </scrolledwindow>

      <button cssClasses={["pop-foot"]} onClicked={() => run(["nm-connection-editor"])}>
        <box spacing={8}>
          <image iconName="preferences-system-symbolic" />
          <label hexpand xalign={0} label="詳細設定" />
          <label cssClasses={["mono"]} label="nm-connection-editor" />
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
        <box spacing={12}>
          <image iconName={createBinding(wifi, "iconName")} />
          <box orientation={Gtk.Orientation.VERTICAL} hexpand valign={Gtk.Align.CENTER}>
            <label cssClasses={["conn-name"]} xalign={0} label="Wi-Fi" />
            <label cssClasses={["conn-sub"]} xalign={0} ellipsize={3} maxWidthChars={1} hexpand label={subtitle} />
          </box>
          <image cssClasses={["chev"]} iconName="go-next-symbolic" />
        </box>
      </button>
      <switch
        cssClasses={["compact-switch"]}
        valign={Gtk.Align.CENTER}
        active={enabled}
        onNotifyActive={(self: Gtk.Switch) => wifi.set_enabled(self.active)}
      />
    </box>
  );
}
