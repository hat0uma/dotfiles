local wezterm = require "wezterm"
local act = wezterm.action

local terminal_on_neovim = {}
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  terminal_on_neovim = { os.getenv "UserProfile" .. "/dotfiles/win/nvim_terminal.cmd" }
else
  terminal_on_neovim = { os.getenv "HOME" .. "/dotfiles/scripts/nvim_terminal.sh" }
end

local launch_menu = {}
table.insert(launch_menu, { label = "neovim", args = { "nvim" } })
table.insert(launch_menu, { label = "neovim-terminal", args = terminal_on_neovim })
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  table.insert(launch_menu, { label = "pwsh", args = { "pwsh", "-NoLogo" } })
else
  table.insert(launch_menu, { label = "zsh", args = { "zsh", "-l" } })
end

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
  use_ime = true,
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = false,
  window_decorations = "NONE",
  color_scheme = "Afterglow",
  -- exit_behavior = "Hold",
  -- xim_im_name = "fcitx",
  font = wezterm.font_with_fallback { "Sarasa Term J Nerd Font", "Twemoji Mozilla" },
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = terminal_on_neovim,
  keys = {
    { key = "q", mods = "ALT", action = act.CloseCurrentPane { confirm = false } },
    { key = "0", mods = "ALT", action = act.QuitApplication },
    { key = "Enter", mods = "ALT", action = wezterm.action.ShowLauncher },
    { key = "f", mods = "ALT", action = wezterm.action.ToggleFullScreen },
    { key = "1", mods = "ALT", action = act.ActivateTab(0) },
    { key = "2", mods = "ALT", action = act.ActivateTab(1) },
    { key = "3", mods = "ALT", action = act.ActivateTab(2) },
    { key = "4", mods = "ALT", action = act.ActivateTab(3) },
  },
}
