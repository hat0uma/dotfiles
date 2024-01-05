#!/usr/bin/env -S deno run -A --unstable

import $ from "https://deno.land/x/dax@0.35.0/mod.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { setupNvidia } from "./setup_nvidia.ts";
import { linkScripts } from "./setup_link.ts";

const packages = {
  base: [
    "acpi",
    "brightnessctl",
    "eww-hyprland-tray",
    "gobject-introspection",
    "hyprland-git",
    "network-manager-applet",
    "otf-font-awesome",
    "papirus-icon-theme",
    "pop-icon-theme",
    "qt5-wayland",
    "qt6-wayland",
    "swaybg",
    "ttf-twemoji-color",
    "xdg-desktop-portal-hyprland",
  ],
  dm: [
    "greetd",
    "greetd-tuigreet",
  ],
  ime: [
    "fcitx5",
    "fcitx5-configtool",
    "fcitx5-gtk",
    "fcitx5-mozc",
    "fcitx5-qt",
  ],
  theme: [
    "catppuccin-cursors-frappe",
    "catppuccin-fcitx5-git",
    "catppuccin-gtk-theme-frappe",
    "kvantum-theme-catppuccin-git",
  ],
  other: [
    "1password-beta",
    "easyeffects",
    "file-roller",
    "firefox",
    "foot",
    "grim",
    "kvantum",
    "libnotify",
    "mpv",
    "neofetch",
    "pcmanfm-qt",
    "slurp",
    // "steam",
    "swappy",
    "swaylock",
    "swaync",
    "visual-studio-code-insiders-bin",
    "webcord-bin",
    "wezterm-git",
    "wl-clipboard",
    "wofi",
    "mesa-utils",
  ],
  nvidia: [
    "linux-headers",
    "nvidia-dkms",
    "nvidia-prime",
    "nvidia-settings",
    "nvidia-utils",
    "lib32-nvidia-utils",
  ],
};

// deno-fmt-ignore
const GREETD_CONFIG =
`[terminal]
vt = 1
[default_session]
command = "tuigreet --time --time-format='%Y/%m/%d %H:%M' --remember --remember-session --asterisks --cmd='zsh --login -c Hyprland'"
`;

async function setupDM() {
  await $`sudo systemctl enable --now greetd`;
  await $`sudo tee /etc/greetd/config.toml`.stdinText(GREETD_CONFIG);
}

async function modifyDesktopFiles() {
  async function addChromiumFlags(
    srcDesktopFile: string,
    dstDesktopFile: string,
  ) {
    const content =
      await $`sed "s/^\\(Exec=[^ ]\\+\\)/\\1 --ozone-platform=wayland --enable-wayland-ime/g" ${srcDesktopFile}`.text();
    await $`tee ${dstDesktopFile}`.stdinText(content);
  }
  const localAppDir = Deno.env.get("HOME") + "/.local/share/applications";
  await Promise.all([
    await addChromiumFlags(
      "/usr/share/applications/visual-studio-code-insiders.desktop",
      localAppDir + "/visual-studio-code-insiders.desktop",
    ),
    await addChromiumFlags(
      "/usr/share/applications/webcord.desktop",
      localAppDir + "/webcord.desktop",
    ),
  ]);
}

const installPackages = async (packages: string[]) => await $`yay -S --needed --noconfirm ${packages}`;

/**
 * Main
 */
await new Command()
  .option("--disable-nvidia", "Disable Nvidia Setup", { default: false })
  .action(async (opts) => {
    $.setPrintCommand(true);
    await installPackages(packages.base);
    await installPackages(packages.dm);
    await installPackages(packages.ime);
    await installPackages(packages.other);
    await installPackages(packages.theme);
    await modifyDesktopFiles();
    await setupDM();
    await linkScripts();
    if (!opts.disableNvidia) {
      await installPackages(packages.nvidia);
      await setupNvidia();
    }
  })
  .parse(Deno.args);
