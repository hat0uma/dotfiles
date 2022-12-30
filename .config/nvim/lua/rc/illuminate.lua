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
    "Trouble",
  },
}
