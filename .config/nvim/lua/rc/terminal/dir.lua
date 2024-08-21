--- This module provides a feature to synchronize the current directory of the terminal and the current directory(lcd) of neovim.

local M = {}

--- Notify neovim that the current directory of the terminal has changed.
--- This function is intended to be called from zsh's chpwd hook, pwsh's prompt function, etc.
---@param terminal_cwd string
function M.notify_cwd_changed(terminal_cwd)
  if vim.bo.buftype ~= "terminal" then
    vim.notify("terminal buffer only.")
  end
  vim.b.terminal_cwd = terminal_cwd
  vim.cmd([[ doautocmd User TermCwdChanged ]])
end

--- Setup the terminal directory feature.
function M.setup()
  local group = vim.api.nvim_create_augroup("rc.terminal.dir", {})
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "TermCwdChanged",
    callback = function()
      vim.cmd.lcd(vim.b.terminal_cwd)
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "term:/*",
    callback = function()
      if vim.b.terminal_cwd then
        vim.cmd.lcd(vim.b.terminal_cwd)
      end
    end,
  })
end

return M
