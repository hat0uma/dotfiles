local job = require "plenary.job"
local parser = require "rc.git.parser"
local window = require "rc.git.window"
local display = require "rc.git.display"
local preview = require "rc.git.preview"

local M = {}
M.kinds = {
  branch = {
    values = {},
    display = display.branch,
    win = window.branch,
  },
  staged = {
    values = {},
    display = display.staged_changes,
    preview = preview.staged,
    win = window.staged,
  },
  unstaged = {
    values = {},
    display = display.unstaged_changes,
    preview = nil,
    win = window.unstaged,
  },
  untracked = {
    values = {},
    display = display.untracked,
    preview = nil,
    win = window.untracked,
  },
}
M.current_preview = nil

local function ppreview(kind)
  local line = vim.fn.line "."
  local current = kind.values[line]
  print(vim.inspect(current))
  if M.current_preview ~= current and kind.preview then
    M.current_preview = current
    kind.preview(current, function(r, code)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(window.preview.bufnr, 0, -1, false, r)
      end)
    end)
  end
end

local function register_autocmds()
  local augroup = vim.api.nvim_create_augroup("git_status_augroup", { clear = true })
  for _, kind in pairs(M.kinds) do
    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = function()
        ppreview(kind)
      end,
      group = augroup,
      buffer = kind.win.bufnr,
    })
  end
end

function _G.test_status_v2()
  local status_job = job:new {
    command = "git",
    args = { "status", "--porcelain=v2", "--branch", "--show-stash" },
    cwd = vim.loop.cwd(),
    env = {},
  }
  local r, code = status_job:sync(1000, 10)
  local status = parser.parse_status_v2(r)
  local all_changes = {}
  -- { unpack(status.ordinary_changed), unpack(status.renamed_or_copied), unpack(status.unmerged) }
  for _, entry in ipairs(status.ordinary_changed) do
    table.insert(all_changes, entry)
  end
  for _, entry in ipairs(status.renamed_or_copied) do
    table.insert(all_changes, entry)
  end
  for _, entry in ipairs(status.unmerged) do
    table.insert(all_changes, entry)
  end
  M.kinds.branch.values = { status.branch }
  M.kinds.staged.values = vim.tbl_filter(function(s)
    return s.status.staged ~= "."
  end, all_changes)
  M.kinds.unstaged.values = vim.tbl_filter(function(s)
    return s.status.unstaged ~= "."
  end, all_changes)
  M.kinds.untracked.values = status.untracked

  window.open()
  local function show(kind)
    vim.api.nvim_buf_set_lines(kind.win.bufnr, 0, -1, false, vim.tbl_map(kind.display, kind.values))
  end
  show(M.kinds.branch)
  show(M.kinds.staged)
  show(M.kinds.unstaged)
  show(M.kinds.untracked)
  register_autocmds()
end

return M
