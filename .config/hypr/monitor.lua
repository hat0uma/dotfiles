--- Check monitor is external
---@param m HL.Monitor
---@return boolean
local function is_external_monitor(m)
  return m.name ~= "eDP-1" and m.name ~= "FALLBACK"
end
local function get_external_monitors()
  local monitors = hl.get_monitors()
  local externals = {} --- @type HL.Monitor[]
  for _, m in ipairs(monitors) do
    if is_external_monitor(m) then
      table.insert(externals, m)
    end
  end

  return externals
end

---@param m HL.Monitor
---@return number
local function monitor_scale(m)
  local long_edge = math.max(m.width, m.height)
  local short_edge = math.min(m.width, m.height)
  return long_edge >= 3840 and short_edge >= 2160 and 2 or 1
end

local function setup_monitor()
  local externals = get_external_monitors()

  if #externals > 0 then
    hl.monitor({ output = "eDP-1", disabled = true })
  else
    hl.monitor({
      output = "eDP-1",
      mode = "preferred",
      position = "auto",
      scale = 1,
      disabled = false,
    })
  end

  for _, m in ipairs(externals) do
    print(string.format("%s is hidpi monitor [%dx%d]", m.name, m.width, m.height))
    hl.monitor({
      output = m.name,
      mode = "preferred",
      position = "auto",
      scale = monitor_scale(m),
    })
  end

  hl.exec_cmd("ags quit; ags run")
end

hl.on(
  "monitor.added",
  --- @param m HL.Monitor
  function(m)
    print("[event] monitor.added: " .. m.name)
    if not is_external_monitor(m) then
      print(m.name .. " is not external monitor.")
      return
    end

    setup_monitor()
  end
)
hl.on(
  "monitor.removed",
  --- @param m HL.Monitor
  function(m)
    print("[event] monitor.removed: " .. m.name)
    if not is_external_monitor(m) then
      print(m.name .. " is not external monitor.")
      return
    end
    setup_monitor()
  end
)
hl.on("hyprland.start", function()
  print("[event] hyprland.start")
  setup_monitor()
end)

setup_monitor()
