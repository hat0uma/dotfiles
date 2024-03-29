#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = {
  wifi: {
    disconnected: "󰤭",
    connected: [
      "󰤟",
      "󰤢",
      "󰤥",
      "󰤨",
    ],
    connectedSecure: [
      "󰤡",
      "󰤤",
      "󰤧",
      "󰤪",
    ],
    connectedNotSecure: [
      "󰤠",
      "󰤣",
      "󰤦",
      "󰤩",
    ],
  },
  ethernet: {
    connected: "󰈁",
    disconnected: "󰈂",
  },
};

const ICON_NAMES = {
  wifi: {
    disconnected: "network-wireless-offline-symbolic",
    connected: [
      "network-wireless-signal-weak-symbolic",
      "network-wireless-signal-ok-symbolic",
      "network-wireless-signal-good-symbolic",
      "network-wireless-signal-excellent-symbolic",
    ],
  },
  ethernet: {
    connected: "network-wired-symbolic",
    disconnected: "network-wired-disconnected-symbolic",
  },
};

type Wifi = {
  state: "connected";
  icon: string;
  ssid: string;
  device: string;
} | { state: "disconnected"; icon: string };

// NOTE: nmcli -t -f name,type,device,state connection show
//   : active connections both ethernet and wifi. but no wifi signal level

async function getActiveWifiConnection() {
  const output = await $`LANG=C nmcli -t -f device,ssid,active,signal,security device wifi`.text();
  const lines = output.split("\n");
  const ssids = lines.map((line) => {
    const [device, ssid, active, signal, security] = line.split(":");
    return { device, ssid, active, signal, security };
  });
  const activeSsid = ssids.find((ssid) => ssid.active === "yes") || null;
  return activeSsid;
}

function getWifiIcon(signal: string) {
  const index = Math.floor(parseInt(signal) / 25);
  return ICON_NAMES.wifi.connected[index];
}

async function getWifi(): Promise<Wifi> {
  const activeSsid = await getActiveWifiConnection();
  if (activeSsid === null) {
    return {
      state: "disconnected",
      icon: ICON_NAMES.wifi.disconnected,
    };
  }
  const icon = getWifiIcon(activeSsid.signal);
  return {
    state: "connected",
    icon: icon,
    ssid: activeSsid.ssid,
    device: activeSsid.device,
  };
}

console.log(JSON.stringify(await getWifi()));
