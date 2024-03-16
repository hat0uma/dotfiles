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
    "xdg-desktop-portal-hyprland-git",
  ],
  dm: [
    "greetd",
    "greetd-tuigreet",
    "gnome-keyring",
    "seahorse",
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
    "file-roller",
    "firefox",
    "foot",
    "grim",
    "kvantum",
    "libnotify",
    "neofetch",
    "pcmanfm-qt",
    "slurp",
    // "steam",
    "swappy",
    "swaylock",
    "swaync",
    "visual-studio-code-insiders-bin",
    // "webcord-git",
    "firefox-pwa-bin",
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
    "nvtop",
    "lib32-nvidia-utils",
    "moonlight-qt-bin",
  ],
  yubikey: [
    "pam-u2f",
    "yubikey-manager",
    "yubikey-manager-qt",
  ],
  media: [
    "calf",
    "lsp-plugins-lv2",
    "zam-plugins-lv2",
    "mda.lv2",
    "yelp",
    "ardour",
    "easyeffects",
    "mpv",
    "youtube-music-bin",
  ],
};

// deno-fmt-ignore
const GREETD_CONFIG =
`[terminal]
vt = 1
[default_session]
command = "tuigreet --time --time-format='%Y/%m/%d %H:%M' --remember --remember-session --asterisks --cmd='zsh --login -c Hyprland'"
`;

// deno-fmt-ignore
const GREETD_PAMCONFIG =
`#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
`

async function setupDM() {
  await $`sudo systemctl enable --now greetd`;
  await $`systemctl enable --user  --now gnome-keyring-daemon`;
  await $`sudo tee /etc/greetd/config.toml`.stdinText(GREETD_CONFIG);
  await $`sudo tee /etc/pam.d/greetd`.stdinText(GREETD_PAMCONFIG);

  // Automatically change keyring password with user password
  const text = await Deno.readTextFile("/etc/pam.d/passwd");
  const lines = text.split("\n");
  const pamGnomeKeyring = lines.findIndex((line) => line.includes("pam_gnome_keyring.so"));
  if (pamGnomeKeyring === -1) {
    $.log("pam_gnome_keyring.so not found, adding");
    lines.push("password    optional    pam_gnome_keyring.so");
  } else {
    $.log("pam_gnome_keyring.so already exists");
  }
  await $`sudo tee /etc/pam.d/passwd`.stdinText(lines.join("\n"));
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

async function setupYubikey() {
  await $`sudo systemctl enable --now pcscd`;
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
    await installPackages(packages.yubikey);
    await installPackages(packages.media);
    await modifyDesktopFiles();
    await setupDM();
    await linkScripts();
    await setupYubikey();
    if (!opts.disableNvidia) {
      await installPackages(packages.nvidia);
      await setupNvidia();
    }
  })
  .parse(Deno.args);
