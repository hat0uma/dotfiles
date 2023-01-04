local M = {
  "jose-elias-alvarez/null-ls.nvim",
}

local has = function(files)
  return {
    condition = function(utils)
      return utils.root_has_file(files)
    end,
  }
end
local has_eslintrc = has { ".eslintrc.json" }
local has_prettierrc = has { ".prettierrc" }
local has_stylua = has { ".stylua.toml", "stylua.toml" }

--- @param options {on_attach:function}
function M.setup_sources(options)
  local nls = require "null-ls"
  local sources = {
    nls.builtins.formatting.stylua.with(has_stylua),
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.eslint_d.with(has_eslintrc),
    nls.builtins.formatting.eslint_d.with(has_eslintrc),
    nls.builtins.formatting.prettierd.with(has_prettierrc),
    nls.builtins.code_actions.refactoring.with {
      filetypes = { "go", "javascript", "lua", "python", "typescript", "c", "cpp" },
    },
  }
  nls.setup { sources = sources, on_attach = options.on_attach }
end

return M
