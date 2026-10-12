import { type Accessor, createState } from "ags";
import AstalNetwork from "gi://AstalNetwork";
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import NM from "gi://NM";

// Wi-Fi state read straight from the NetworkManager device.
//
// AstalNetwork.Wifi caches access points by BSSID and looks the active one up
// in that cache. When NM replaces an AP object (the supplicant reconnects,
// e.g. after a DHCP renew or roaming) and the new object is added before the
// old one is removed, the removal deletes the new entry: the connected network
// disappears from `accessPoints`, `ssid` stays empty and the icon goes grey
// although NM is still connected. Its `scanning` flag also sticks at true when
// a scan request is rejected. So only `enabled` and the actions that act on the
// device itself (set_enabled, deactivate_connection) still go through Astal.

Gio._promisify(NM.Client.prototype, "activate_connection_async", "activate_connection_finish");
Gio._promisify(NM.Client.prototype, "add_and_activate_connection_async", "add_and_activate_connection_finish");
Gio._promisify(NM.RemoteConnection.prototype, "commit_changes_async", "commit_changes_finish");

const ICON = {
  excellent: "network-wireless-signal-excellent-symbolic",
  good: "network-wireless-signal-good-symbolic",
  ok: "network-wireless-signal-ok-symbolic",
  weak: "network-wireless-signal-weak-symbolic",
  none: "network-wireless-signal-none-symbolic",
  acquiring: "network-wireless-acquiring-symbolic",
  connected: "network-wireless-connected-symbolic",
  disabled: "network-wireless-disabled-symbolic",
  offline: "network-wireless-offline-symbolic",
  noRoute: "network-wireless-no-route-symbolic",
  hotspot: "network-wireless-hotspot-symbolic",
};

export function signalIcon(strength: number) {
  if (strength >= 80) return ICON.excellent;
  if (strength >= 60) return ICON.good;
  if (strength >= 40) return ICON.ok;
  if (strength >= 20) return ICON.weak;
  return ICON.none;
}

export function apSsid(ap: NM.AccessPoint) {
  const bytes = ap.get_ssid();
  return bytes ? NM.utils_ssid_to_utf8(bytes.get_data() ?? new Uint8Array()) : null;
}

export function apRequiresPassword(ap: NM.AccessPoint) {
  return ap.get_wpa_flags() !== NM["80211ApSecurityFlags"].NONE ||
    ap.get_rsn_flags() !== NM["80211ApSecurityFlags"].NONE;
}

export function apConnections(ap: NM.AccessPoint) {
  return ap.filter_connections(ap.get_client().get_connections());
}

// Same behaviour as AstalNetwork.AccessPoint.activate: reuse the first saved
// connection for this AP, otherwise create a WPA-PSK one.
export async function activateAp(device: NM.DeviceWifi, ap: NM.AccessPoint, password: string | null) {
  const client = device.get_client();
  const [saved] = apConnections(ap);
  if (saved) {
    if (password !== null) {
      saved.get_setting_wireless_security()?.set_property("psk", password);
      await (saved as NM.RemoteConnection).commit_changes_async(true, null);
    }
    await client.activate_connection_async(saved, device, ap.get_path(), null);
    return;
  }
  const connection = NM.SimpleConnection.new();
  connection.add_setting(new NM.SettingWireless({ ssid: ap.get_ssid(), bssid: ap.get_bssid() }));
  connection.add_setting(new NM.SettingWirelessSecurity({ key_mgmt: "wpa-psk", psk: password ?? "" }));
  await client.add_and_activate_connection_async(connection, device, ap.get_path(), null);
}

export type WifiState = {
  ssid: Accessor<string | null>;
  iconName: Accessor<string>;
  accessPoints: Accessor<NM.AccessPoint[]>;
  scanning: Accessor<boolean>;
  scan: () => void;
};

const states = new Map<NM.DeviceWifi, WifiState>();

export function wifiState(wifi: AstalNetwork.Wifi): WifiState {
  const device = wifi.device;
  const existing = states.get(device);
  if (existing) return existing;

  const client = device.get_client();
  const [ssid, setSsid] = createState<string | null>(null);
  const [iconName, setIconName] = createState(ICON.offline);
  const [accessPoints, setAccessPoints] = createState<NM.AccessPoint[]>([]);
  const [scanning, setScanning] = createState(false);

  let activeAp: NM.AccessPoint | null = null;
  let strengthHandler = 0;

  function icon() {
    if (!client.wireless_enabled) return ICON.disabled;
    const state = device.get_state();
    if (state === NM.DeviceState.ACTIVATED) {
      if (wifi.isHotspot) return ICON.hotspot;
      if (client.connectivity !== NM.ConnectivityState.FULL) return ICON.noRoute;
      return activeAp ? signalIcon(activeAp.get_strength()) : ICON.connected;
    }
    if (state > NM.DeviceState.DISCONNECTED && state < NM.DeviceState.ACTIVATED) return ICON.acquiring;
    return ICON.offline;
  }

  function update() {
    const ap = device.get_active_access_point();
    if (ap !== activeAp) {
      if (activeAp && strengthHandler) activeAp.disconnect(strengthHandler);
      activeAp = ap;
      strengthHandler = ap ? ap.connect("notify::strength", () => setIconName(icon())) : 0;
    }
    setSsid(ap ? apSsid(ap) : null);
    setIconName(icon());
  }

  const updateAccessPoints = () => setAccessPoints([...device.get_access_points()]);

  device.connect("notify::active-access-point", update);
  device.connect("state-changed", update);
  device.connect("access-point-added", updateAccessPoints);
  device.connect("access-point-removed", updateAccessPoints);
  client.connect("notify::connectivity", update);
  client.connect("notify::wireless-enabled", update);
  update();
  updateAccessPoints();

  let scanTimeout = 0;
  function scanDone() {
    if (scanTimeout) GLib.source_remove(scanTimeout);
    scanTimeout = 0;
    setScanning(false);
  }
  device.connect("notify::last-scan", scanDone);

  function scan() {
    if (scanning()) return;
    setScanning(true);
    // NM rejects scans requested too soon after the previous one; never keep
    // showing "scanning" for a scan that does not happen.
    scanTimeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 15_000, () => {
      scanTimeout = 0;
      setScanning(false);
      return GLib.SOURCE_REMOVE;
    });
    device.request_scan_async(null, (_, res) => {
      try {
        device.request_scan_finish(res);
      } catch (error) {
        console.error(error);
        scanDone();
      }
    });
  }

  const state = { ssid, iconName, accessPoints, scanning, scan };
  states.set(device, state);
  return state;
}
