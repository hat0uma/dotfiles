return {
  setup = function()
    vim.diagnostic.config({
      virtual_lines = false,
      virtual_text = true,
      -- underline = {
      --   severity = { min = vim.diagnostic.severity.HINT },
      -- },
      -- virtual_text = {
      --   severity = { min = vim.diagnostic.severity.WARN },
      -- },
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
    })
  end,

  vim.api.nvim_create_user_command("DiagnosticShowMode", function(opts)
    local mode = opts.fargs[1] --- @type any
    if mode == "virtual_lines" then
      vim.diagnostic.config({
        virtual_lines = true,
        virtual_text = false,
        jump = { float = false },
      })
    elseif mode == "virtual_text" then
      vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = true,
        jump = { float = true },
      })
    else
      vim.notify("unknown argument " .. mode, vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function(arg_lead, _, _)
      return vim.tbl_filter(function(item)
        return vim.startswith(item, arg_lead)
      end, { "virtual_lines", "virtual_text" })
    end,
  }),
}
