#!/usr/bin/env -S deno run -A --unstable

import { parse } from "https://deno.land/std@0.208.0/flags/mod.ts";
import { format } from "https://deno.land/std@0.208.0/datetime/mod.ts";
import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import * as hyprctl from "/lib/hyprctl.ts";
import { join } from "https://deno.land/std@0.201.0/path/join.ts";

// dependencies: grim, slurp, wl-copy, notify-send, xdg-user-dir, hyprctl

// helper functions
const notify = (title: string, message: string, timeout = 2000) => $`notify-send -t ${timeout} ${title} ${message}`;
const copyImageToClip = (bytes: Uint8Array) => $`wl-copy -t image/png`.stdin(bytes);
const captureRegion = (region: string) => $`grim -g ${region} -`.bytes();
const captureScreen = () => $`grim -`.bytes();
const selectRegion = () => $`slurp`.text();

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
 * Capture selected region and save to file and clipboard
 */
async function captureSelectedRegion(saveDir: string) {
  const region = await selectRegion();
  const cap = await captureRegion(region);

  const name = fileName();
  await clipAndSave(saveDir, name, cap);
  await notify("Screenshot(Selected region)", `saved to ${name}`);
}

/**
 * Main
 */
const args = parse(Deno.args, {
  boolean: ["fullscreen", "activewindow", "region"],
  default: { fullscreen: false, activewindow: false, region: false },
});
const saveDir = join(await $`xdg-user-dir PICTURES`.text(), "Screenshots");
if (args.fullscreen) {
  await captureFullScreen(saveDir);
} else if (args.activewindow) {
  await captureActiveWindow(saveDir);
} else if (args.region) {
  await captureSelectedRegion(saveDir);
} else {
  console.error("Usage: screenshot.ts [--fullscreen | --activewindow | --region]");
}
