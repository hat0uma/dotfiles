local job = require "plenary.job"
local parser = require "rc.git.parser"
local GitStatus = parser.GitStatus

local M = {}
M.config = {
  status_refresh_interval = 3000,
}
M.cache = GitStatus.new()
M.internal = {
  last_job = nil,
  on_cooldown = false,
}

--- update status cache(on exit status)
---@param j Job
---@param exit_code number
function M.update_status_cache(j, exit_code)
  if exit_code ~= 0 then
    print "git status failed"
    return
  end
  local out = j:result()
  M.cache = parser.parse_status_v2(out)
end

--- make git status job
---@param opts table
---@return Job
local function make_git_status_job(opts)
  opts = vim.tbl_extend("keep", opts or {}, { env = {}, cwd = vim.loop.cwd(), on_exit = nil })
  return job:new {
    command = "git",
    args = { "status", "--porcelain=v2", "--branch" },
    cwd = opts.cwd,
    env = opts.env,
    on_exit = opts.on_exit,
  }
end

--- get cached status
---@param cwd string
---@return GitStatus
function M.get_status_cached(cwd)
  if M.internal.on_cooldown then
    -- do nothing
  elseif M.internal.last_job ~= nil and not M.internal.last_job.is_shutdown then
    print "git status is running"
  else
    M.internal.last_job = make_git_status_job { cwd = cwd, on_exit = M.update_status_cache }
    M.internal.last_job:start()
    M.internal.on_cooldown = true
    vim.defer_fn(function()
      M.internal.on_cooldown = false
    end, M.config.status_refresh_interval)
  end
  return M.cache
end

return M
