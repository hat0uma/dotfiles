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

function M.setup_sources(options)
  local null_ls = require "null-ls"
  local sources = {
    null_ls.builtins.formatting.stylua.with(has_stylua),
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.eslint_d.with(has_eslintrc),
    null_ls.builtins.formatting.eslint_d.with(has_eslintrc),
    null_ls.builtins.formatting.prettierd.with(has_prettierrc),
  }
  null_ls.setup { sources = sources, on_attach = options.on_attach }

  local group = vim.api.nvim_create_augroup("register_my_nullls_settings", {})
  vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
      null_ls.register(sources)
    end,
    group = group,
  })
end

return M
