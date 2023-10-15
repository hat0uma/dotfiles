local M = {}
local ALIGN_NS = vim.api.nvim_create_namespace "csv_align"
local BORDER_NS = vim.api.nvim_create_namespace "csv_border"

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
---@param column string
local function render_right_padding(bufnr, lnum, offset, padding, column)
  vim.api.nvim_buf_set_extmark(bufnr, ALIGN_NS, lnum - 1, offset + string.len(column), {
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
  vim.api.nvim_buf_set_extmark(bufnr, ALIGN_NS, lnum - 1, offset, {
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
  vim.api.nvim_buf_set_extmark(bufnr, BORDER_NS, lnum - 1, offset, {
    hl_group = config.border.hl,
    end_col = offset + 1,
  })
end

---@param bufnr integer
---@param lnum integer
---@param offset integer
---@param colwidth integer
---@param column string
local function render_field(bufnr, lnum, offset, colwidth, column)
  local strwidth = vim.fn.strdisplaywidth(column)
  local padding = colwidth - strwidth + config.pack
  if padding <= 0 then
    return
  end

  if tonumber(column) then
    render_left_padding(bufnr, lnum, offset, padding)
  else
    render_right_padding(bufnr, lnum, offset, padding, column)
  end
end

--- render table border
---@param bufnr integer
---@param lnum integer
---@param offset integer
local function render_border(bufnr, lnum, offset)
  vim.api.nvim_buf_set_extmark(bufnr, BORDER_NS, lnum - 1, offset, {
    virt_text = { { config.border.char, config.border.hl } },
    virt_text_pos = "overlay",
  })
end

--- render line
---@param bufnr integer
---@param lnum integer
---@param columns string[]
---@param column_max_width integer[]
function M.render_line(bufnr, lnum, columns, column_max_width)
  local offset = 0
  for i, column in ipairs(columns) do
    local colwidth = math.max(column_max_width[i], config.min_column_width)
    render_field(bufnr, lnum, offset, colwidth, column)

    if i < #columns then
      highlight_delimiter(bufnr, lnum, offset + string.len(column))
      -- render_border(bufnr, lnum, offset)
    end
    offset = offset + string.len(column) + 1
  end
end

--- clear view
---@param bufnr integer
function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ALIGN_NS, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, BORDER_NS, 0, -1)
end

return M
