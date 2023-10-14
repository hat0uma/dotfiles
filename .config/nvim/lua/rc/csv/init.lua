local M = {}
local parser = require "rc.csv.parser"
local view = require "rc.csv.view"

local function update()
  local bufnr = vim.api.nvim_get_current_buf()

  --- calculate max column width
  local column_max_width = {} --- @type number[]
  for _, columns in parser.iter_lines(bufnr) do
    for i, column in ipairs(columns) do
      local width = vim.fn.strdisplaywidth(column)
      if not column_max_width[i] or width > column_max_width[i] then
        column_max_width[i] = width
      end
    end
  end

  -- render
  view.clear(bufnr)
  for lnum, columns in parser.iter_lines(bufnr) do
    view.render_line(bufnr, lnum, columns, column_max_width)
  end
end

function M.enable()
  update()
  vim.b.csvview_update_auid = vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    callback = update,
    buffer = 0,
    group = vim.api.nvim_create_augroup("CsvView", {}),
  })
end

function M.disable()
  local bufnr = vim.api.nvim_get_current_buf()
  view.clear(bufnr)
  if vim.b.csvview_update_auid then
    vim.api.nvim_del_autocmd(vim.b.csvview_update_auid)
    vim.b.csvview_update_auid = nil
  end
end

function M.setup()
  vim.api.nvim_create_user_command("CsvViewEnable", M.enable, {})
  vim.api.nvim_create_user_command("CsvViewDisable", M.disable, {})
end

return M
