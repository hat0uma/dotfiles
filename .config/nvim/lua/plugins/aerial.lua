local function get_winids()
  local winids = vim.api.nvim_tabpage_list_wins(0)
  return vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end, winids)
end

local function toggle()
  if #get_winids() == 1 then
    require("aerial").toggle { direction = "left" }
  else
    require("aerial").toggle { direction = "float" }
  end
end

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
      },
      close_on_select = true,
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
      ---@return boolean
      post_parse_symbol = function(bufnr, item, ctx)
        if item.name == "(anonymous struct)" then
          return false
        elseif item.name == "(anonymous enum)" then
          return false
        end
        return true
      end,
      layout = {
        default_direction = "float",
        max_width = 0.5,
      },
      float = {
        relative = "win",
        override = function(conf, source_winid)
          local padding = 1
          conf.anchor = "NE"
          conf.row = padding
          conf.col = vim.api.nvim_win_get_width(source_winid) - padding
          return conf
        end,
      },
    }
  end,
  keys = {
    { "<leader>s", toggle, mode = { "n" } },
  },
  cmd = "AerialToggle",
}
