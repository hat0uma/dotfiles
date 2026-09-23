--- Monitor-local workspace grouping.
---
--- Hyprland keeps a single flat global workspace id space. This module
--- groups that space into fixed-size blocks, one block per monitor, so
--- keybinds/bar can address workspaces by a "local" number (1..GROUP_SIZE)
--- that always looks the same on every monitor. With only one monitor
--- connected, grouping is dropped and local == global (flatten mode) so
--- workspaces beyond the group size stay reachable.
---
--- Keep GROUP_SIZE and MONITOR_PRIORITY in sync with the copies in
--- .config/ags/widgets/Bar.tsx (native Lua and AGS/GJS are separate
--- processes; there is no code sharing between them).

local M = {}

M.GROUP_SIZE = 5

-- monitor name -> group number (1-based). Lower number = higher priority.
-- Monitors not listed here get the lowest still-free group number.
-- eDP-1 is omitted: monitor.lua always disables it while any external is
-- connected, so it never coexists with DP-2/HDMI-A-1 and would only ever
-- waste a group slot if listed here.
M.MONITOR_PRIORITY = {
  ["DP-2"] = 1,
  ["HDMI-A-1"] = 2,
}

--- monitor name -> group number, only meaningful while multi-monitor.
local assignment = {}

--- @return boolean
function M.is_multi_monitor()
  return #hl.get_monitors() > 1
end

local function recompute_assignment()
  assignment = {}

  local monitors = hl.get_monitors()
  if #monitors <= 1 then
    return
  end

  table.sort(monitors, function(a, b)
    return a.id < b.id
  end)

  local used = {}
  local unassigned = {}
  for _, m in ipairs(monitors) do
    local want = M.MONITOR_PRIORITY[m.name]
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
end

--- @param name string
--- @return integer|nil
function M.group_for_monitor(name)
  return assignment[name]
end

--- Local (1..GROUP_SIZE) workspace number on a given monitor -> global id.
--- Returns the local id unchanged in single-monitor (flatten) mode.
--- Returns nil when the local id is out of range or the monitor has no
--- assigned group (no-op case for callers).
--- @param local_id integer
--- @param monitor_name string
--- @return integer|nil
function M.resolve_global(local_id, monitor_name)
  if local_id < 1 then
    return nil
  end

  if not M.is_multi_monitor() then
    -- flatten mode: no group ceiling, local id addresses the global id directly
    return local_id
  end

  if local_id > M.GROUP_SIZE then
    return nil
  end

  local group = assignment[monitor_name]
  if not group then
    return nil
  end
  return (group - 1) * M.GROUP_SIZE + local_id
end

--- Global workspace id -> local number within the given monitor's own
--- group. Returns the global id unchanged in single-monitor (flatten)
--- mode. Returns nil when the global id isn't in that monitor's range.
--- @param global_id integer
--- @param monitor_name string
--- @return integer|nil
function M.to_local(global_id, monitor_name)
  if not M.is_multi_monitor() then
    return global_id
  end

  local group = assignment[monitor_name]
  if not group then
    return nil
  end

  local base = (group - 1) * M.GROUP_SIZE
  if global_id <= base or global_id > base + M.GROUP_SIZE then
    return nil
  end
  return global_id - base
end

--- Re-home a monitor's owned workspace range onto it: declare affinity for
--- the whole range (creation-time backstop, never forces creation since
--- `persistent` is intentionally omitted), move any workspace that already
--- exists in that range but currently lives elsewhere, then renumber any
--- workspace already sitting on this monitor but outside its range into a
--- free slot within the range. That last step only matters for workspaces
--- whose id predates this grouping scheme (e.g. left over from before this
--- feature existed). If no slot is available, the workspace is retained as
--- an overflow workspace and remains selectable from the bar and scroll.
--- @param monitor_name string
local function reassign_group(monitor_name, occupied)
  local group = assignment[monitor_name]
  if not group then
    return
  end
  local base = (group - 1) * M.GROUP_SIZE

  for i = 1, M.GROUP_SIZE do
    hl.workspace_rule({ workspace = tostring(base + i), monitor = monitor_name })
  end

  for _, wsp in ipairs(hl.get_workspaces()) do
    if wsp.id > base and wsp.id <= base + M.GROUP_SIZE then
      occupied[wsp.id] = true
      if not wsp.monitor or wsp.monitor.name ~= monitor_name then
        hl.dispatch(hl.dsp.workspace.move({ workspace = wsp.id, monitor = monitor_name }))
      end
    end
  end
end

local function compact_group(monitor_name, occupied)
  local group = assignment[monitor_name]
  if not group then
    return
  end
  local base = (group - 1) * M.GROUP_SIZE
  for _, wsp in ipairs(hl.get_workspaces()) do
    local in_range = wsp.id > base and wsp.id <= base + M.GROUP_SIZE
    if not in_range and wsp.id > 0 and wsp.monitor and wsp.monitor.name == monitor_name then
      local slot
      for i = 1, M.GROUP_SIZE do
        if not occupied[base + i] then
          slot = base + i
          break
        end
      end
      if slot then
        occupied[slot] = true
        hl.dispatch(hl.dsp.workspace.change_id({ workspace = wsp.id, id = slot }))
      end
    end
  end
end

function M.on_topology_changed()
  recompute_assignment()

  if not M.is_multi_monitor() then
    -- Flatten mode. Hyprland's own default disconnect behavior already
    -- keeps existing workspace ids unchanged and reassigns them to the
    -- remaining monitor, so there's nothing to do here.
    return
  end

  -- First move every already-existing workspace into the group that owns its
  -- id. This must complete for all monitors before any workspace is renamed:
  -- otherwise a workspace such as 6 can be renamed by group 1 before group 2
  -- gets a chance to claim it.
  local occupied = {}
  for _, m in ipairs(hl.get_monitors()) do
    reassign_group(m.name, occupied)
  end

  -- Then compact legacy/out-of-range workspaces where a free id exists.
  -- If a group is full, the workspace keeps its id and remains visible via
  -- the bar/scroll overflow path instead of becoming unreachable.
  for _, m in ipairs(hl.get_monitors()) do
    compact_group(m.name, occupied)
  end
end

hl.on("monitor.added", M.on_topology_changed)
hl.on("monitor.removed", M.on_topology_changed)
hl.on("hyprland.start", M.on_topology_changed)

M.on_topology_changed()

return M
