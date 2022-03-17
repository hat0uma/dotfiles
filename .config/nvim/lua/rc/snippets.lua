local M = {}
function M.config()
  local ls = require "luasnip"
  ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
  }

  ls.filetype_extend("cs", { "csharp" })
  require("luasnip.loaders.from_vscode").lazy_load {}
end

return M
