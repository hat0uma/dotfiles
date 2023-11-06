return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      sh = { "shellcheck" },
      python = { "mypy", "flake8" },
      markdown = { "markdownlint" },
      -- lua = { "luacheck" },
    }
    local actionlint = require("lint").linters.actionlint
    -- actionlint.args = { "-format", "{{json .}}", "-" }
    actionlint.stdin = false
    vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufReadPost", "TextChanged" }, {
      callback = function()
        local lint_status, lint = pcall(require, "lint")
        if not lint_status then
          return
        end

        local buf = vim.api.nvim_buf_get_name(0)
        if string.find(buf, "%.github/workflows/.*%.yml") then
          lint.try_lint("actionlint", { cwd = vim.loop.cwd() })
        else
          lint.try_lint(nil, { cwd = vim.loop.cwd() })
        end
      end,
    })
  end,
}
