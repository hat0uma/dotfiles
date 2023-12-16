#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { delay } from "https://deno.land/std@0.208.0/async/mod.ts";
import { format } from "https://deno.land/std@0.208.0/datetime/mod.ts";
import { join } from "https://deno.land/std@0.201.0/path/join.ts";

// dependencies: grim, slurp, wl-copy, notify-send, xdg-user-dir, hyprctl, swappy

// helper functions
const notify = (title: string, message: string, timeout = 2000) => $`notify-send -t ${timeout} ${title} ${message}`;
const copyImageToClip = (bytes: Uint8Array) => $`wl-copy -t image/png`.stdin(bytes);
const captureRegion = (region: string) => $`grim -g ${region} -`.bytes();
const captureScreen = () => $`grim -`.bytes();
const selectRegion = () => $`slurp`.text();
const edit = (img: Uint8Array) => $`swappy -f -`.stdin(img);

/**
 * Generate file name
 */
function fileName(suffix = ".png", date = new Date()) {
  const prefix = "Screenshot_";
  const dateText = format(date, "yyyyMMdd_HHmmss");
  return `${prefix}${dateText}${suffix}`;
}

/**
 * Save image to file and clipboard
 */
function clipAndSave(saveDir: string, fileName: string, image: Uint8Array) {
  Deno.mkdirSync(saveDir, { recursive: true });
  const dest = join(saveDir, fileName);
  const save = Deno.writeFile(dest, image, { create: true, append: false });
  const clip = copyImageToClip(image);
  return Promise.all([save, clip]);
}

/**
 * Capture active window and save to file and clipboard
 */
async function captureActiveWindow(saveDir: string) {
  const win = await hyprctl.fetchActiveWindow();
  const region = `${win.at[0]},${win.at[1]} ${win.size[0]}x${win.size[1]}`;
  const cap = await captureRegion(region);

  const name = fileName(`_${win.class}.png`);
  await clipAndSave(saveDir, name, cap);
  await notify("Screenshot(ActiveWindow)", `saved to ${name}`);
}

/**
 * Capture full screen and save to file and clipboard
 */
async function captureFullScreen(saveDir: string) {
  const cap = await captureScreen();

  const name = fileName();
  await clipAndSave(saveDir, name, cap);
  await notify("Screenshot(Full screen)", `saved to ${name}`);
}

/**
 * Capture selected region and edit it
 */
async function captureSelectedRegionAndEdit() {
  const region = await selectRegion();
  const cap = await captureRegion(region);
  await edit(cap);
}

/**
 * Main
 */
await new Command()
  .option("-f, --fullscreen", "Capture full screen", { default: false })
  .option("-a, --activewindow", "Capture active window", { default: false })
  .option("-r, --regionedit", "Capture selected region and edit it", { default: false })
  .option("-d, --delay <seconds:number>", "Delay in seconds", { default: 0 })
  .action(async (opts) => {
    const saveDir = join(await $`xdg-user-dir PICTURES`.text(), "Screenshots");
    const delayMs = opts.delay * 1000;
    if (opts.fullscreen) {
      await delay(delayMs);
      await captureFullScreen(saveDir);
    } else if (opts.activewindow) {
      await delay(delayMs);
      await captureActiveWindow(saveDir);
    } else if (opts.regionedit) {
      await delay(delayMs);
      await captureSelectedRegionAndEdit();
    } else {
      console.error("Usage: screenshot.ts [--fullscreen | --activewindow | --regionedit]");
    }
  })
  .parse(Deno.args);
