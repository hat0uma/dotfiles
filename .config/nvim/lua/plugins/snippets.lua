local M = {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "kleber-swf/vscode-unity-code-snippets",
    "qjebbs/vscode-plantuml",
  },
  event = { "InsertEnter", "CmdlineEnter" },
}

function M.config()
  local ls = require "luasnip"
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node
  local c = ls.choice_node
  local d = ls.dynamic_node
  local r = ls.restore_node

  ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
  }

  ls.add_snippets("lua", {
    -- for vim
    s("printt", { t "print(vim.inspect(", i(1, "tbl"), t "))", i(0) }),
    s("printf", { t 'print(string.format("', i(1, "format"), t '",', i(2, "va_args"), t "))", i(0) }),
    s("tbl_filter", { t "vim.tbl_filter( function() return ", i(2, "expr"), t " end,", i(1, "tbl"), t ")", i(0) }),
    s("tbl_map", { t "vim.tbl_map( function() return ", i(2, "expr"), t " end,", i(1, "tbl"), t ")", i(0) }),
  })

  ls.filetype_extend("cs", { "csharp" })
  ls.filetype_extend("gina-commit", { "gitcommit" })
  require("luasnip.loaders.from_vscode").lazy_load {}
  require("luasnip.loaders.from_vscode").lazy_load { paths = vim.fn.stdpath "config" .. "/snippets" }
end

return M
