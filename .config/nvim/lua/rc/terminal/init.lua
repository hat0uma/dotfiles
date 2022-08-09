local M = {}
local shell = require "rc.terminal.shell"

local function is_floating(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg.relative ~= "" or cfg.external
end

local function _edit(split_cmd)
  return function(opts)
    if is_floating(0) then
      vim.cmd.close()
    end
    if split_cmd then
      vim.cmd(split_cmd)
    end
    for _, arg in pairs(opts.fargs) do
      vim.cmd.edit(arg)
    end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("TEdit", _edit(), { nargs = "*", complete = "file", bar = true })
  vim.api.nvim_create_user_command("TVsplit", _edit "vs", { nargs = "*", complete = "file", bar = true })
  vim.api.nvim_create_user_command("TSplit", _edit "sp", { nargs = "*", complete = "file", bar = true })
end
return M
