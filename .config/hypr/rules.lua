---@type HL.WindowRuleSpec[]
local window_rules = {
  -- Generic rules
  {
    match = { xwayland = false, float = true },
    center = true,
  },
  -- pcmanfm
  {
    match = { class = "pcmanfm", title = "設定" },
    float = true,
  },
  {
    match = { class = "pcmanfm", title = "リムーバブルメディアが接続されました" },
    float = true,
  },
  -- 1password
  {
    match = { class = "1Password" },
    float = true,
  },
  {
    match = { class = "1Password", float = true },
    center = true,
  },
  {
    match = { class = "1Password", title = "クイックアクセス — 1Password", float = true },
    no_anim = true,
  },
  -- Unity
  {
    match = { class = "Unity", title = "Starting Unity\\.\\.\\." },
    maximize = true,
  },
  {
    match = { class = "Unity", title = ".* - Unity \\d+\\.\\d+\\.\\d+", float = false },
    maximize = true,
  },
  {
    match = { class = "Unity", title = "negative:Unity", float = true },
    center = true,
  },
  -- Steam
  {
    match = { class = "steam", title = "^(Steam Settings)$" },
    float = true,
  },
  {
    match = { class = "steam", title = "negative:^$", float = true },
    center = true,
  },
  -- Network Manager
  {
    match = { class = "nm-connection-editor" },
    float = true,
  },
  -- fcitx5
  {
    match = { class = "org\\.fcitx\\.fcitx5-config-qt" },
    float = true,
  },
  -- satty
  {
    match = { class = "org\\.satty\\.satty" },
    float = true,
  },
  -- Discord
  {
    match = { class = "^(FFPWA-.*)$", title = "^(Discord)$" },
    workspace = "special",
  },
  {
    match = { class = "webcord", float = true },
    center = true,
  },
  -- pavucontrol
  {
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
  },
}

--- @type HL.LayerRuleSpec[]
local layer_rules = {
  {
    match = { namespace = "ags-power-menu" },
    blur = true,
  },
}

for _, rule in ipairs(window_rules) do
  hl.window_rule(rule)
end

for _, rule in ipairs(layer_rules) do
  hl.layer_rule(rule)
end
