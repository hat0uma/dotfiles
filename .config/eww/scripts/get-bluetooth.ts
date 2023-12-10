#!/usr/bin/env -S deno run -A --unstable

import * as bluetoothctl from "./lib/bluetoothctl.ts";

const ICONS = {
  disconnected: "󰂲",
  connected: "󰂱",
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
    return { state: "disconnected", icon: ICONS.disconnected };
  } else {
    return {
      state: "connected",
      icon: ICONS.connected,
      name: activeDevice.Alias || activeDevice.Name || "unknown",
    };
  }
}

console.log(JSON.stringify(await getActiveBluetoothDevice()));
