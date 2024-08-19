local wezterm = require("wezterm")
local act = wezterm.action
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local home = is_windows and os.getenv("UserProfile") or os.getenv("HOME")
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
  local bg
  if tab.is_active then
    bg = "#8caaee"
  elseif hover then
    bg = "#414559"
  else
    bg = "#292c3c"
  end

  local title = string.format(" %d ", tab.tab_index + 1)
  return {
    { Background = { Color = bg } },
    { Text = title },
  }
end)

wezterm.on("trigger-neovim-with-scrollback", function(window, pane)
  -- Retrieve the text from the pane
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  -- Create a temporary file to pass to neovim
  local name = os.tmpname()
  local f = assert(io.open(name, "w+"))
  f:write(text)
  f:flush()
  f:close()

  window:perform_action(
    act.SpawnCommandInNewTab({
      args = { "nvim", name },
      domain = { DomainName = "local" },
    }),
    pane
  )

  -- Wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous wrt. running
  -- this script and are not awaitable, so we just pick a number.
  wezterm.sleep_ms(1000)
  os.remove(name)
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
  -- debug_key_events = true,
  -- exit_behavior = "Hold",
  -- xim_im_name = "fcitx",
  font = wezterm.font_with_fallback({ "UDEV Gothic NF", "Twemoji Mozilla" }),
  font_size = 11,
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  default_prog = is_windows and pwsh.args or zsh.args,
  leader = {
    key = "t",
    mods = "CTRL",
    timeout_milliseconds = 5000,
  },
  keys = {
    { key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
    { key = "0", mods = "LEADER", action = act.QuitApplication },
    { key = "Enter", mods = "LEADER", action = act.ShowLauncher },
    { key = "f", mods = "LEADER", action = act.ToggleFullScreen },
    { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
    { key = "\\", mods = "LEADER", action = act.SplitHorizontal({}) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({}) },
    { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
    { key = "h", mods = "LEADER", action = act({ ActivatePaneDirection = "Left" }) },
    { key = "j", mods = "LEADER", action = act({ ActivatePaneDirection = "Down" }) },
    { key = "k", mods = "LEADER", action = act({ ActivatePaneDirection = "Up" }) },
    { key = "l", mods = "LEADER", action = act({ ActivatePaneDirection = "Right" }) },
    {
      key = "e",
      mods = "LEADER",
      action = act.EmitEvent("trigger-neovim-with-scrollback"),
    },
  },
}
