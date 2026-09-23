// ウィンドウの class (と一部 title) → アイコン名の対応表
// アイコン名は icons/ 内のファイル名から .svg を除いたもの

type Rule = [RegExp, string]

// class 完全一致 (小文字化して比較)
const classRules: Rule[] = [
  [/^(kitty|alacritty|foot|footclient|ghostty|com\.mitchellh\.ghostty|org\.wezfurlong\.wezterm|wezterm)$/, "terminal"],
  [/^(firefox|zen|zen-browser|librewolf|floorp|chromium|google-chrome|brave-browser|vivaldi-stable)$/, "browser"],
  [/^(discord|vesktop|webcord|slack|org\.telegram\.desktop|telegramdesktop|element|signal)$/, "chat"],
  [/^(code|code-oss|vscodium|cursor|zed|dev\.zed\.zed|neovide|jetbrains-.*)$/, "code"],
  [/^(org\.gnome\.nautilus|thunar|pcmanfm|pcmanfm-qt|org\.kde\.dolphin|nemo)$/, "files"],
  [/^(spotify|feishin|com\.github\.th_ch\.youtube_music|rhythmbox|strawberry|io\.bassi\.amberol)$/, "music"],
  [/^(mpv|vlc|io\.github\.celluloid_player\.celluloid|org\.gnome\.showtime|org\.gnome\.totem)$/, "video"],
  [/^(imv|org\.gnome\.loupe|eog|feh|swayimg|qimgv)$/, "image"],
  [/^(obsidian|logseq|notion-app|joplin)$/, "notes"],
  [/^(thunderbird|betterbird|geary|org\.gnome\.evolution)$/, "mail"],
  [/^(chatgpt|chatgpt-desktop|claude|claude-desktop)$/, "ai"],
  [/^(org\.pulseaudio\.pavucontrol|pavucontrol|nwg-look|blueman-manager|nm-connection-editor|gnome-control-center)$/, "settings"],
  [/^(steam|steam_app_\d+|lutris|heroic|com\.heroicgameslauncher\.hgl|org\.prismlauncher\.prismlauncher)$/, "game"],
  [/^(org\.pwmt\.zathura|zathura|org\.kde\.okular|okular|org\.gnome\.papers|evince|libreoffice-writer)$/, "document"],
  [/^(libreoffice-calc)$/, "sheet"],
  [/^(gimp|gimp-.*|krita|org\.inkscape\.inkscape|inkscape|pinta)$/, "paint"],
  [/^(org\.keepassxc\.keepassxc|keepassxc|bitwarden)$/, "key"],
  [/^(io\.missioncenter\.missioncenter|gnome-system-monitor|net\.nokyan\.resources)$/, "monitor"],
  [/^(org\.qbittorrent\.qbittorrent|qbittorrent|transmission-gtk|de\.haeckerfelix\.fragments)$/, "download"],
  [/^(zoom|teams-for-linux)$/, "camera"],
  [/^(com\.obsproject\.studio|obs)$/, "record"],
]

// ターミナル内で動く TUI アプリ用 (title 先頭一致)
// 例: kitty で btop を開くと class は kitty のままなので title で判定
const terminalTitleRules: Rule[] = [
  [/^(n?vim?)\b/, "code"],
  [/^(btop|htop|top)\b/, "monitor"],
  [/^(yazi|lf|ranger)\b/, "files"],
]

const TERMINAL = classRules[0][0]

// アイコン → 色グループ (CSS クラス名になる)
const groups: Record<string, string> = {
  terminal: "dev", code: "dev",
  browser: "web", download: "web",
  chat: "comm", mail: "comm", camera: "comm",
  music: "media", video: "media", image: "media", record: "media", game: "media",
  document: "doc", notes: "doc", sheet: "doc", paint: "doc",
  ai: "ai",
  files: "system", settings: "system", monitor: "system", key: "system",
  window: "other",
}

function resolve(cls: string, title: string): string {
  const c = cls.toLowerCase()
  if (TERMINAL.test(c)) {
    for (const [re, icon] of terminalTitleRules)
      if (re.test(title.toLowerCase())) return icon
  }
  for (const [re, icon] of classRules) if (re.test(c)) return icon
  return "window"
}

export function appIcon(cls: string, title = "") {
  const name = resolve(cls, title)
  return { icon: `ws-${name}-symbolic`, group: groups[name] }
}
