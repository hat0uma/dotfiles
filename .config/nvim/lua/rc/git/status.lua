local job = require "plenary.job"
local parser = require "rc.git.parser"
local GitStatus = parser.GitStatus
local window = require "rc.git.window"
local display = require "rc.git.display"
local util = require "rc.git.util"

-- test
local config = {
  status_refresh_interval = 3000,
}

local status_cache = GitStatus.new()

local state = {}
state.last_job = nil
state.on_cooldown = false

--- update status cache(on exit status)
---@param j Job
---@param exit_code number
local function update_status_cache(j, exit_code)
  if exit_code ~= 0 then
    print "git status failed"
    return
  end
  local out = j:result()
  status_cache = parser.parse_status_v2(out)
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
local function get_status_cached(cwd)
  if state.on_cooldown then
    -- do nothing
  elseif state.last_job ~= nil and not state.last_job.is_shutdown then
    print "git status is running"
  else
    state.last_job = make_git_status_job { cwd = cwd, on_exit = update_status_cache }
    state.last_job:start()
    state.on_cooldown = true
    vim.defer_fn(function()
      state.on_cooldown = false
    end, config.status_refresh_interval)
  end
  return status_cache
end

function _G.test_status_v2()
  local status_job = job:new {
    command = "git",
    args = { "status", "--porcelain=v2", "--branch", "--show-stash" },
    cwd = vim.loop.cwd(),
    env = {},
  }
  local r, code = status_job:sync(1000, 10)
  package.loaded["rc.git.parser"] = nil
  parser = require "rc.git.parser"
  local status = parser.parse_status_v2(r)
  -- print("exit code : " .. code)
  -- print(vim.inspect(r))
  -- print(vim.inspect(status))
  local all_changes = { unpack(status.ordinary_changed), unpack(status.renamed_or_copied), unpack(status.unmerged) }
  local staged = util.list_partition(function(s)
    return s.status.staged ~= "."
  end, all_changes)

  local unstaged = vim.tbl_filter(function(s)
    return s.status.unstaged ~= "."
  end, all_changes)

  window.open()
  vim.api.nvim_buf_set_lines(window.branch.bufnr, 0, -1, false, { display.branch(status.branch) })
  vim.api.nvim_buf_set_lines(window.staged.bufnr, 0, -1, false, vim.tbl_map(display.staged_changes, staged))
  vim.api.nvim_buf_set_lines(window.unstaged.bufnr, 0, -1, false, vim.tbl_map(display.unstaged_changes, unstaged))
  vim.api.nvim_buf_set_lines(window.untracked.bufnr, 0, -1, false, vim.tbl_map(display.untracked, status.untracked))
end

return {
  status_cache = status_cache,
  get_status_cached = get_status_cached,
  internal_state = state,
}
