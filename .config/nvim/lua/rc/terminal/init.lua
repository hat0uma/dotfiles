--- This module provides terminal related functions.
local M = {}

local function is_floating(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg.relative ~= "" or cfg.external
end

-- functions for script
local function _edit_files(opts)
  local wd = opts.fargs[1] --- @type string
  local files = {} --- @type string[]
  for i = 2, #opts.fargs, 1 do
    table.insert(files, opts.fargs[i])
  end
  if is_floating(0) then
    vim.cmd.close()
  end
  for _, file in pairs(files) do
    local path = rc.path.make_absolute(wd, file)
    vim.cmd.edit(path)
  end
end

function M.setup()
  require("rc.terminal.dir").setup()
  require("rc.terminal.editor").setup()

  -- commands for script
  -- This command is intended to be called via RPC from shell scripts in the terminal.
  -- See bin/, bin.pwsh/ for more information.
  local cmd_opts = { nargs = "*", complete = "file", bar = true }
  vim.api.nvim_create_user_command("TEdit", function(opts)
    _edit_files(opts)
  end, cmd_opts)
  vim.api.nvim_create_user_command("TVsplit", function(opts)
    vim.cmd.vsplit()
    _edit_files(opts)
  end, cmd_opts)
  vim.api.nvim_create_user_command("TSplit", function(opts)
    vim.cmd.split()
    _edit_files(opts)
  end, cmd_opts)
end

M.shell = require("rc.terminal.shell")

return M
