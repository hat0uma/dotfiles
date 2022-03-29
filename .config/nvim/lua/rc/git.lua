local a = require "plenary.async"
local async = a.async
local await = a.await
local job = require "plenary.job"
local log = require "plenary.log"
local autil = require "plenary.async.util"

-- test
local opts = {
  status_refresh_interval = 3000,
}
local cache = {}
cache.staged_changes = {}
cache.unstaged_changes = {}
cache.untracked_changes = {}
cache.reset = function()
  cache.staged_changes = {}
  cache.unstaged_changes = {}
  cache.untracked_changes = {}
end
cache.is_dirty = function()
  return #cache.staged_changes ~= 0 or #cache.unstaged_changes ~= 0 or #cache.untracked_changes ~= 0
end

local state = {}
state.last_job = nil
state.on_cooldown = false

local function update_status_cache(out)
  cache.reset()
  if #out == 0 then
    return
  end
  -- parse branch info
  local branch_line = out[1]
  local branch, remote_branch = string.match(branch_line, "## (.*)%.%.%.(%S*)")
  local ahead_num = string.match(branch_line, "%[ahead (%d)%]") or 0
  local behind_num = string.match(branch_line, "%[behind (%d)%]") or 0
  -- parse changes
  local STATUS_CHARS = " MADRCU?"
  local STATUS_PATTERNS = ("([STATUS_CHARS])([STATUS_CHARS]) (.*)"):gsub("STATUS_CHARS", STATUS_CHARS)
  for i = 2, #out, 1 do
    local staged, unstaged, file = string.match(out[i], STATUS_PATTERNS)
    if staged == "?" or unstaged == "?" then
      table.insert(cache.untracked_changes, file)
    else
      if staged ~= " " then
        table.insert(cache.staged_changes, { file = file, status = staged })
      end
      if unstaged ~= " " then
        table.insert(cache.unstaged_changes, { file = file, status = unstaged })
      end
    end
  end
  print(branch, remote_branch, ahead_num, behind_num)
  print(vim.inspect(cache.staged_changes))
  print(vim.inspect(cache.unstaged_changes))
  print(vim.inspect(cache.untracked_changes))
  print("is_dirty : " .. tostring(cache.is_dirty()))
end
local on_git_status_exit = function(j, exit_code)
  if exit_code ~= 0 then
    print "git status failed"
    return
  end
  update_status_cache(j:result())
end

local make_git_status_job = function(cwd, env)
  return job:new {
    command = "git",
    args = { "status", "--porcelain", "--branch" },
    cwd = cwd or vim.loop.cwd(),
    env = env or {},
    on_exit = on_git_status_exit,
  }
end

local function check_dirty_cached(cwd)
  if state.last_job ~= nil and not state.last_job.is_shutdown then
    print "git status is running"
  elseif not state.on_cooldown then
    state.last_job = make_git_status_job(cwd)
    state.last_job:start()
    state.on_cooldown = true
    vim.defer_fn(function()
      state.on_cooldown = false
    end, opts.status_refresh_interval)
  else
    -- on cooldown
  end
  return cache.is_dirty()
end

return {
  cache = cache,
  check_dirty_cached = check_dirty_cached,
  internal_state = state,
}
