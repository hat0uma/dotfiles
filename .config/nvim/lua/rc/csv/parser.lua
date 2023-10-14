local M = {}

--- read fields
---@param line string
---@return string[]
local function parse_fields(line)
  return vim.split(line, ",", { trimempty = true })
end

--- iterate fields
---@param bufnr integer
---@param startlnum integer?
---@param endlnum integer?
---@return fun():integer?,string[]?
function M.iter_lines(bufnr, startlnum, endlnum)
  local lnum = endlnum and endlnum or vim.api.nvim_buf_line_count(bufnr)
  local i = startlnum and startlnum or 1
  return function()
    if i > lnum then
      return nil, nil
    end

    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, true)
    i = i + 1
    return i - 1, parse_fields(line[1])
  end
end

return M
