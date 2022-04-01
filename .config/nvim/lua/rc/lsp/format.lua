local gitsigns = require "gitsigns"

function _G.test_format_change_only()
  local hunks = gitsigns.get_hunks()

  local positions = {}
  for _, hunk in ipairs(hunks) do
    local start_pos = { hunk.added.start, 0 }
    local end_row = hunk.added.start + hunk.added.count - 1
    local end_pos = { end_row, vim.fn.col { end_row, "$" } - 1 }
    table.insert(positions, { start_pos = start_pos, end_pos = end_pos })
  end

  print(vim.inspect(positions))
  for _, pos in ipairs(positions) do
    vim.lsp.buf.range_formatting({}, pos.start_pos, pos.end_pos)
  end
end
