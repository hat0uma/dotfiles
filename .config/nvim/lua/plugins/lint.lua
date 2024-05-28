local ignore_buffers = {
  "copilot-chat",
}

return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters.markdownlint_cli2 = vim.tbl_extend("force", require("lint").linters.markdownlint, {
      cmd = string.gsub(require("lint").linters.markdownlint.cmd, "markdownlint", "markdownlint-cli2"),
    })

    require("lint").linters_by_ft = {
      sh = { "shellcheck" },
      python = { "mypy" },
      markdown = { "markdownlint_cli2" },
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

        if vim.tbl_contains(ignore_buffers, vim.fn.expand "%:p:t") then
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
