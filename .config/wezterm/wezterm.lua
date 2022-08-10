local wezterm = require "wezterm"

local shell = { "nvim", "-c", "lua require'rc.terminal'.show()" }

return {
  use_ime = true,
  -- xim_im_name = "fcitx",
  font = wezterm.font "Sarasa Term J Nerd Font",
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = shell,
  color_scheme = "Afterglow",
}
