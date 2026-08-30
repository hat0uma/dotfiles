hl.window_rule({
  match = { xwayland = false, float = true },
  center = true,
})

hl.window_rule({
  match = { class = "pcmanfm", title = "設定" },
  float = true,
})
hl.window_rule({
  match = { class = "pcmanfm", title = "リムーバブルメディアが接続されました" },
  float = true,
})

hl.window_rule({ match = { class = "1Password" }, float = true })
hl.window_rule({ match = { class = "1Password", float = true }, center = true })
hl.window_rule({
  match = { class = "1Password", title = "クイックアクセス — 1Password", float = true },
  no_anim = true,
})

hl.window_rule({
  match = { class = "Unity", title = "Starting Unity\\.\\.\\." },
  maximize = true,
})
hl.window_rule({
  match = { class = "Unity", title = ".* - Unity \\d+\\.\\d+\\.\\d+", float = false },
  maximize = true,
})
hl.window_rule({
  match = { class = "Unity", title = "negative:Unity", float = true },
  center = true,
})

hl.window_rule({
  match = { class = "steam", title = "^(Steam Settings)$" },
  float = true,
})
hl.window_rule({
  match = { class = "steam", title = "negative:^$", float = true },
  center = true,
})

hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "org\\.fcitx\\.fcitx5-config-qt" }, float = true })
hl.window_rule({
  match = { class = "^(FFPWA-.*)$", title = "^(Discord)$" },
  workspace = "special",
})
hl.window_rule({
  match = { class = "webcord", float = true },
  center = true,
})

hl.layer_rule({
  match = { namespace = "ags-power-menu" },
  blur = true,
})
