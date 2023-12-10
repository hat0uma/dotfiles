#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = [
  "󰃞",
  "󰃝",
  "󰃟",
  "󰃠",
];

type Brightness = {
  deviceName: string;
  className: string;
  brightness: number;
  percentage: number;
  maxBrightness: number;
  icon: string;
};

async function getBrightness(): Promise<Brightness> {
  const output = await $`brightnessctl -m info`.text();
  const [deviceName, className, rawBrightness, rawPercent, rawMaxBrightness] = output.split(",");
  return {
    deviceName,
    className,
    brightness: parseInt(rawBrightness),
    percentage: parseInt(rawPercent),
    maxBrightness: parseInt(rawMaxBrightness),
    icon: ICONS[Math.floor(parseInt(rawPercent) / 25)],
  };
}

console.log(JSON.stringify(await getBrightness()));
