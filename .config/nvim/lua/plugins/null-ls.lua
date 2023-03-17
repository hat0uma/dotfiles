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
local find_cwd = function(files)
  return {
    cwd = function()
      return vim.fs.dirname(vim.fs.find(files, { upward = false })[1])
    end,
  }
end
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
    require("go.null_ls").gotest(),
    require("go.null_ls").gotest_action(),
    nls.builtins.diagnostics.golangci_lint.with(find_cwd { "go.mod" }),

    -- diagnostics
    nls.builtins.diagnostics.eslint_d.with(find_cwd { ".eslintrc.json" }),
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.mypy.with(prefer_venv),
    nls.builtins.diagnostics.flake8.with(prefer_venv),

    -- formatters
    nls.builtins.formatting.isort.with(prefer_venv),
    nls.builtins.formatting.black.with(prefer_venv),
    nls.builtins.formatting.eslint_d.with(find_cwd { ".eslintrc.json" }),
    nls.builtins.formatting.prettierd.with(find_cwd { ".prettierrc" }),
    nls.builtins.formatting.stylua.with(has_stylua),
    nls.builtins.formatting.fixjson,
  }
  nls.setup { sources = sources, on_attach = options.on_attach }
end

setmetatable(M, { __index = { setup_sources = setup_sources } })
return M
