local display = {}

local STATUS_TBL = {
  M = "modified",
  A = "added",
  D = "deleted",
  R = "renamed",
  C = "copied",
  U = "unmerged",
  ["?"] = "untracked",
  ["!"] = "ignored",
  ["."] = "",
}

--- display
---@param entry GitOrdinaryChangedEntry
function display.staged_ordinary_changes(entry)
  local s = entry.status.staged
  return string.format("%s: %s", STATUS_TBL[s], entry.path)
end

--- display
---@param entry GitOrdinaryChangedEntry
function display.unstaged_ordinary_changes(entry)
  local s = entry.status.unstaged
  return string.format("%s: %s", STATUS_TBL[s], entry.path)
end

return display
