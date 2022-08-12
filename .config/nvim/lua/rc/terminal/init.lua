local M = {}
local shells = require "rc.terminal.shells"
local config = {
  terminal_ft = "terminal",
  start_in_insert = false,
  shell = vim.fn.has "win64" == 1 and shells.pwsh or shells.zsh,
  on_open = function(bufnr)
    local opts = { noremap = true, buffer = bufnr }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "jj", [[<C-\><C-n>]], opts)
  end,
}

-- functions for script
local function edit_files(opts)
  for _, arg in pairs(opts.fargs) do
    vim.cmd.edit(arg)
  end
end
local function vsplit_files(opts)
  vim.cmd.vsplit()
  edit_files(opts)
end
local function split_files(opts)
  vim.cmd.split()
  edit_files(opts)
end

-- callbacks
local function on_termenter() end
local function on_termleave() end
local function on_termbufleave() end

--- open new terminal buffer
---@return number bufnr
local function open_new_terminal()
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.bo[bufnr].filetype = config.terminal_ft
  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.termopen(config.shell.cmd, { env = config.shell.env })
    config.on_open(bufnr)
  end)
  return bufnr
end

--- show terminal on current window
--- Buffers are associated with windows
function M.show()
  local winid = vim.api.nvim_get_current_win()
  if vim.w.rc_terminal_bufnr ~= nil then
    vim.api.nvim_win_set_buf(winid, vim.w.rc_terminal_bufnr)
  else
    vim.w.rc_terminal_bufnr = open_new_terminal()
    vim.api.nvim_win_set_buf(winid, vim.w.rc_terminal_bufnr)
    if config.start_in_insert then
      vim.cmd.startinsert()
    end
  end
end
--- show terminal with vsplit
function M.show_vs()
  vim.cmd.vsplit()
  M.show()
end
--- show terminal with split
function M.show_sp()
  vim.cmd.split()
  M.show()
end

function M.setup()
  -- autocmds
  local augid = vim.api.nvim_create_augroup("rc_terminal_aug", {})
  vim.api.nvim_create_autocmd("TermEnter", { group = augid, pattern = "*", callback = on_termenter })
  vim.api.nvim_create_autocmd("TermLeave", { group = augid, pattern = "*", callback = on_termleave })
  vim.api.nvim_create_autocmd("BufLeave", { group = augid, pattern = "term:/*", callback = on_termbufleave })

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
