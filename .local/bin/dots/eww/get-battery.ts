#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = {
  charging: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"],
  notCharging: ["󰢟", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
};

type Battery = {
  status: string;
  percentage: number;
  icon: string;
  extra: string;
};
async function getBatteryInfo(): Promise<Battery | null> {
  const output = await $`acpi -b`.text();
  const parsed = parseAcpiOutput(output);
  if (parsed === null) {
    return null;
  }
  return { ...parsed, icon: getBatteryIcon(parsed.status, parsed.percentage) };
}

function getBatteryIcon(status: string, percentage: number) {
  const index = Math.floor(percentage / 10);
  if (status === "Discharging") {
    return ICONS.notCharging[index];
  } else {
    return ICONS.charging[index];
  }
}

function parseAcpiOutput(output: string) {
  // patterns:
  //   ❯ acpi -b
  //   Battery 0: Full, 100%
  //   ❯ acpi -b
  //   Battery 0: Discharging, 100%, 04:07:47 remaining
  //   ❯ acpi -b
  //   Battery 0: Not charging, 98%
  //   ❯ acpi -b
  //   Battery 0: Charging, 86%, 03:09:50 until charged
  const delimIndex = output.indexOf(":");
  if (delimIndex === -1) {
    return null;
  }
  const message = output.slice(delimIndex + 1).split(",").map((t) => t.trim());
  const status = message.at(0);
  const percentageText = message.at(1);
  const extra = message.at(2);
  if (!status || !percentageText) {
    console.error(`failed to parse acpi output:${output}`);
    return null;
  }
  return {
    status: status,
    percentage: parseInt(percentageText),
    extra: extra ?? status,
  };
}

const battery = await getBatteryInfo();
if (battery) {
  console.log(JSON.stringify(battery));
}
