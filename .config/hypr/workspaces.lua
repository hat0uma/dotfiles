--- Pin fixed workspace ranges to monitors so the same physical monitor
--- always owns the same workspace numbers (e.g. monitor 1: workspaces 1-5,
--- monitor 2: workspaces 6-10). Workspace ids are used as-is everywhere
--- else (keybinds, bar) - this module only manages monitor affinity.
---
--- This is the only place that knows the monitor-to-block assignment.
--- The bar (.config/ags/widgets/Bar.tsx) derives its per-monitor placeholder
--- range from the ids it observes already pinned to each monitor, rather
--- than duplicating GROUP_SIZE/MONITOR_PRIORITY in a second process.

local M = {}

local GROUP_SIZE = 5

-- monitor name -> group number (1-based). Lower number = higher priority.
-- Monitors not listed here get the lowest still-free group number.
-- eDP-1 is omitted: monitor.lua always disables it while any external is
-- connected, so it never coexists with DP-2/HDMI-A-1.
local MONITOR_PRIORITY = {
  ["HDMI-A-1"] = 1,
  ["DP-2"] = 2,
}

--- @return table<string, integer>
local function compute_assignment()
  local monitors = hl.get_monitors()
  if #monitors <= 1 then
    return {}
  end

  table.sort(monitors, function(a, b)
    return a.id < b.id
  end)

  local assignment = {}
  local used = {}
  local unassigned = {}
  for _, m in ipairs(monitors) do
    local want = MONITOR_PRIORITY[m.name]
    if want and not used[want] then
      assignment[m.name] = want
      used[want] = true
    else
      table.insert(unassigned, m)
    end
  end

  local next_group = 1
  for _, m in ipairs(unassigned) do
    while used[next_group] do
      next_group = next_group + 1
    end
    assignment[m.name] = next_group
    used[next_group] = true
  end

  return assignment
end

--- Pin each monitor's workspace range to it, and move any workspace that
--- already exists in that range but currently lives elsewhere.
local function apply_assignment(assignment)
  for name, group in pairs(assignment) do
    local base = (group - 1) * GROUP_SIZE
    for i = 1, GROUP_SIZE do
      hl.workspace_rule({ workspace = tostring(base + i), monitor = name })
    end
  end

  for _, wsp in ipairs(hl.get_workspaces()) do
    if wsp.id > 0 then
      for name, group in pairs(assignment) do
        local base = (group - 1) * GROUP_SIZE
        if wsp.id > base and wsp.id <= base + GROUP_SIZE and (not wsp.monitor or wsp.monitor.name ~= name) then
          hl.dispatch(hl.dsp.workspace.move({ workspace = wsp.id, monitor = name }))
        end
      end
    end
  end
end

function M.on_topology_changed()
  -- Single monitor: no range restriction needed, everything already lives
  -- there.
  if #hl.get_monitors() <= 1 then
    return
  end

  apply_assignment(compute_assignment())
end

hl.on("monitor.added", M.on_topology_changed)
hl.on("monitor.removed", M.on_topology_changed)
hl.on("hyprland.start", M.on_topology_changed)

M.on_topology_changed()

return M
