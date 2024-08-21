local M = {}

local function fetch()
  vim.system({ "git", "fetch" }, { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.notify("fetch failed.\n" .. obj.stderr, vim.log.levels.WARN)
    end
  end)
end

local timer = nil --- @type uv_timer_t?
local job = nil --- @type vim.SystemObj?

function M.is_enabled()
  return timer and not timer:is_closing()
end

--- Enable auto git fetch
---@param duration? number milliseconds
function M.enable(duration)
  duration = duration or (1000 * 30)

  if M.is_enabled() then
    vim.notify("auto fetch already started.")
    return
  end

  timer = vim.uv.new_timer()
  vim.uv.timer_start(timer, duration, duration, function()
    if job and not job:is_closing() then
      vim.notify("fetch is already running.")
      return
    end
    M.job = fetch()
  end)
end

--- Disable auto git fetch
function M.disable()
  if timer and not timer:is_closing() then
    vim.uv.timer_stop(timer)
    vim.uv.close(timer)
    timer = nil
  end
end

return M
