local job = require "plenary.job"
local preview = {}

--- @type Job
preview.last_job = nil

local on_exit = function(cb)
  return function(j, exit_code)
    local r = j:result()
    cb(r, exit_code)
  end
end

--- preview
---@param entry GitOrdinaryChangedEntry|GitRenamedOrCopiedEntry|GitUnmergedEntry
preview.staged = function(entry, cb)
  if preview.last_job ~= nil and not preview.last_job.is_shutdown then
    preview.last_job:shutdown()
  end

  local diff = job:new {
    command = "git",
    args = { "diff", "--staged", entry.path },
    -- command = "sleep",
    -- args = { "3" },
    cwd = vim.loop.cwd(),
    env = {},
    on_exit = on_exit(cb),
  }
  diff:start()
  preview.last_job = diff
end

return preview
