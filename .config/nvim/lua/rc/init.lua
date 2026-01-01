-- scrren to string
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

local function region_to_text(region)
  local text = ""
  local maxcol = vim.v.maxcol
  for line, cols in vim.spairs(region) do
    local endcol = cols[2] == maxcol and -1 or cols[2]
    local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
    text = ("%s%s\n"):format(text, chunk)
  end
  return text
end

local function get_visual_selection()
  local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
  return region_to_text(r)
end

return {
  toys = require("rc.toys.init"),
  git = require("rc.git"),
  img = require("rc.img"),
  path = require("rc.path"),
  projectrc = require("rc.projectrc"),
  editor = require("rc.editor"),
  scratch = require("rc.scratch"),
  sys = require("rc.sys"),
  curcenter = require("rc.curcenter"),
  terminal = require("rc.terminal"),
  winbar = require("rc.winbar"),
  ambiwidth = require("rc.ambiwidth"),
  screen_to_string = screen_to_string,
  region_to_text = region_to_text,
  get_visual_selection = get_visual_selection,
}
