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

return {
  path = require("rc.util.path"),
  system = require("rc.util.system"),
  region = require("rc.util.region"),
  screen_to_string = screen_to_string,
}
