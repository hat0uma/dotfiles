local M = {}

function M.region_to_text(region)
  local text = ""
  local maxcol = vim.v.maxcol
  for line, cols in vim.spairs(region) do
    local endcol = cols[2] == maxcol and -1 or cols[2]
    local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
    text = ("%s%s\n"):format(text, chunk)
  end
  return text
end

function M.get_visual_selection()
  local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
  return M.region_to_text(r)
end

return M
