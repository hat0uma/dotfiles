local M = {}

--- move cursor
---@param name string
function M.find(name)
  local lines = vim.fn.line("$")
  for i = 1, lines, 1 do
    local entry = require("oil").get_entry_on_line(0, i)
    if entry and entry.name == name then
      vim.cmd(string.format("%d", i))
      break
    end
  end
end

--- Open Oil
function M.open()
  local state = require("plugins.oil.state")
  require("plugins.oil.history").clear()

  local buf = vim.api.nvim_buf_get_name(0)
  if vim.fn.filereadable(buf) ~= 0 then
    state.filename = vim.fs.basename(buf)
    state.dir = vim.fs.dirname(buf)
  else
    state.filename = ""
    state.dir = vim.uv.cwd()
  end

  -- move cursor
  vim.api.nvim_create_autocmd("User", {
    pattern = "OilEnter",
    callback = vim.schedule_wrap(function()
      M.find(state.filename)
    end),
    group = vim.api.nvim_create_augroup("my-oil-settings", {}),
    once = true,
  })

  if state.direction == "float" then
    require("oil").open_float(state.dir)
  elseif state.direction == "tab" then
    vim.cmd.tabedit(state.dir)
  else
    require("oil").open_float(state.dir)
    state.direction = "float"
  end
end

return M
