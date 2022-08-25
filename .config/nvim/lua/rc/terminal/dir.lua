local config = require "rc.terminal.config"
local M = {}

function M.notify_cwd_changed(terminal_cwd)
  if vim.bo.filetype ~= config.terminal_ft then
    vim.notify "terminal buffer only."
  end
  vim.b.terminal_cwd = terminal_cwd
  vim.cmd [[ doautocmd User TermCwdChanged ]]
end

function M.on_term_cwd_changed()
  -- vim.notify(vim.b.terminal_cwd)
  vim.cmd.lcd(vim.b.terminal_cwd)
end

function M.on_termbuf_enter()
  if vim.b.terminal_cwd then
    vim.cmd.lcd(vim.b.terminal_cwd)
  end
end

return M
