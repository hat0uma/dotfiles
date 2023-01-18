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
local prefer_venv = { prefer_local = ".venv/bin" }
local prefer_node_modules = { prefer_local = "node_modules/.bin" }

--- @param options {on_attach:function}
local function setup_sources(options)
  local nls = require "null-ls"
  local sources = {
    -- code actions
    nls.builtins.code_actions.refactoring.with {
      filetypes = { "go", "javascript", "lua", "python", "typescript", "c", "cpp" },
    },

    -- diagnostics
    nls.builtins.diagnostics.eslint_d.with(has_eslintrc),
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.mypy(prefer_venv),
    nls.builtins.diagnostics.flake8(prefer_venv),

    -- formatters
    nls.builtins.formatting.isort.with(prefer_venv),
    nls.builtins.formatting.black.with(prefer_venv),
    nls.builtins.formatting.eslint_d.with(has_eslintrc),
    nls.builtins.formatting.prettierd.with(prefer_node_modules),
    nls.builtins.formatting.stylua.with(has_stylua),
    nls.builtins.formatting.fixjson,
  }
  nls.setup { sources = sources, on_attach = options.on_attach }
end

setmetatable(M, { __index = { setup_sources = setup_sources } })
return M
