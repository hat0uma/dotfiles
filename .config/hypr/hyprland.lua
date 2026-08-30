-- Hyprland 0.55+ Lua config.
-- The legacy .conf files are kept next to this file as a rollback path.

require("envs")
require("monitor")

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  input = {
    kb_layout = "jp",
    kb_variant = "",
    kb_model = "",
    kb_options = "ctrl:nocaps",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
  cursor = {
    no_hardware_cursors = 1,
  },
  general = {
    gaps_in = 4,
    gaps_out = 4,
    border_size = 2,
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    layout = "dwindle",
  },
  decoration = {
    rounding = 10,
    dim_special = 0.3,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      special = false,
    },
  },
  animations = {
    enabled = true,
  },
  dwindle = {
    -- pseudotile = true,
    preserve_split = true,
    special_scale_factor = 0.96,
  },
  master = {
    new_status = "master",
  },
  misc = {
    focus_on_activate = true,
    disable_hyprland_logo = true,
  },
  debug = {
    disable_logs = false,
    enable_stdout_logs = true,
  },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

require("rules")
require("binds")
require("autostart")
