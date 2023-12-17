#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { delay } from "https://deno.land/std@0.208.0/async/mod.ts";
import { format } from "https://deno.land/std@0.208.0/datetime/mod.ts";
import { join } from "https://deno.land/std@0.201.0/path/join.ts";
import { notify } from "./lib/notify.ts";

/**
 * Check dependencies are installed, otherwise exit.
 */
async function checkDependencies() {
  const deps = [
    "grim",
    "hyprctl",
    "notify-send",
    "slurp",
    "swappy",
    "wl-copy",
    "xdg-open",
    "xdg-user-dir",
  ];
  const results = await Promise.all(deps.map((dep) => $.commandExists(dep)));
  results.forEach((ok, i) => {
    if (!ok) {
      console.error(`Missing dependency: ${deps[i]}`);
      Deno.exit(1);
    }
  });
}

// helper functions
const copyImageToClip = (bytes: Uint8Array, file: string) => $`wl-copy -t image/png ${file}`.stdin(bytes);
const captureRegion = (region: string) => $`grim -g ${region} -`.bytes();
const captureScreen = () => $`grim -`.bytes();
const selectRegion = () => $`slurp`.text();
const edit = (img: Uint8Array) => $`swappy -f -`.stdin(img);

/**
 * Show notification and wait for user action
 * @param title - title of notification
 * @param message - message of notification
 * @param saveDir - directory to save file
 * @param file - file name
 */
async function notifySave(title: string, message: string, saveDir: string, file: string) {
  const path = join(saveDir, file);
  const choice = await notify(title, message)
    .setIcon(path)
    .setTimeout(10000)
    .setTransient()
    .addAction("open_folder", "Open Folder")
    .addAction("edit", "Edit")
    .send();

  switch (choice) {
    case "open_folder":
      await $`xdg-open ${saveDir}`;
      break;
    case "edit":
      await $`swappy -f ${path}`;
      break;
    default:
      // do nothing
      break;
  }
}

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
  const clip = copyImageToClip(image, fileName);
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
  await notifySave("Screenshot(ActiveWindow)", `saved to ${saveDir}`, saveDir, name);
}

/**
 * Capture full screen and save to file and clipboard
 */
async function captureFullScreen(saveDir: string) {
  const cap = await captureScreen();

  const name = fileName();
  await clipAndSave(saveDir, name, cap);
  await notifySave("Screenshot(Full screen)", `saved to ${saveDir}`, saveDir, name);
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
    await checkDependencies();
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
