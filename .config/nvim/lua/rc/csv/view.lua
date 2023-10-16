local M = {}
local EXTMARK_NS = vim.api.nvim_create_namespace "csv_extmark"

local config = {
  min_column_width = 5,
  pack = 2,
  border = {
    char = "│",
    hl = "Comment",
  },
}

--- add virt padding
---@param bufnr integer
---@param lnum integer
---@param offset integer
---@param padding integer
---@param field CsvFieldMetrics
local function render_right_padding(bufnr, lnum, offset, padding, field)
  if padding == 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(bufnr, EXTMARK_NS, lnum - 1, offset + field.len, {
    virt_text = { { string.rep(" ", padding) } },
    virt_text_pos = "inline",
    right_gravity = true,
  })
end

--- add virt padding
---@param bufnr integer
---@param lnum integer
---@param offset integer
---@param padding integer
local function render_left_padding(bufnr, lnum, offset, padding)
  if padding == 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(bufnr, EXTMARK_NS, lnum - 1, offset, {
    virt_text = { { string.rep(" ", padding) } },
    virt_text_pos = "inline",
    right_gravity = false,
  })
end

--- render table border
---@param bufnr integer
---@param lnum integer
---@param offset integer
local function highlight_delimiter(bufnr, lnum, offset)
  vim.api.nvim_buf_set_extmark(bufnr, EXTMARK_NS, lnum - 1, offset, {
    hl_group = config.border.hl,
    end_col = offset + 1,
  })
end

--- render table border
---@param bufnr integer
---@param lnum integer
---@param offset integer
---@param padding integer
local function render_border(bufnr, lnum, offset, padding)
  vim.api.nvim_buf_set_extmark(bufnr, EXTMARK_NS, lnum - 1, offset, {
    virt_text = { { string.rep(" ", padding) .. config.border.char, config.border.hl } },
    virt_text_pos = "overlay",
  })
end

--- render line
---@param bufnr integer
---@param lnum integer
---@param line_fields CsvFieldMetrics[]
---@param column_max_widths integer[]
local function render_line(bufnr, lnum, line_fields, column_max_widths)
  local offset = 0
  for i, field in ipairs(line_fields) do
    local colwidth = math.max(column_max_widths[i], config.min_column_width)
    local padding = colwidth - field.display_width + config.pack
    local border_padding = 0
    if field.is_number then
      -- numbers are right aligned
      render_left_padding(bufnr, lnum, offset, padding)
      border_padding = 0
    else
      -- text is left aligned
      -- if put an overlay after inline virtual text, need to add padding for the virtual text.
      render_right_padding(bufnr, lnum, offset, padding, field)
      border_padding = padding
    end

    if i < #line_fields then
      render_border(bufnr, lnum, offset + field.len, border_padding)
      -- highlight_delimiter(bufnr, lnum, offset + field.len)
    end
    offset = offset + field.len + 1
  end
end

--- start render
---@param preview_bufnr integer
---@param item { column_max_widths:number[],fields:CsvFieldMetrics[][] }
function M.start_render(preview_bufnr, item)
  local old_top = 1
  local old_bot = -1
  vim.api.nvim_set_decoration_provider(EXTMARK_NS, {
    on_win = function(_, winid, bufnr, _, _)
      if bufnr ~= preview_bufnr then
        return false
      end

      -- do not rerender when in insert mode
      local m = vim.api.nvim_get_mode()
      if string.find(m["mode"], "i") then
        return true
      end

      -- print(os.clock())
      local top = vim.fn.line("w0", winid)
      local bot = vim.fn.line("w$", winid)
      M.clear(bufnr, old_top - 1, old_bot)
      for i = top, bot do
        render_line(bufnr, i, item.fields[i], item.column_max_widths)
      end

      old_top = top or old_top
      old_bot = bot or old_bot
      return true
    end,
  })
end

function M.stop_render()
  vim.api.nvim_set_decoration_provider(EXTMARK_NS, {})
end

--- clear view
---@param bufnr integer
---@param linestart integer
---@param lineend integer
function M.clear(bufnr, linestart, lineend)
  vim.api.nvim_buf_clear_namespace(bufnr, EXTMARK_NS, linestart, lineend)
end

return M
