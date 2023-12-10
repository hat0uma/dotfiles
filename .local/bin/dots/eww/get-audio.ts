#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

const ICONS = {
  muted: "󰖁",
  low: "󰖀",
  high: "󰕾",
};

type Audio = {
  icon: string;
  volume: number;
};

async function getAudio(): Promise<Audio> {
  const output = await $`wpctl get-volume @DEFAULT_SINK@`.text();
  const [, volumetext] = output.split(":");
  const volume = parseFloat(volumetext);

  const icon = volume <= 0 ? ICONS.muted : volume <= 0.5 ? ICONS.low : ICONS.high;
  return {
    volume: volume,
    icon: icon,
  };
}

console.log(JSON.stringify(await getAudio()));
