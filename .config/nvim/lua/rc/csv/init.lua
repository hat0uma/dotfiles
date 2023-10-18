local M = {}
local parser = require "rc.csv.parser"
local view = require "rc.csv.view"

--- @type integer[]
local enable_buffers = {}

--- @class CsvFieldMetrics
--- @field len integer
--- @field display_width integer
--- @field is_number boolean

--- @class CsvMetrics
--- @field column_max_widths number[]
--- @field fields CsvFieldMetrics[][]

--- compute csv metrics
---@param bufnr integer
---@param startlnum integer?
---@param endlnum integer?
---@param current CsvMetrics?
---@return CsvMetrics
local function compute_csv_metrics(bufnr, startlnum, endlnum, current)
  local before = os.clock()
  local csv = current or { column_max_widths = {}, fields = {} } --- @type CsvMetrics
  for lnum, columns in parser.iter_lines(bufnr, startlnum, endlnum) do
    csv.fields[lnum] = {}
    for i, column in ipairs(columns) do
      local width = vim.fn.strdisplaywidth(column)
      csv.fields[lnum][i] = {
        len = string.len(column),
        display_width = width,
        is_number = tonumber(column) ~= nil,
      }
      if not csv.column_max_widths[i] or width > csv.column_max_widths[i] then
        csv.column_max_widths[i] = width
      end
    end
  end
  local after = os.clock()
  print(string.format("computed %f", after - before))
  return csv
end

--- register buffer events
---@param bufnr integer
---@param events { on_lines:function,on_reload:function}
local function register_events(bufnr, events)
  ---  on :e
  vim.b.csvview_update_auid = vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    callback = function()
      register_events(bufnr, events)
      events.on_reload()
    end,
    buffer = bufnr,
    group = vim.api.nvim_create_augroup("CsvView", {}),
  })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(...)
      if not vim.tbl_contains(enable_buffers, bufnr) then
        return true
      end
      events.on_lines(...)
    end,
    on_reload = function()
      if not vim.tbl_contains(enable_buffers, bufnr) then
        return true
      end
      events.on_reload()
    end,
  })
end

--- unregister buffer events
---@param bufnr integer
local function unregister_events(bufnr)
  vim.api.nvim_del_autocmd(vim.b[bufnr].csvview_update_auid)
  vim.b[bufnr].csvview_update_auid = nil
end

--- enable csv table view
function M.enable()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.tbl_contains(enable_buffers, bufnr) then
    print "csvview is already enabled."
    return
  end
  table.insert(enable_buffers, bufnr)

  -- compute and attach
  local item = compute_csv_metrics(bufnr)
  view.attach(bufnr, item)
  register_events(bufnr, {
    on_lines = function(_, _, _, first, last)
      item = compute_csv_metrics(bufnr, first + 1, last + 1, item)
      view.update(bufnr, item)
    end,
    on_reload = function()
      item = compute_csv_metrics(bufnr)
      view.update(bufnr, item)
    end,
  })
end

--- disable csv table view
function M.disable()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.tbl_contains(enable_buffers, bufnr) then
    print "csvview is not enabled for this buffer."
    return
  end

  for i = #enable_buffers, 1, -1 do
    if enable_buffers[i] == bufnr then
      table.remove(enable_buffers, i)
    end
  end

  unregister_events(bufnr)
  view.detach(bufnr)
end

--- setup
function M.setup()
  vim.api.nvim_create_user_command("CsvViewEnable", M.enable, {})
  vim.api.nvim_create_user_command("CsvViewDisable", M.disable, {})
  view.setup()
end

return M
