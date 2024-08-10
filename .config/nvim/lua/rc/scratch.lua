local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Scratch", function()
    M.open()
  end, {})
end

function M.open()
  local bufname = vim.fn.tempname() .. ".lua"

  -- create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, bufname)
  vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })

  -- load lazydev
  local ok, _ = pcall(require, "lazydev")
  if not ok then
    vim.notify("lazydev is not installed", vim.log.levels.WARN)
  end

  -- open
  vim.cmd("split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- launch language servers
  local matches = require("lspconfig.util").get_config_by_ft(vim.bo.filetype)
  for _, config in ipairs(matches) do
    config.launch(buf)
  end

  -- set run keymap
  vim.keymap.set("n", "<leader><CR>", function()
    M.run()
  end, { buffer = buf })
end

--- Evaluate code
---@param code string
---@return any
local function eval(code)
  return assert(loadstring(code))()
end

--- Run code in the current buffer
function M.run()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local code = table.concat(lines, "\n")

  local result = eval(code)
  if result then
    vim.print(result)
  end
end

return M
