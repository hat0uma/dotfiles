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
local git = {}
git.cache = {}
git.cache.staged_changes = {}
git.cache.unstaged_changes = {}
git.cache.untracked_changes = {}
git.cache.reset = function()
  git.cache.staged_changes = {}
  git.cache.unstaged_changes = {}
  git.cache.untracked_changes = {}
end
git.cache.is_dirty = function()
  return #git.cache.staged_changes ~= 0 or #git.cache.unstaged_changes ~= 0 or #git.cache.untracked_changes ~= 0
end
git.context = {}
git.context.last_job = nil
git.context.on_cooldown = false

local function update_status_cache(out)
  git.cache.reset()
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
      table.insert(git.cache.untracked_changes, file)
    else
      if staged ~= " " then
        table.insert(git.cache.staged_changes, { file = file, status = staged })
      end
      if unstaged ~= " " then
        table.insert(git.cache.unstaged_changes, { file = file, status = unstaged })
      end
    end
  end
  print(branch, remote_branch, ahead_num, behind_num)
  print(vim.inspect(git.cache.staged_changes))
  print(vim.inspect(git.cache.unstaged_changes))
  print(vim.inspect(git.cache.untracked_changes))
  print("is_dirty : " .. tostring(git.cache.is_dirty()))
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

function git.check_dirty_cached(cwd)
  if git.context.last_job ~= nil and not git.context.last_job.is_shutdown then
    print "git status is running"
  elseif not git.context.on_cooldown then
    git.context.last_job = make_git_status_job(cwd)
    git.context.last_job:start()
    git.context.on_cooldown = true
    vim.defer_fn(function()
      git.context.on_cooldown = false
    end, opts.status_refresh_interval)
  else
    -- on cooldown
  end
  return git.cache.is_dirty()
end

return git
