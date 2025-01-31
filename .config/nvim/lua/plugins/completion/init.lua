local provider = require("plugins.completion.cmp")
local M = provider.spec

local keys = {
  "get_lsp_capabilities",
}

return setmetatable(M, {
  __index = function(_, k)
    if vim.tbl_contains(keys, k) then
      return provider[k]
    end
  end,
})
