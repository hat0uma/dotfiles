local wezterm = require "wezterm"
local act = wezterm.action
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local home = is_windows and os.getenv "UserProfile" or os.getenv "HOME"
local dotfiles = home .. "/dotfiles"

local pwsh = { label = "pwsh", args = { "pwsh", "-NoLogo" } }
local zsh = { label = "zsh", args = { "zsh", "-l" } }
local neovim = { label = "neovim", args = { "nvim" } }
local neovim_terminal = {
  label = "neovim-terminal",
  args = is_windows and { dotfiles .. "/win/nvim_terminal.cmd" } or { dotfiles .. "/scripts/nvim_terminal.sh" },
}
local launch_menu = {
  is_windows and pwsh or zsh,
  neovim_terminal,
  neovim,
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local bg = tab.is_active and "blue" or "navy"
  local title = string.format(" %d ", tab.tab_index + 1)
  return {
    { Background = { Color = bg } },
    { Text = title },
  }
end)

return {
  launch_menu = launch_menu,
  audible_bell = "Disabled",
  use_ime = true,
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = false,
  window_decorations = "RESIZE",
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  color_scheme = "Catppuccin Frappe",
  -- exit_behavior = "Hold",
  -- xim_im_name = "fcitx",
  font = wezterm.font_with_fallback { "Sarasa Term J Nerd Font", "Twemoji Mozilla" },
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = is_windows and pwsh.args or zsh.args,
  leader = { key = "e", mods = "ALT" },
  keys = {
    { key = "q", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },
    { key = "0", mods = "LEADER", action = act.QuitApplication },
    { key = "Enter", mods = "LEADER", action = act.ShowLauncher },
    { key = "f", mods = "LEADER", action = act.ToggleFullScreen },
    { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
    { key = "\\", mods = "LEADER", action = act.SplitHorizontal {} },
    { key = "-", mods = "LEADER", action = act.SplitVertical {} },
    { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
    { key = "h", mods = "LEADER", action = act { ActivatePaneDirection = "Left" } },
    { key = "j", mods = "LEADER", action = act { ActivatePaneDirection = "Down" } },
    { key = "k", mods = "LEADER", action = act { ActivatePaneDirection = "Up" } },
    { key = "l", mods = "LEADER", action = act { ActivatePaneDirection = "Right" } },
  },
}
