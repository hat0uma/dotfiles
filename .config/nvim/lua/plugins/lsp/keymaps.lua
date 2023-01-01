local M = {}
function M.on_attach(client, bufnr)
  local lsp_document_symbols = function()
    require("telescope.builtin").lsp_document_symbols()
  end
  local lsp_workspace_symbol = function()
    require("telescope.builtin").lsp_dynamic_workspace_symbols()
  end
  local lsp_references = function()
    require("telescope.builtin").lsp_references()
  end
  local go_to_definition = function()
    if client.name == "omnisharp" then
      require("omnisharp_extended").telescope_lsp_definitions()
    else
      require("telescope.builtin").lsp_definitions()
    end
  end
  local rename = function()
    require "inc_rename"
    return ":IncRename " .. vim.fn.expand "<cword>"
  end

  local map_opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
  vim.keymap.set("n", "gd", go_to_definition, map_opts)
  vim.keymap.set("n", "gh", vim.lsp.buf.hover, map_opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, map_opts)
  vim.keymap.set("n", "gr", lsp_references, map_opts)
  vim.keymap.set("n", "<leader>s", "<Cmd>AerialToggle<CR>", map_opts)
  vim.keymap.set("n", "<leader>S", lsp_workspace_symbol, map_opts)
  vim.keymap.set("n", "<leader>rn", rename, { noremap = true, silent = true, buffer = bufnr, expr = true })
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, map_opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, map_opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, map_opts)
  vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, map_opts)
end
return M
