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
local has_stylua = has({ ".stylua.toml", "stylua.toml" })
local prefer_venv = { prefer_local = ".venv/bin" }
local prefer_node_modules = { prefer_local = "node_modules/.bin" }

return {
  "nvimtools/none-ls.nvim",
  config = function()
    local nls = require("null-ls")
    local sources = {
      nls.builtins.diagnostics.golangci_lint.with(find_cwd({ "go.mod" })),
      nls.builtins.diagnostics.selene.with(has({ ".selene.toml", "selene.toml" })),
      nls.builtins.code_actions.refactoring.with({
        filetypes = {
          "go",
          "javascript",
          -- "lua",
          "python",
          "typescript",
          "c",
          "cpp",
        },
      }),

      -- nls.builtins.diagnostics.eslint_d.with(find_cwd({ ".eslintrc.json" })),
      -- nls.builtins.diagnostics.mypy.with(prefer_venv),
      -- nls.builtins.diagnostics.flake8.with(prefer_venv),
    }
    nls.setup({ sources = sources })
  end,
}
