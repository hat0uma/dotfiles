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
      ---@param bufnr integer
      ---@param item aerial.Symbol
      ---@param ctx any
      post_parse_symbol = function(bufnr, item, ctx)
        if item.name == "(anonymous struct)" then
          return false
        elseif item.name == "(anonymous enum)" then
          return false
        end
        return true
      end,
    }
  end,
  cmd = "AerialToggle",
}
