local config = require "rc.terminal.config"
local M = {}

function M.notify_cwd_changed(terminal_cwd)
  if vim.bo.buftype ~= "terminal" then
    vim.notify "terminal buffer only."
  end
  vim.b.terminal_cwd = terminal_cwd
  vim.cmd [[ doautocmd User TermCwdChanged ]]
end

local function on_term_cwd_changed()
  -- vim.notify(vim.b.terminal_cwd)
  vim.cmd.lcd(vim.b.terminal_cwd)
end

local function on_termbuf_enter()
  if vim.b.terminal_cwd then
    vim.cmd.lcd(vim.b.terminal_cwd)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("rc_terminal_dir", {})
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "TermCwdChanged",
    callback = on_term_cwd_changed,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "term:/*",
    callback = on_termbuf_enter,
  })
end

return M
