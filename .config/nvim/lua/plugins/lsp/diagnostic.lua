return {
  setup = function()
    vim.diagnostic.config {
      underline = {
        severity = { min = vim.diagnostic.severity.HINT },
      },
      virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
      },
      signs = {
        severity = { min = vim.diagnostic.severity.HINT },
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
      severity_sort = true,
      jump = {
        float = true,
      },
    }
  end,
}
