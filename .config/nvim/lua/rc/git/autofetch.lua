local util = require "rc.git.util"
local fetch = require "rc.git.ops.fetch"
local M = {}

M.options = {
  auto_fetch_duration = 30000,
  start = false,
}

M.timer = nil --- @type uv_timer_t?
M.job = nil --- @type SystemObj?

function M.is_starting()
  return M.timer and not M.timer:is_closing()
end

function M.auto_fetch_start()
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

function M.auto_fetch_stop()
  if M.is_starting() then
    util.clearInterval(M.timer)
    M.timer = nil
  end
end

function M.auto_fetch_status()
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
