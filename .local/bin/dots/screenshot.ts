#!/usr/bin/env -S deno run -A --unstable

import { parse } from "https://deno.land/std@0.208.0/flags/mod.ts";
import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import * as hyprctl from "/lib/hyprctl.ts";

const args = parse(Deno.args, {
  boolean: ["activewindow"],
  default: { activewindow: false },
});

async function activeWindow() {
  const win = await hyprctl.fetchActiveWindow();
  const region = `${win.at[0]},${win.at[1]} ${win.size[0]}x${win.size[1]}`;
  await $`grim -g ${region}`;
}

if (args.activewindow) {
  await activeWindow();
} else {
  await $`grim`;
}
