local async = require "plenary.async"
local job = require "plenary.job"

-- test
local opts = {}
local git = {}

git.cache = { dirty = false }

local on_git_status_exit = function(j, _)
  -- update dirty
  local r = j:result()
  git.cache.dirty = next(r) ~= nil
  print(git.cache.dirty)
end

local git_status_job = job:new {
  command = "git",
  args = { "status", "--porcelain" },
  cwd = opts.cwd or vim.loop.cwd(),
  env = opts.env or {},
  on_exit = on_git_status_exit,
}

local timer = vim.loop.new_timer()
function git.start_check_dirty()
  timer:start(0, 3000, function()
    git_status_job:start()
  end)
end

function git.stop_check_dirty()
  timer:close()
end

return git
