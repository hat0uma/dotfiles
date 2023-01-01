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
      },
      severity_sort = true,
    }

    vim.cmd [[sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=]]
    vim.cmd [[sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=]]
    vim.cmd [[sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=]]
    vim.cmd [[sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=]]
  end,
}
