local M = {}

M.oldfiles = function(opts)
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  local current_buffer = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buffer)
  local results = {}

  -- get all buffers
  local bufnrs = vim.api.nvim_list_bufs()
  table.sort(bufnrs, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)
  for _, bufnr in ipairs(bufnrs) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local buf_stats = vim.api.nvim__buf_stats(bufnr)
    local open_by_lsp = buf_stats.current_lnum == 0
    local file = vim.uv.fs_realpath(bufname)
    if not open_by_lsp and file and bufnr ~= current_buffer then
      table.insert(results, file)
    end
  end

  -- get all oldfiles
  for _, file in ipairs(vim.v.oldfiles) do
    local path = vim.uv.fs_realpath(file)
    if path and not vim.tbl_contains(results, path) and path ~= current_file then
      table.insert(results, path)
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Oldfiles",
      __locations_input = true,
      finder = finders.new_table({
        results = results,
        entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
      }),
      ---@diagnostic disable-next-line: no-unknown
      sorter = conf.file_sorter(opts),
      ---@diagnostic disable-next-line: no-unknown
      previewer = conf.grep_previewer(opts),
    })
    :find()
end

return M
