return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      sh = { "shellcheck" },
      python = { "mypy", "flake8" },
    }
    vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufReadPost", "TextChanged" }, {
      callback = function()
        local lint_status, lint = pcall(require, "lint")
        if lint_status then
          lint.try_lint()
        end
      end,
    })
  end,
}
