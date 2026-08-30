--- Check monitoe is external
---@param m HL.Monitor
---@return boolean
local function is_external_monitor(m)
  return m.name ~= "eDP-1" and m.name ~= "FALLBACK"
end
local function get_external_monitor_names()
  local monitors = hl.get_monitors()
  local externals = {} --- @type string[]
  for _, m in ipairs(monitors) do
    if is_external_monitor(m) then
      table.insert(externals, m.name)
    end
  end

  return externals
end

local function setup_monitor()
  if #get_external_monitor_names() > 0 then
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

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
})
