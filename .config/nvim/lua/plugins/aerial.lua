return {
  "stevearc/aerial.nvim",
  config = function()
    require("aerial").setup {
      backends = {
        "lsp",
        "treesitter",
        "markdown",
        "man",
      },
      filter_kind = {
        "Class",
        "Constant",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
        "Object",
        "Array",
        "Package",
      },
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│",
        whitespace = "  ",
      },
    }
  end,
  cmd = "AerialToggle",
}
