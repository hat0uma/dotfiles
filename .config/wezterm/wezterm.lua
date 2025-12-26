local wezterm = require("wezterm") --- @type Wezterm
local act = wezterm.action
local config = wezterm.config_builder()
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
-- local home = is_windows and os.getenv("UserProfile") or os.getenv("HOME")
-- local dotfiles = home .. "/dotfiles"

--------------------------------------------------------------------------------
-- Launch Menu
--------------------------------------------------------------------------------
local pwsh = { label = "pwsh", args = { "pwsh", "-NoLogo" } } ---@type SpawnCommand
local zsh = { label = "zsh", args = { "zsh", "-l" } } ---@type SpawnCommand
local neovim = { label = "neovim", args = { "nvim" } } ---@type SpawnCommand
config.launch_menu = {
  is_windows and pwsh or zsh,
  neovim,
}
config.default_prog = is_windows and pwsh.args or zsh.args

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------
config.audible_bell = "Disabled"
-- config.exit_behavior = "Hold"

-- keybords
-- config.debug_key_events = true
-- config.xim_im_name = "fcitx"
config.use_ime = true
config.allow_win32_input_mode = false
config.enable_kitty_keyboard = false
config.enable_csi_u_key_encoding = true

--------------------------------------------------------------------------------
-- Stylings
--------------------------------------------------------------------------------

------------------------------------
-- Tab bars
------------------------------------
config.enable_tab_bar = true
-- config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.show_close_tab_button_in_tabs = false

------------------------------------
-- Window
------------------------------------
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
------------------------------------
-- Colors
------------------------------------
-- config.window_background_opacity = 0.85
-- config.win32_system_backdrop = "Acrylic"
local color_scheme = "Catppuccin Frappe"
config.color_scheme = color_scheme

local colors = wezterm.color.get_builtin_schemes()[color_scheme]
config.command_palette_fg_color = colors.background
config.command_palette_bg_color = colors.foreground

------------------------------------
-- Fonts
------------------------------------
config.font = wezterm.font_with_fallback({
  { family = "UDEV Gothic", weight = "Regular" },
  -- { family = "Sarasa Term J" },
  { family = "Symbols Nerd Font Mono" },
  { family = "Twemoji Mozilla" },
})
config.font_size = 11
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.allow_square_glyphs_to_overflow_width = "Always"

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
config.leader = {
  key = "t",
  mods = "CTRL",
  timeout_milliseconds = 5000,
}
config.keys = {
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
  {
    key = "E",
    mods = "LEADER",
    action = act.EmitEvent("trigger-neovim-with-ansi-scrollback"),
  },
}

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
  local item = {}
  if tab.is_active then
    table.insert(item, { Background = { Color = "#8caaee" } })
    table.insert(item, { Attribute = { Intensity = "Bold" } })
  elseif hover then
    table.insert(item, { Background = { Color = "#414559" } })
  else
    table.insert(item, { Background = { Color = "#292c3c" } })
  end

  local title = string.format(" %d ", tab.tab_index + 1)
  table.insert(item, { Text = title })
  return item
end)

wezterm.on(
  "trigger-neovim-with-scrollback",

  --- @param window Window
  --- @param pane Pane
  function(window, pane)
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
  end
)

wezterm.on(
  "trigger-neovim-with-ansi-scrollback",

  --- @param window Window
  --- @param pane Pane
  function(window, pane)
    -- Retrieve the current pane's text
    local text = pane:get_lines_as_escapes(pane:get_dimensions().scrollback_rows)

    -- Create a temporary file to pass to the pager
    local name = os.tmpname()
    local f = assert(io.open(name, "w+"))
    f:write(text)
    f:flush()
    f:close()

    -- Open a new window running less and tell it to open the file
    window:perform_action(
      act.SpawnCommandInNewTab({
        args = { "nvim", "-c", "DeansiEnable", name },
        domain = { DomainName = "local" },
      }),
      pane
    )

    -- Wait "enough" time for less to read the file before we remove it.
    -- The window creation and process spawn are asynchronous wrt. running
    -- this script and are not awaitable, so we just pick a number.
    --
    -- Note: We don't strictly need to remove this file, but it is nice
    -- to avoid cluttering up the temporary directory.
    wezterm.sleep_ms(1000)
    os.remove(name)
  end
)

local distro_cache = {} ---@type string[]
local function get_wsl_distro_name(guid)
  if distro_cache[guid] then
    -- wezterm.log_info("Use Cache Entry! GUID: " .. guid .. " -> Name: " .. distro_cache[guid])
    return distro_cache[guid]
  end

  local cmd = {
    "reg.exe",
    "query",
    "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\\" .. guid,
    "/v",
    "DistributionName",
  }

  local success, stdout = wezterm.run_child_process(cmd)

  if success then
    -- Output Example: "    DistributionName    REG_SZ    Ubuntu-20.04"
    local name = stdout:match("DistributionName%s+REG_SZ%s+([^\r\n]+)")
    if name then
      -- wezterm.log_info("New Cache Entry! GUID: " .. guid .. " -> Name: " .. name)
      distro_cache[guid] = name
      return name
    end
  end

  return guid
end

---@param proc LocalProcessInfo
---@return string?
local function get_wsl_distro_guid(proc)
  for i, arg in ipairs(proc.argv) do
    if arg == "--distro-id" and proc.argv[i + 1] then
      local guid = proc.argv[i + 1]
      return guid
    end
  end
end

wezterm.on("update-right-status", function(window, pane)
  local domain = pane:get_domain_name()
  local cmd = pane:get_foreground_process_name() or ""
  local proc = pane:get_foreground_process_info()

  local function insert_ssh_format(items, text)
    table.insert(items, { Background = { Color = "#764ABC" } })
    table.insert(items, { Foreground = { Color = "#ffffff" } })
    table.insert(items, { Text = string.format("  %s ", text) })
  end
  local function insert_wsl_format(items, text)
    table.insert(items, { Background = { Color = "#0078D4" } })
    table.insert(items, { Foreground = { Color = "#ffffff" } })
    table.insert(items, { Text = string.format("  %s ", text) })
  end

  local items = {} ---@type FormatItemSpec[]
  if cmd:lower():find("ssh") then
    insert_ssh_format(items, "SSH")
  elseif domain:lower():find("ssh") then
    insert_ssh_format(items, domain)
  elseif domain:lower():find("wsl") then
    insert_wsl_format(items, domain)
  elseif cmd:find("wslhost.exe") then
    local distro_id = proc and get_wsl_distro_guid(proc) or nil
    local distro_name = distro_id and get_wsl_distro_name(distro_id) or nil
    local display = distro_name and string.format("WSL:%s", distro_name) or "WSL"
    insert_wsl_format(items, display)
  else
  end

  if #items > 0 then
    window:set_right_status(wezterm.format(items))
  else
    window:set_right_status("")
  end
end)

return config
