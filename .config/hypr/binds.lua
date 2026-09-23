local mod = "SUPER"

-- Observe both Super keys without consuming their normal shortcuts.
for _, key in ipairs({ { "Super_L", "left" }, { "Super_R", "right" } }) do
  for _, action in ipairs({ "down", "up" }) do
    hl.bind(key[1], function()
      -- Compositor CPU time is monotonic across config reloads. Include it so
      -- asynchronously launched requests cannot restore stale key state.
      hl.exec_cmd(string.format("ags request workspace-numbers %s %s %.9f", key[2], action, os.clock()))
    end, {
      release = action == "up",
      ignore_mods = true,
      non_consuming = true,
      transparent = true,
      submap_universal = true,
      locked = true,
    })
  end
end

local function toggle_file_manager()
  local special = hl.get_active_special_workspace()
  -- if special.config_name
  if special and special.name == "special:file-manager" then
    hl.dispatch(hl.dsp.workspace.toggle_special("file-manager"))
    return
  end

  local fm = { class = "nemo", cmd = "nemo" }
  local fm_exists = false
  local wins = hl.get_workspace_windows("special:file-manager")
  for _, win in ipairs(wins) do
    if win.class == fm.class then
      fm_exists = true
    end
  end

  hl.dispatch(hl.dsp.workspace.toggle_special("file-manager"))
  if not fm_exists then
    hl.exec_cmd(fm.cmd)
  end
end

local binds = {
  { lhs = "Escape", rhs = hl.dsp.exit() },

  { lhs = "Return", rhs = "footclient" },
  { lhs = "SHIFT + Q", rhs = hl.dsp.window.close() },
  { lhs = "F2", rhs = "google-chrome-stable" },
  { lhs = "D", rhs = "wofi --show drun" },
  { lhs = "SHIFT + D", rhs = "wofi --show run" },
  { lhs = "O", rhs = "1password --quick-access" },
  { lhs = "N", rhs = "ags request toggle-notifications" },
  { lhs = "E", rhs = toggle_file_manager },

  { lhs = "P", rhs = hl.dsp.window.pseudo() },
  { lhs = "F", rhs = hl.dsp.window.fullscreen({ mode = "fullscreen" }) },
  { lhs = "M", rhs = hl.dsp.window.fullscreen({ mode = "maximized" }) },
  { lhs = "V", rhs = hl.dsp.window.float() },
  { lhs = "S", rhs = hl.dsp.layout("togglesplit") },
  { lhs = "G", rhs = hl.dsp.group.toggle() },
  { lhs = "C", rhs = hl.dsp.window.center() },
  { lhs = "SHIFT + N", rhs = hl.dsp.group.next() },
  { lhs = "SHIFT + P", rhs = hl.dsp.group.prev() },

  { mod = false, lhs = "Print", rhs = "ags request toggle-screenshot" },
  { lhs = "Print", rhs = "screenshot full" },
  { lhs = "SHIFT + Print", rhs = "screenshot region" },

  { lhs = "H", rhs = hl.dsp.focus({ direction = "left" }) },
  { lhs = "L", rhs = hl.dsp.focus({ direction = "right" }) },
  { lhs = "K", rhs = hl.dsp.focus({ direction = "up" }) },
  { lhs = "J", rhs = hl.dsp.focus({ direction = "down" }) },

  { lhs = "SHIFT + H", rhs = hl.dsp.window.move({ direction = "left" }) },
  { lhs = "SHIFT + L", rhs = hl.dsp.window.move({ direction = "right" }) },
  { lhs = "SHIFT + K", rhs = hl.dsp.window.move({ direction = "up" }) },
  { lhs = "SHIFT + J", rhs = hl.dsp.window.move({ direction = "down" }) },

  {
    lhs = "RIGHT",
    rhs = hl.dsp.window.resize({ x = 10, y = 0, relative = true }),
    repeating = true,
  },
  {
    lhs = "LEFT",
    rhs = hl.dsp.window.resize({ x = -10, y = 0, relative = true }),
    repeating = true,
  },
  {
    lhs = "UP",
    rhs = hl.dsp.window.resize({ x = 0, y = -10, relative = true }),
    repeating = true,
  },
  {
    lhs = "DOWN",
    rhs = hl.dsp.window.resize({ x = 0, y = 10, relative = true }),
    repeating = true,
  },

  { lhs = "0", rhs = hl.dsp.workspace.toggle_special("") },
  { lhs = "SHIFT + 0", rhs = hl.dsp.window.move({ workspace = 10 }) },

  { lhs = "mouse_down", rhs = hl.dsp.focus({ workspace = "e+1" }) },
  { lhs = "mouse_up", rhs = hl.dsp.focus({ workspace = "e-1" }) },

  { lhs = "mouse:272", rhs = hl.dsp.window.drag(), mouse = true },
  { lhs = "mouse:273", rhs = hl.dsp.window.resize(), mouse = true },

  {
    lhs = "SHIFT + E",
    rhs = function()
      hl.exec_cmd("ags request toggle-power")
      hl.dispatch(hl.dsp.submap("powermenu"))
    end,
  },
}

for i = 1, 9 do
  table.insert(binds, { lhs = tostring(i), rhs = hl.dsp.focus({ workspace = i }) })
  table.insert(binds, { lhs = "SHIFT + " .. i, rhs = hl.dsp.window.move({ workspace = i }) })
end

local submaps = {
  powermenu = {
    { mod = false, lhs = "SHIFT + S", rhs = "systemctl poweroff", repeating = true },
    { mod = false, lhs = "SHIFT + R", rhs = "systemctl reboot", repeating = true },
    { mod = false, lhs = "SHIFT + Z", rhs = "systemctl suspend", repeating = true },
    { mod = false, lhs = "SHIFT + L", rhs = "swaylock -f -c 000000", repeating = true },
    { mod = false, lhs = "SHIFT + Q", rhs = hl.dsp.exit(), repeating = true },
    {
      mod = false,
      lhs = "escape",
      rhs = function()
        hl.exec_cmd("ags request close-power")
        hl.dispatch(hl.dsp.submap("reset"))
      end,
    },
  },
}

--- Bind
---@param opts {
---  mod?: boolean,
---  lhs: string,
---  rhs: HL.Dispatcher | function | string,
---  repeating?: boolean,
---  mouse?: boolean,
--- }
local function bind(opts)
  local use_mod = opts.mod ~= false
  local lhs = use_mod and mod .. " + " .. opts.lhs or opts.lhs

  local rhs = opts.rhs
  if type(rhs) == "string" then
    rhs = hl.dsp.exec_cmd(rhs)
  end

  hl.bind(lhs, rhs, {
    repeating = opts.repeating,
    mouse = opts.mouse,
  })
end

for _, opts in ipairs(binds) do
  bind(opts)
end

for name, submap in pairs(submaps) do
  hl.define_submap(name, function()
    for _, opts in ipairs(submap) do
      bind(opts)
    end
  end)
end
