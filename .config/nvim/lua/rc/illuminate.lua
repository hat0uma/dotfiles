require("illuminate").configure {
  providers = {
    "lsp",
    "treesitter",
    "regex",
  },
  delay = 100,
  filetypes_denylist = {
    "gina-status",
    "gina-commit",
    "TelescopePrompt",
    "toggleterm",
    "terminal",
    "lir",
  },
}
local aug = vim.api.nvim_create_augroup("rc_illuminate_arg", {})
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.cmd [[
      hi! link illuminatedWord CurrentWord
      hi! link illuminatedWordRead CurrentWord
      hi! link illuminatedWordWrite CurrentWord
      hi! link illuminatedWordText CurrentWord
    ]]
  end,
  group = aug,
})
