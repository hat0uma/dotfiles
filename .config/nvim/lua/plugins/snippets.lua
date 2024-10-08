return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "kleber-swf/vscode-unity-code-snippets",
      "qjebbs/vscode-plantuml",
    },
    cond = not vim.g.vscode,
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local r = ls.restore_node

      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
      })

      ls.add_snippets("lua", {
        -- for vim
        s(
          "tbl_filter",
          { t("vim.tbl_filter( function() return "), i(2, "expr"), t(" end,"), i(1, "tbl"), t(")"), i(0) }
        ),
        s("tbl_map", { t("vim.tbl_map( function() return "), i(2, "expr"), t(" end,"), i(1, "tbl"), t(")"), i(0) }),
      })

      ls.filetype_extend("cs", { "csharp" })
      ls.filetype_extend("gina-commit", { "gitcommit" })
      ls.filetype_extend("NeogitCommitMessage", { "gitcommit" })
      require("luasnip.loaders.from_vscode").lazy_load({})
      require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },
  {
    "glepnir/template.nvim",
    cmd = { "Template", "TemProject" },
    config = function()
      require("template").setup({
        temp_dir = vim.fn.expand("~/.config/nvim/template"),
      })
    end,
  },
}
