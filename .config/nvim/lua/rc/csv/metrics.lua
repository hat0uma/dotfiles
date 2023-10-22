local parser = require "rc.csv.parser"
local strings = require "plenary.strings"
local M = {}

--- @class CsvFieldMetrics
--- @field len integer
--- @field display_width integer
--- @field is_number boolean

--- compute csv metrics
---@param bufnr integer
---@param startlnum integer?
---@param endlnum integer?
---@param fields CsvFieldMetrics[][]?
---@return { column_max_widths:number[],fields:CsvFieldMetrics[][] }
function M.compute_csv_metrics(bufnr, startlnum, endlnum, fields)
  -- local before = os.clock()
  --- @type { column_max_widths:number[],fields:CsvFieldMetrics[][] }
  local csv = { column_max_widths = {}, fields = fields or {} }

  --- analyze field
  for lnum, columns in parser.iter_lines(bufnr, startlnum, endlnum) do
    csv.fields[lnum] = {}
    for i, column in ipairs(columns) do
      local width = strings.strdisplaywidth(column)
      csv.fields[lnum][i] = {
        len = #column,
        display_width = width,
        is_number = tonumber(column) ~= nil,
      }
    end
  end
  --- update column max width
  for i = 1, #csv.fields do
    for j = 1, #csv.fields[i] do
      local width = csv.fields[i][j].display_width
      if not csv.column_max_widths[j] or width > csv.column_max_widths[j] then
        csv.column_max_widths[j] = width
      end
    end
  end
  -- local after = os.clock()
  -- print(string.format("computed %f", after - before))
  return csv
end

return M
