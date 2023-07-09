local util = require "rc.git.util"
local fetch = require "rc.git.ops.fetch"
local M = {}

M.options = {
  auto_fetch_duration = 30000,
  start = true,
}

M.timer = nil --- @type uv_timer_t?
M.job = nil --- @type SystemObj?

M.is_starting = function()
  return M.timer and not M.timer:is_closing()
end

M.auto_fetch_start = function()
  if M.is_starting() then
    vim.notify("auto fetch already started.", "INFO")
  end
  M.timer = util.setInterval(
    M.options.auto_fetch_duration,
    vim.schedule_wrap(function()
      if M.job and not M.job:is_closing() then
        vim.notify("fetch is already running.", "INFO")
        return
      end
      M.job = fetch.run()
    end)
  )
end
M.auto_fetch_stop = function()
  if M.is_starting() then
    util.clearInterval(M.timer)
    M.timer = nil
  end
end
M.auto_fetch_status = function()
  if M.is_starting() then
    vim.notify "auto fetch starting."
  else
    vim.notify "auto fetch stopped."
  end
end

function M.setup(opts)
  M.options = vim.tbl_extend("keep", opts or {}, M.options)
  vim.api.nvim_create_user_command("GitAutoFetchStart", M.auto_fetch_start, {})
  vim.api.nvim_create_user_command("GitAutoFetchStop", M.auto_fetch_stop, {})
  vim.api.nvim_create_user_command("GitAutoFetchStatus", M.auto_fetch_status, {})
  if M.options.start then
    M.auto_fetch_start()
  end
end

return M
