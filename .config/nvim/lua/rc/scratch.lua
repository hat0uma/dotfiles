local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Scratch", function()
    M.open()
  end, {})
end

---@type number?
local notification = nil

--- Notify message
---@param msg string
---@param level number?
local function notify(msg, level)
  notification = vim.notify(msg, level or vim.log.levels.INFO, {
    replace = notification,
    title = "Scratch",
  })
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
    notify("lazydev is not installed", vim.log.levels.WARN)
  end

  -- open
  vim.cmd("split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_set_option_value("winfixbuf", true, {})

  -- local library = {}
  -- table.insert(library, vim.env.VIMRUNTIME .. "/lua")
  -- vim.api.nvim_create_autocmd("LspAttach", {
  --   group = vim.api.nvim_create_augroup("scratch-lsp-setup", {}),
  --   callback = function(ev)
  --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
  --     if client and client.name == "lua_ls" then
  --       print("scratch-lsp-setup")
  --       ---@type table
  --       client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
  --         runtime = {
  --           version = "LuaJIT",
  --           path = { "?.lua", "?/init.lua" },
  --           pathStrict = true,
  --         },
  --         workspace = {
  --           checkThirdParty = false,
  --           library = library,
  --           ignoreDir = { "/lua" },
  --         },
  --       })
  --       client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  --     end
  --   end,
  --   buffer = buf,
  -- })

  -- launch language servers
  local matches = require("lspconfig.util").get_config_by_ft(vim.bo.filetype)
  ---@diagnostic disable-next-line: no-unknown
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
  return assert(load(code))()
end

--- Format result
---@param ... any
---@return string?
local function format_result(...)
  local result = { ... }
  if #result == 0 then
    return nil
  end

  local msg = {}
  if #result == 1 then
    table.insert(msg, vim.inspect(result[1]))
  else
    for i, v in ipairs(result) do
      table.insert(msg, string.format("%d: %s", i, vim.inspect(v)))
    end
  end
  return table.concat(msg, "\n")
end

--- Run code in the current buffer
function M.run()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local code = table.concat(lines, "\n")
  local result = format_result(eval(code))
  if not result then
    return
  end

  notify(result)
end

return M
