local M = {}

local config = {
  row = 2,
  width = math.floor(vim.o.columns * 0.7 / 2),
  preview_width = math.floor(vim.o.columns * 0.7 / 2),
  branch_height = 1,
  staged_height = math.floor(vim.o.lines * 0.7 / 3),
  unstaged_height = math.floor(vim.o.lines * 0.7 / 3),
  untracked_height = math.floor(vim.o.lines * 0.7 / 3),
  border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  winhl = "Normal:Normal,FloatBorder:Normal",
  branch_ft = "GitBranch",
  staged_ft = "GitStaged",
  unstaged_ft = "GitUnstaged",
  untracked_ft = "GitUntracked",
  preview_ft = "diff",
  on_open = function()
    -- M.focus "staged"
    M.focus(1)
    local function bind(f, ...)
      local args = { ... }
      return function()
        f(unpack(args))
      end
    end
    for _, win in ipairs(M.ordered) do
      local opt = { noremap = true, buffer = win.bufnr }
      vim.keymap.set("n", "q", M.close, opt)
      vim.keymap.set("n", "1", bind(M.focus, 1), opt)
      vim.keymap.set("n", "2", bind(M.focus, 2), opt)
      vim.keymap.set("n", "3", bind(M.focus, 3), opt)
    end
  end,
}

M.branch = {
  bufnr = 0,
  winid = 0,
  name = "branch",
  height = config.branch_height,
  ft = config.branch_ft,
  focus = false,
}

M.staged = {
  bufnr = 0,
  winid = 0,
  name = "staged",
  height = config.staged_height,
  ft = config.staged_ft,
  focus = true,
}

M.unstaged = {
  bufnr = 0,
  winid = 0,
  name = "unstaged",
  height = config.unstaged_height,
  ft = config.unstaged_ft,
  focus = true,
}

M.untracked = {
  bufnr = 0,
  winid = 0,
  name = "untracked",
  height = config.untracked_height,
  ft = config.untracked_ft,
  focus = true,
}

M.ordered = {
  M.branch,
  M.staged,
  M.unstaged,
  M.untracked,
}

M.preview = {
  bufnr = 0,
  winid = 0,
  ft = config.preview_ft,
}

local function border_top()
  local border = { unpack(config.border_chars) }
  border[5] = ""
  border[6] = ""
  border[7] = ""
  return border
end
local function border_middle()
  local border = { unpack(config.border_chars) }
  border[1] = border[4]
  border[3] = border[4]
  border[5] = border[4]
  border[7] = border[4]
  return border
end
local function border_bottom()
  local border = { unpack(config.border_chars) }
  border[1] = border[4]
  border[3] = border[4]
  return border
end

local function open_float(bufnr, opts)
  local winopts = {
    relative = "editor",
    style = "minimal",
    border = opts.border,
    width = opts.width,
    height = opts.height,
    col = opts.col,
    row = opts.row,
  }
  local winid = vim.api.nvim_open_win(bufnr, false, winopts)
  vim.api.nvim_win_set_option(winid, "winhl", config.winhl)
  return winid
end

function M.open()
  -- already opened
  if M.branch.winid ~= 0 then
    return
  end

  local height_accum = 0
  for i, win in ipairs(M.ordered) do
    win.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(win.bufnr, "filetype", win.ft)
    local border = i == 1 and border_top() or (i == #M.ordered and border_bottom() or border_middle())
    win.winid = open_float(win.bufnr, {
      width = config.width,
      height = win.height,
      col = vim.o.columns / 2 - config.width - 2,
      row = config.row + height_accum,
      border = border,
    })
    -- height with border
    height_accum = height_accum + win.height + 1
  end

  -- preview win
  M.preview.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(M.preview.bufnr, "ft", M.preview.ft)
  M.preview.winid = open_float(M.preview.bufnr, {
    width = config.preview_width,
    height = height_accum - 1,
    col = vim.o.columns / 2,
    row = config.row,
    border = config.border_chars,
  })

  -- close all window if one window closed.
  local aug_id = vim.api.nvim_create_augroup("git_window_augroup", { clear = true })
  local wins = { M.branch, M.staged, M.unstaged, M.untracked, M.untracked, M.preview }
  for _, win in ipairs(wins) do
    vim.api.nvim_create_autocmd("WinClosed", { pattern = tostring(win.winid), callback = M.close, group = aug_id })
  end

  if config.on_open then
    config.on_open()
  end
end

function M.close()
  local _close = function(win)
    if win.winid ~= 0 then
      vim.api.nvim_win_close(win.winid, true)
      win.winid = 0
    end
  end
  _close(M.preview)
  for _, win in ipairs(M.ordered) do
    _close(win)
  end
end

---@alias GitWinName
---| '"branch"'
---| '"staged"'
---| '"unstaged"'
---| '"untracked"'
--- focus
---@param window number|GitWinName
function M.focus(window)
  if type(window) == "number" then
    -- focus with ordered number
    local focusables = vim.tbl_filter(function(win)
      return win.focus
    end, M.ordered)
    if focusables[window] then
      vim.api.nvim_set_current_win(focusables[window].winid)
    end
  else
    -- focus with name
    for _, win in ipairs(M.ordered) do
      if win.name == window then
        vim.api.nvim_set_current_win(win.winid)
        break
      end
    end
  end
end

return M
