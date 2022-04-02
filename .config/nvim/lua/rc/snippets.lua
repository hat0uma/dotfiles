local M = {}
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
    -- print table
    s("printt", {
      t "print(vim.inspect(",
      i(1, "tbl"),
      t "))",
      i(0),
    }),
    -- printf
    s("printf", {
      t 'print(string.format("',
      i(1, "format"),
      t '",',
      i(2, "va_args"),
      t "))",
      i(0),
    }),
  })

  ls.filetype_extend("cs", { "csharp" })
  require("luasnip.loaders.from_vscode").lazy_load {}
end

return M
