local M = {}
local parser = require "rc.csv.parser"
local view = require "rc.csv.view"

--- @class CsvFieldMetrics
--- @field len integer
--- @field display_width integer
--- @field is_number boolean

--- compute csv metrics
---@param bufnr integer
---@return number[] column_max_widths,CsvFieldMetrics[][] fields
local function compute_csv_metrics(bufnr)
  local column_max_widths = {} --- @type number[]
  local fields = {} --- @type CsvFieldMetrics[][]
  for lnum, columns in parser.iter_lines(bufnr) do
    fields[lnum] = {}
    for i, column in ipairs(columns) do
      local width = vim.fn.strdisplaywidth(column)
      table.insert(fields[lnum], {
        len = string.len(column),
        display_width = width,
        is_number = tonumber(column) ~= nil,
      })
      if not column_max_widths[i] or width > column_max_widths[i] then
        column_max_widths[i] = width
      end
    end
  end
  return column_max_widths, fields
end

--- enable csv table view
function M.enable()
  local bufnr = vim.api.nvim_get_current_buf()

  -- compute and start render
  local item = {}
  item.column_max_widths, item.fields = compute_csv_metrics(bufnr)
  view.start_render(bufnr, item)

  -- register autocmd for recompute
  vim.b.csvview_update_auid = vim.api.nvim_create_autocmd({ "TextChanged", "BufReadPost" }, {
    callback = function()
      item.column_max_widths, item.fields = compute_csv_metrics(bufnr)
    end,
    buffer = bufnr,
    group = vim.api.nvim_create_augroup("CsvView", {}),
  })
end

--- disable csv table view
function M.disable()
  local bufnr = vim.api.nvim_get_current_buf()

  -- clear view
  view.stop_render()
  view.clear(bufnr, 0, -1)

  -- clear autocmd for autocmd
  if vim.b.csvview_update_auid then
    vim.api.nvim_del_autocmd(vim.b.csvview_update_auid)
    vim.b.csvview_update_auid = nil
  end
end

--- setup
function M.setup()
  vim.api.nvim_create_user_command("CsvViewEnable", M.enable, {})
  vim.api.nvim_create_user_command("CsvViewDisable", M.disable, {})
end

return M
