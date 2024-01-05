import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { existsSync } from "https://deno.land/std@0.201.0/fs/exists.ts";

// https://wiki.hyprland.org/Nvidia/
export async function setupNvidia() {
  /**
   * add nvidia_drm.modeset=1 to the end of /boot/loader/entries/arch.conf.
   */
  async function addNvidiaDrmModeset() {
    const text = await Deno.readTextFile("/boot/loader/entries/arch.conf");
    const lines = text.split("\n");
    const optionLine = lines.findIndex((line) => line.startsWith("options"));
    if (optionLine === -1) {
      throw new Error("options line not found");
    }
    if (lines[optionLine].includes("nvidia-drm.modeset=1")) {
      $.log("nvidia-drm.modeset=1 already exists");
      return;
    }
    lines[optionLine] += " nvidia-drm.modeset=1";
    await $`sudo tee /boot/loader/entries/arch.conf`.stdinText(
      lines.join("\n"),
    );
  }
  /**
   * in /etc/mkinitcpio.conf add nvidia nvidia_modeset nvidia_uvm nvidia_drm to MODULES
   */
  async function addNvidiaModules() {
    const text = await Deno.readTextFile("/etc/mkinitcpio.conf");
    const lines = text.split("\n");
    for (let i = 0; i < lines.length; i++) {
      const match = lines[i].match(/MODULES=\((.*)\)/);
      if (match) {
        const modules = new Set(match[1] !== "" ? match[1].split(" ") : []);
        modules.add("nvidia");
        modules.add("nvidia_modeset");
        modules.add("nvidia_uvm");
        modules.add("nvidia_drm");
        lines[i] = `MODULES=(${Array.from(modules).join(" ")})`;
        await $`sudo tee /etc/mkinitcpio.conf`.stdinText(lines.join("\n"));
        return;
      }
    }
  }
  /**
   * run # mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
   * (make sure you have the linux-headers package installed first)
   */
  async function mkinitcpio() {
    await $`sudo mkinitcpio -P`;
  }

  /**
   * add a new line to /etc/modprobe.d/nvidia.conf (make it if it does not exist)
   * and add the line options nvidia-drm modeset=1
   */
  async function addNvidiaDrmModesetToModprobe() {
    const conf = "/etc/modprobe.d/nvidia.conf";
    if (!existsSync(conf)) {
      await $`sudo touch ${conf}`;
    }

    const text = await Deno.readTextFile(conf);
    const lines = text !== "" ? text.split("\n") : [];
    const optionLine = lines.findIndex((line) => line.startsWith("options"));
    if (optionLine === -1) {
      $.log("options line not found, creating new one");
      lines.push("options nvidia-drm modeset=1");
    } else if (lines[optionLine].includes("nvidia-drm modeset=1")) {
      $.log("nvidia-drm modeset=1 already exists");
      return;
    }
    lines[optionLine] += " nvidia-drm modeset=1 fbdev=1";
    await $`sudo tee ${conf}`.stdinText(lines.join("\n"));
  }

  await addNvidiaDrmModeset();
  await addNvidiaModules();
  await mkinitcpio();
  await addNvidiaDrmModesetToModprobe();
}

if (import.meta.main) {
  await setupNvidia();
}
