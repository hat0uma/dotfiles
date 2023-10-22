local M = {}
local parser = require "rc.csv.parser"
local view = require "rc.csv.view"
local strings = require "plenary.strings"

--- @type integer[]
local enable_buffers = {}

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
local function compute_csv_metrics(bufnr, startlnum, endlnum, fields)
  local before = os.clock()
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
  -- require("profile").start "*"
  -- local item = compute_csv_metrics(bufnr, 1, 10000)
  -- require("profile").stop "profile.json"
  local item = compute_csv_metrics(bufnr)
  view.attach(bufnr, item)
  register_events(bufnr, {
    on_lines = function(_, _, _, first, last)
      item = compute_csv_metrics(bufnr, first + 1, last + 1, item.fields)
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
