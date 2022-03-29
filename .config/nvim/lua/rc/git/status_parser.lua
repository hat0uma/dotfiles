local parser = {}

local STATUS_CHARS = " MADRCU?"
local STATUS_PATTERNS = ("([STATUS_CHARS])([STATUS_CHARS]) (.*)"):gsub("STATUS_CHARS", STATUS_CHARS)

--- parse git status output
---@param out string[]
-- @return table
function parser.parse(out)
  if #out == 0 then
    return {}
  end

  -- parse branch info
  local branch_line = out[1]
  local branch, remote_branch = string.match(branch_line, "## (.*)%.%.%.(%S*)")
  local ahead_num = string.match(branch_line, "%[ahead (%d)%]") or 0
  local behind_num = string.match(branch_line, "%[behind (%d)%]") or 0

  local staged_changes = {}
  local unstaged_changes = {}
  local untracked_changes = {}

  -- parse changes
  for i = 2, #out, 1 do
    local staged, unstaged, file = string.match(out[i], STATUS_PATTERNS)
    if staged == "?" or unstaged == "?" then
      table.insert(untracked_changes, file)
    else
      if staged ~= " " then
        table.insert(staged_changes, { file = file, status = staged })
      end
      if unstaged ~= " " then
        table.insert(unstaged_changes, { file = file, status = unstaged })
      end
    end
  end
  local is_dirty = #staged_changes ~= 0 or #unstaged_changes ~= 0 or #untracked_changes ~= 0
  return {
    branch = branch or "",
    remote_branch = remote_branch or "",
    ahead_num = ahead_num,
    behind_num = behind_num,
    staged_changes = staged_changes,
    unstaged_changes = unstaged_changes,
    untracked_changes = untracked_changes,
    is_dirty = is_dirty,
  }
end

return parser
