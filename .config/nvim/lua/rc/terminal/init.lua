local M = {}
local config = require "rc.terminal.config"
local util = require "rc.utils"
local AUGID = vim.api.nvim_create_augroup("rc_terminal_aug", {})

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
    local path = util.accessable_path(cwd, arg)
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

-- callbacks
local function on_termenter() end

local function on_termleave() end

local function on_termbufleave() end

--- open new terminal buffer
---@param opts TermConfig
---@return number bufnr
local function open_new_terminal(opts)
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.bo[bufnr].filetype = opts.terminal_ft
  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.termopen(opts.shell.cmd, { env = opts.shell.env })
    opts.on_open(bufnr)
  end)
  return bufnr
end

--- attach to window
---@param winid number
---@param bufnr number
local function attach_terminal_to_window(winid, bufnr)
  vim.w[winid].rc_terminal_bufnr = bufnr
  vim.api.nvim_create_autocmd("TermClose", {
    group = AUGID,
    buffer = bufnr,
    callback = function()
      vim.w[winid].rc_terminal_bufnr = nil
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = AUGID,
    pattern = tostring(winid),
    callback = function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end,
  })
end

--- find attached terminal
---@param winid number
---@return number:bufnr|nil
local function find_attached_terminal(winid)
  return vim.w[winid].rc_terminal_bufnr
end

--- show terminal on current window
---@param opts TermConfig?
function M.show(opts)
  opts = vim.tbl_extend("keep", opts or {}, config)
  local winid = vim.api.nvim_get_current_win()
  local term = find_attached_terminal(winid)
  if term ~= nil then
    vim.api.nvim_win_set_buf(winid, term)
  else
    local new_term = open_new_terminal(opts)
    vim.api.nvim_win_set_buf(winid, new_term)
    attach_terminal_to_window(winid, new_term)
  end
  if opts.start_in_insert then
    vim.cmd.startinsert()
  end
end

--- show terminal with vsplit
---@param opts TermConfig?
function M.show_vs(opts)
  vim.cmd.vsplit()
  M.show(opts)
end

--- show terminal with split
---@param opts TermConfig?
function M.show_sp(opts)
  vim.cmd.split()
  M.show(opts)
end

function M.setup()
  require("rc.terminal.dir").setup()

  -- autocmds
  vim.api.nvim_create_autocmd("TermEnter", { group = AUGID, pattern = "*", callback = on_termenter })
  vim.api.nvim_create_autocmd("TermLeave", { group = AUGID, pattern = "*", callback = on_termleave })
  vim.api.nvim_create_autocmd("BufLeave", { group = AUGID, pattern = "term:/*", callback = on_termbufleave })

  -- commands
  local cmdopts = { nargs = "*", complete = "file", bar = true }
  vim.api.nvim_create_user_command("TEdit", edit_files, cmdopts)
  vim.api.nvim_create_user_command("TVsplit", vsplit_files, cmdopts)
  vim.api.nvim_create_user_command("TSplit", split_files, cmdopts)

  -- keymaps
  local keyopts = { noremap = true }
  vim.keymap.set("n", "<C-t>", M.show, keyopts)
  vim.keymap.set("n", "<leader>%", M.show_vs, keyopts)
  vim.keymap.set("n", '<leader>"', M.show_sp, keyopts)
end

return M
