local async = require "plenary.async"
local job = require "plenary.job"

-- test
local cache = {}
cache.dirty = false

local opts = {}

local on_git_status_exit = function(j, _)
  -- update dirty
  local r = j:result()
  if type(r) == "table" and next(r) ~= nil then
    cache.dirty = true
  elseif type(r) == "string" and r ~= "" then
    cache.dirty = true
  else
    cache.dirty = false
  end
  print(cache.dirty)
end

local git_status_job = job:new {
  command = "git",
  args = { "status", "--porcelain" },
  cwd = opts.cwd or vim.loop.cwd(),
  env = opts.env or {},
  on_exit = on_git_status_exit,
}

local timer = vim.loop.new_timer()
timer:start(0, 3000, function()
  git_status_job:start()
end)
