local M = {}
function M.on_attach(client, bufnr)
  local document_symbols = function()
    require("telescope.builtin").lsp_document_symbols()
  end

  local lsp_workspace_symbol = function()
    require("telescope.builtin").lsp_dynamic_workspace_symbols()
  end

  local references = function()
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

  local default_opts = { noremap = true, silent = true, buffer = bufnr }
  local keymaps = {
    { "n", "gD", vim.lsp.buf.declaration },
    { "n", "gD", vim.lsp.buf.declaration },
    { "n", "gd", go_to_definition },
    { "n", "gh", vim.lsp.buf.hover },
    { "n", "gi", vim.lsp.buf.implementation },
    { "n", "gr", references },
    { "n", "<leader>s", "<Cmd>AerialToggle<CR>" },
    { "n", "<leader>S", lsp_workspace_symbol },
    { "n", "<leader>D", vim.lsp.buf.type_definition },
    { "n", "[d", vim.diagnostic.goto_prev },
    { "n", "]d", vim.diagnostic.goto_next },
    { { "n", "v" }, "<leader>a", vim.lsp.buf.code_action },
    { "n", "<leader>rn", rename, { expr = true } },
  }

  for _, keymap in ipairs(keymaps) do
    local map = {
      mode = keymap[1],
      lhs = keymap[2],
      rhs = keymap[3],
      opts = keymap[4] or {},
    }
    map.opts = vim.tbl_extend("keep", map.opts, default_opts)
    vim.keymap.set(map.mode, map.lhs, map.rhs, map.opts)
  end
end

return M
