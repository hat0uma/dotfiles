local M = {}
local config = require "rc.terminal.config"
local util = require "rc.utils"

local function is_floating(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg.relative ~= "" or cfg.external
end

-- functions for script
local function _edit_files(opts, cwd)
  if is_floating(0) then
    vim.cmd.close()
  end
  for _, arg in pairs(opts.fargs) do
    local path = util.rel_or_abs(cwd, arg)
    vim.cmd.edit(path)
  end
end

local function edit_files(opts)
  _edit_files(opts, vim.b.terminal_cwd)
end

local function vsplit_files(opts)
  vim.cmd.vsplit()
  _edit_files(opts, vim.b.terminal_cwd)
end

local function split_files(opts)
  vim.cmd.split()
  _edit_files(opts, vim.b.terminal_cwd)
end

function M.setup()
  require("rc.terminal.dir").setup()

  -- commands
  local cmdopts = { nargs = "*", complete = "file", bar = true }
  vim.api.nvim_create_user_command("TEdit", edit_files, cmdopts)
  vim.api.nvim_create_user_command("TVsplit", vsplit_files, cmdopts)
  vim.api.nvim_create_user_command("TSplit", split_files, cmdopts)
end

return M
