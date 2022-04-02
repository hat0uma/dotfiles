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
---@param entry GitOrdinaryChangedEntry|GitRenamedOrCopiedEntry|GitUnmergedEntry
function display.staged_changes(entry)
  local s = entry.status.staged
  return string.format("%s: %s", STATUS_TBL[s], entry.path)
end

--- display
---@param entry GitOrdinaryChangedEntry|GitRenamedOrCopiedEntry|GitUnmergedEntry
function display.unstaged_changes(entry)
  local s = entry.status.unstaged
  return string.format("%s: %s", STATUS_TBL[s], entry.path)
end

--- display
---@param entry GitIgnoredEntry
function display.ignored(entry)
  return string.format("%s", entry.path)
end

--- display
---@param entry GitUntrackedEntry
function display.untracked(entry)
  return string.format("%s", entry.path)
end

return display
