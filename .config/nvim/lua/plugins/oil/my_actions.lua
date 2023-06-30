local M = {}

M.state = {
  filename = "",
  dir = "",
  direction = "float",
}

--- move cursor
---@param name string
local function find(name)
  local lines = vim.fn.line "$"
  for i = 1, lines, 1 do
    local entry = require("oil").get_entry_on_line(0, i)
    if entry and entry.name == name then
      vim.cmd(string.format("%d", i))
      break
    end
  end
end

M.open_explorer = {
  desc = "open current directory by explorer.",
  callback = function()
    local is_windows = vim.loop.os_uname().version:match "Windows"
    local opener = is_windows and "explorer.exe" or "xdg-open"
    local oil = require "oil"
    local dir = oil.get_current_dir()
    vim.cmd(string.format("!%s %s", opener, dir))
  end,
}

M.open_terminal = {
  desc = "open terminal in current directory.",
  callback = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local oil = require "oil"
    local dir = oil.get_current_dir()
    local term = Terminal:new {
      dir = dir,
      direction = "float",
    }
    term:toggle()
  end,
}

local function float_select(base)
  local oil = require "oil"
  local entry = oil.get_cursor_entry()
  if entry and entry.type == "directory" then
    local current = oil.get_current_dir()
    oil.close()
    oil.open(current)
  end
  base.callback()
end

M.float_select_vsplit = function()
  float_select(require("oil.actions").select_vsplit)
end

M.float_select_split = function()
  float_select(require("oil.actions").select_split)
end

function M.home()
  vim.cmd.edit(vim.fn.fnamemodify("~", ":p"))
end

function M.toggle_tab()
  local oil = require "oil"
  local dir = oil.get_current_dir()
  if M.state.direction == "float" then
    oil.close()
    vim.cmd.tabedit(dir)
    M.state.direction = "tab"
  elseif M.state.direction == "tab" then
    vim.cmd.tabclose()
    oil.open_float(dir)
    M.state.direction = "float"
  else
  end
end

function M.close()
  if M.state.direction == "float" then
    require("oil.actions").close.callback()
  elseif M.state.direction == "tab" then
    vim.cmd.tabclose()
  else
  end
end

function M.find()
  find(M.state.filename)
end

function M.open()
  local buf = vim.fn.expand "%:p"
  if vim.fn.filereadable(buf) ~= 0 then
    M.state.filename = vim.fn.expand "%:p:t"
    M.state.dir = vim.fn.expand "%:p:h"
  else
    M.state.filename = ""
    M.state.dir = vim.loop.cwd()
  end

  -- move cursor
  vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    callback = vim.schedule_wrap(function()
      find(M.state.filename)
    end),
    group = vim.api.nvim_create_augroup("my-oil-settings", {}),
    once = true,
  })

  if M.state.direction == "float" then
    require("oil").open_float(M.state.dir)
  elseif M.state.direction == "tab" then
    vim.cmd.tabedit(M.state.dir)
  else
    require("oil").open_float(M.state.dir)
    M.state.direction = "float"
  end
end

return M
