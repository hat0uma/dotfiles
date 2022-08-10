local M = {}
local shell = require "rc.terminal.shell"
local config = require "rc.terminal.config"

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

local function on_bufenter()
  if vim.bo.filetype == config.terminal_ft then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end

local function on_termbufleave()
  vim.b.rc_terminal_mode = vim.fn.mode()
end

local function open_new_terminal()
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.bo[bufnr].filetype = config.terminal_ft
  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.termopen(shell.cmd, { env = shell.env })
  end)

  config.setup_terminal(bufnr)
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.cmd.startinsert()
  return bufnr
end

function M.show()
  local winid = vim.api.nvim_get_current_win()
  if vim.w.rc_terminal_bufnr ~= nil then
    vim.api.nvim_win_set_buf(winid, vim.w.rc_terminal_bufnr)
  else
    vim.w.rc_terminal_bufnr = open_new_terminal()
  end
end

function M.show_vs()
  vim.cmd.vsplit()
  M.show()
end

function M.show_sp()
  vim.cmd.split()
  M.show()
end

function M.setup()
  -- autocmds
  local augid = vim.api.nvim_create_augroup("rc_terminal_aug", {})
  vim.api.nvim_create_autocmd("BufEnter", { group = augid, pattern = "*", callback = on_bufenter })
  vim.api.nvim_create_autocmd("BufLeave", { group = augid, pattern = "term:/*", callback = on_termbufleave })

  -- commands
  vim.api.nvim_create_user_command("TEdit", _edit(), { nargs = "*", complete = "file", bar = true })
  vim.api.nvim_create_user_command("TVsplit", _edit "vs", { nargs = "*", complete = "file", bar = true })
  vim.api.nvim_create_user_command("TSplit", _edit "sp", { nargs = "*", complete = "file", bar = true })

  -- keymaps
  vim.keymap.set("n", "<C-t>", M.show, { noremap = true })
  vim.keymap.set("n", "<leader>%", M.show_vs, { noremap = true })
  vim.keymap.set("n", '<leader>"', M.show_sp, { noremap = true })
end

return M
