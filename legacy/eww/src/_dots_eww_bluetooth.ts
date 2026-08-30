#!/usr/bin/env -S deno run -A --unstable

import * as bluetoothctl from "/lib/bluetoothctl.ts";

const ICONS = {
  disconnected: "󰂲",
  connected: "󰂱",
};

const ICON_NAMES = {
  disconnected: "bluetooth-disabled-symbolic",
  connected: "bluetooth-active-symbolic",
};

type Bluetooth = {
  state: "connected";
  icon: string;
  name: string;
  device: string;
} | { state: "disconnected"; icon: string };

async function getActiveBluetoothDevice() {
  const devices = await bluetoothctl.info().catch(() => []);
  const activeDevice = devices.find((device) => device.Connected);
  if (!activeDevice) {
    return { state: "disconnected", icon: ICON_NAMES.disconnected };
  } else {
    return {
      state: "connected",
      icon: ICON_NAMES.connected,
      name: activeDevice.Alias || activeDevice.Name || "unknown",
    };
  }
}

console.log(JSON.stringify(await getActiveBluetoothDevice()));
