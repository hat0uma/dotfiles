#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = {
  muted: "󰖁",
  low: "󰕿",
  medium: "󰖀",
  high: "󰕾",
};

const ICON_NAMES = {
  muted: "audio-volume-muted-symbolic",
  low: "audio-volume-low-symbolic",
  medium: "audio-volume-medium-symbolic",
  high: "audio-volume-high-symbolic",
};

type Audio = {
  icon: string;
  volume: number;
};

async function getAudio(): Promise<Audio> {
  const output = await $`wpctl get-volume @DEFAULT_SINK@`.text();
  const [, volumetext] = output.split(":");
  const volume = parseFloat(volumetext);

  const icon = volume <= 0
    ? ICON_NAMES.muted
    : volume <= 0.33
    ? ICON_NAMES.low
    : volume <= 0.66
    ? ICON_NAMES.medium
    : ICON_NAMES.high;
  return {
    volume: volume,
    icon: icon,
  };
}

console.log(JSON.stringify(await getAudio()));
