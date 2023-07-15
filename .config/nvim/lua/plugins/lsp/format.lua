local M = {}
local format_disable_clients = {
  "tsserver",
  "lua_ls",
}

M.format_on_save = {}
M.format_on_save.mode = "Buffer" --- @type "Hunks"|"Buffer"
M.format_on_save.enabled = true
M.format_on_save.handle = function()
  if not M.format_on_save.enabled then
    return
  end
  if M.format_on_save.mode == "Buffer" then
    M.format_async_all_client(0, { on_end = vim.cmd.write })
  else
    M.format_hunks(0, { on_end = vim.cmd.write })
  end
end
M.format_on_save.toggle = function()
  M.format_on_save.enabled = not M.format_on_save.enabled
end
M.format_on_save.enable = function()
  M.format_on_save.enabled = true
end

M.format_on_save.disable = function()
  M.format_on_save.enabled = false
end

--- format async
---@param client lsp.Client
---@param bufnr integer
---@param opts { range:table,on_end:function }
M.format_async = function(client, bufnr, opts)
  vim.bo[bufnr].modifiable = false
  local method ---@type string
  local params ---@type table
  if opts.range then
    method = "textDocument/rangeFormatting"
    params = vim.lsp.util.make_formatting_params()
    params = vim.lsp.util.make_given_range_params(opts.range["start"], opts.range["end"], bufnr, client.offset_encoding)
  else
    method = "textDocument/formatting"
    params = vim.lsp.util.make_formatting_params()
  end
  local handler = function(err, result)
    vim.bo[bufnr].modifiable = true
    if not result then
    else
      vim.lsp.util.apply_text_edits(result, bufnr, client.offset_encoding)
    end
    opts.on_end()
  end
  client.request(method, params, handler, bufnr)
end

--- format async
---@param bufnr integer
---@param opts { range:table,on_end:function }
M.format_async_all_client = function(bufnr, opts)
  local method = opts.range and "textDocument/rangeFormatting" or "textDocument/formatting"
  local clients = vim.lsp.get_active_clients { id = nil, bufnr = bufnr, name = nil }
  clients = vim.tbl_filter(function(client)
    return client.supports_method(method) and not vim.tbl_contains(format_disable_clients, client.name)
  end, clients)
  local do_format
  do_format = function(idx, client)
    if not client then
      opts.on_end()
      return
    end
    M.format_async(client, bufnr, {
      range = opts.range,
      on_end = function()
        do_format(next(clients, idx))
      end,
    })
  end
  do_format(next(clients))
end

--- format hunks async
---@param bufnr integer
---@param opts { on_end:function }
M.format_hunks = function(bufnr, opts)
  local hunks = require("gitsigns").get_hunks()
  hunks = vim.tbl_filter(function(hunk)
    return hunk.type == "add" or hunk.type == "change"
  end, hunks)
  local do_format
  do_format = function(idx, hunk)
    if not hunk then
      opts.on_end()
      return
    end
    local start_line = hunk.added.start
    local end_line = hunk.added.start + hunk.added.count - 1
    local range = {
      ["start"] = { start_line, 0 },
      ["end"] = { end_line, vim.fn.col { end_line, "$" } - 2 },
    }
    M.format_async_all_client(bufnr, {
      range = range,
      on_end = function()
        do_format(next(hunks, idx))
      end,
    })
  end
  do_format(next(hunks))
end

function M.on_attach(client, bufnr)
  if vim.tbl_contains(format_disable_clients, client.name) then
    return
  end

  if client.server_capabilities.documentFormattingProvider then
    -- vim.api.nvim_buf_create_user_command(bufnr, "Format", M.format, {})
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   buffer = bufnr,
    --   callback = function()
    --     M.format_on_save.handle(client)
    --   end,
    -- })
  end
end

function M.save_without_format()
  if M.format_on_save.enabled then
    M.format_on_save.disable()
    vim.cmd.write()
    M.format_on_save.enable()
  else
    vim.cmd.write()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("FormatOnSaveToggle", M.format_on_save.toggle, {})
  vim.api.nvim_create_user_command("FormatOnSaveDisable", M.format_on_save.disable, {})
  vim.api.nvim_create_user_command("FormatOnSaveEnable", M.format_on_save.enable, {})
end

return M
