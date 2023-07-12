local M = {}
M.format = function()
  vim.lsp.buf.format { timeout_ms = 7000 }
end

M.format_on_save = {}
M.format_on_save.enabled = true
M.format_on_save.handle = function(client)
  if M.format_on_save.enabled then
    M.format()
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

local format_disable_clients = {
  "tsserver",
  "lua_ls",
}

function M.on_attach(client, bufnr)
  if vim.tbl_contains(format_disable_clients, client.name) then
    return
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_buf_create_user_command(bufnr, "Format", M.format, {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        M.format_on_save.handle(client)
      end,
    })
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
