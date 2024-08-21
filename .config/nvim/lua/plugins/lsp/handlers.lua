local M = {}

function M.setup()
  vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    if err then
      vim.api.nvim_err_writeln("Failed to execute textDocument/definition : " .. err.message)
      return
    end

    if result == nil or vim.tbl_isempty(result) then
      return
    end

    local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding

    -- fix zipfile:/// -> zipfile:// on windows
    -- for yarn pnp
    for _, r in ipairs(result) do
      if rc.sys.is_windows and r.targetUri and vim.startswith(r.targetUri, "zipfile:///") then
        r.targetUri = string.gsub(r.targetUri, "zipfile:///", "zipfile://")
      end
    end

    local loclist = vim.lsp.util.locations_to_items(result, offset_encoding)
    if #loclist == 1 then
      vim.lsp.util.jump_to_location(loclist[1].user_data, offset_encoding, true)
    else
      vim.fn.setloclist(0, loclist, " ")
      vim.cmd("lopen")
    end
  end
end

return M
