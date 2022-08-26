require("trouble").setup {
  padding = false,
  auto_preview = false,
  workspace_diagnostics_severity = { min = vim.diagnostic.severity.HINT },
  document_diagnostics_severity = { min = vim.diagnostic.severity.HINT },
}

local current_mode = "document_diagnostics"
local function toggle()
  require("trouble").toggle { mode = current_mode }
end

local function change_mode()
  current_mode = current_mode == "document_diagnostics" and "workspace_diagnostics" or "document_diagnostics"
  require("trouble").open { mode = current_mode }
end

function _G.trouble_winbar()
  return "%#Grey# " .. current_mode
end

vim.keymap.set("n", "<leader>d", toggle, { noremap = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Trouble",
  callback = function()
    local opts = { noremap = true, buffer = true }
    vim.keymap.set("n", "<leader><leader>", change_mode, opts)
    vim.wo.winbar = "%!v:lua.trouble_winbar()"
  end,
})
