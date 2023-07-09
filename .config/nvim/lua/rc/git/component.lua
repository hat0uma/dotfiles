local status = require "rc.git.ops.status"
local GitStatus = status.GitStatus

local M = {
  config = {
    cache_duration = 5000,
  },
  cache = GitStatus.new(),
  last_update = 0,
  job = nil, --- @type SystemObj?
}

--- update cache
---@param sts GitStatus?
local function update_cache(sts)
  if sts then
    M.cache = sts
  end
end

--- get cached status
---@return GitStatus
function M.get_status_cached()
  local now = vim.loop.now()
  if (now - M.last_update) < M.config.cache_duration then
    -- on cache time
  elseif M.job and not M.job:is_closing() then
    print "git status is running"
  else
    M.last_update = now
    M.job = status.run({}, update_cache)
  end
  return M.cache
end

return M
