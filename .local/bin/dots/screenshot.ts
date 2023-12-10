#!/usr/bin/env -S deno run -A --unstable

import { parse } from "https://deno.land/std@0.208.0/flags/mod.ts";
import { format } from "https://deno.land/std@0.208.0/datetime/mod.ts";
import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import { CommandBuilder } from "https://deno.land/x/dax@0.35.0/src/command.ts";

// dependencies: grim, slurp, wl-copy, notify-send, xdg-user-dir, hyprctl
const args = parse(Deno.args, {
  boolean: ["activewindow", "region", "clipboard"],
  default: { activewindow: false, region: false, clipboard: false },
});

async function fileName(suffix = ".png") {
  const dir = await $`xdg-user-dir PICTURES`.text();
  const prefix = "Screenshot_";
  const date = format(new Date(), "yyyyMMdd_HHmmss");
  return `${dir}/${prefix}${date}${suffix}`;
}

async function notify(title: string, message: string, timeout = 2000) {
  await $`notify-send -t ${timeout} ${title} ${message}`;
}

async function wlcopy(cmd: CommandBuilder) {
  await $`wl-copy -t image/png`.stdin(cmd.stdout("piped").spawn().stdout());
}

async function activeWindow(clipboard = false) {
  const win = await hyprctl.fetchActiveWindow();
  const region = `${win.at[0]},${win.at[1]} ${win.size[0]}x${win.size[1]}`;
  if (clipboard) {
    await wlcopy($`grim -g ${region} -`);
    await notify("Screenshot(ActiveWindow)", "copied to clipboard");
  } else {
    const name = await fileName(`_${win.class}.png`);
    await $`grim -g ${region} ${name}`;
    await notify("Screenshot(ActiveWindow)", `saved to ${name}`);
  }
}

async function fullScreen(clipboard = false) {
  if (clipboard) {
    await wlcopy($`grim -`);
    await notify("Screenshot(Full screen)", "copied to clipboard");
  } else {
    const name = await fileName();
    await $`grim ${name}`;
    await notify("Screenshot(Full screen)", `saved to ${name}`);
  }
}

async function selectedRegion(clipboard = false) {
  const region = await $`slurp`.text();
  if (clipboard) {
    await wlcopy($`grim -g ${region} -`);
    await notify("Screenshot(Selected region)", "copied to clipboard");
  } else {
    const name = await fileName();
    await $`grim -g ${region} ${name}`;
    await notify("Screenshot(Selected region)", `saved to ${name}`);
  }
}

if (args.activewindow) {
  await activeWindow(args.clipboard);
} else if (args.region) {
  await selectedRegion(args.clipboard);
} else {
  await fullScreen(args.clipboard);
}
