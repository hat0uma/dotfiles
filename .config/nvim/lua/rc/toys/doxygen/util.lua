local M = {}

--- Dump a table to a json file.
---@param tbl table
---@param name string
---@param open boolean
function M.dump_json(tbl, name, open)
  local json = vim.json.encode(tbl)
  local dir = vim.fn.stdpath("cache")
  local file = string.format("doxygen-%s.json", name)
  local path = vim.fs.joinpath(dir, file) ---@diagnostic disable-line
  local cmd = { "jq", "--indent", "2", "--sort-keys", "." }
  vim.system(cmd, { stdin = json }, function(obj)
    if obj.code ~= 0 then
      vim.notify(obj.stderr, vim.log.levels.ERROR)
      return
    end

    local f = assert(vim.uv.fs_open(path, "w", 438))
    assert(vim.uv.fs_write(f, obj.stdout, -1))
    assert(vim.uv.fs_close(f))
    if open then
      vim.schedule(function()
        vim.cmd("e! " .. path)
      end)
    end
  end)
end

--- Dump a table to a buffer.
---@param tbl table
---@return number bufnr
function M.dump_buf(tbl)
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.split(vim.inspect(tbl), "\n"))
  vim.api.nvim_win_set_buf(0, bufnr)
  return bufnr
end

return M
