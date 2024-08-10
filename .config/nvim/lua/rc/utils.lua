local M = {}

function M.accessable(path)
  return vim.loop.fs_access(path, "R", nil)
end

---@param cwd string
---@param file string
function M.rel_or_abs(cwd, file)
  local Path = require("plenary.path")

  --- @type string
  if cwd == nil then
    return file
  end
  local retpath = Path:new({ cwd, file }):absolute()
  if not M.accessable(retpath) then
    retpath = file
  end
  return retpath
end

function M.region_to_text(region)
  local text = ""
  local maxcol = vim.v.maxcol
  for line, cols in vim.spairs(region) do
    local endcol = cols[2] == maxcol and -1 or cols[2]
    local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
    text = ("%s%s\n"):format(text, chunk)
  end
  return text
end

function M.get_visual_selection()
  local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
  return M.region_to_text(r)
end

--- scrren to string
---@param winid integer
---@return string
local function screen_to_string(winid)
  local first_line = vim.fn.line("w0", winid)
  local first_col = vim.fn.col({ first_line, "w0" }, winid)
  if not first_line or not first_col then
    error(first_line, first_col)
  end

  local screen = {} --- @type string[]
  local screenpos = vim.fn.screenpos(winid, first_line, first_col)
  for i = 0, vim.api.nvim_win_get_height(winid) - 1 do
    local line = {}
    for j = 0, vim.api.nvim_win_get_width(winid) - 1 do
      local c = vim.fn.screenstring(i + screenpos.row, j + screenpos.col)
      table.insert(line, c)
    end
    table.insert(screen, table.concat(line, ""))
  end
  return table.concat(screen, "\n")
end
return M
