local M = {
  "p00f/clangd_extensions.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",
  "jose-elias-alvarez/typescript.nvim",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
    cmd = { "Mason", "MasonInstall" },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup {
        library = {
          enabled = true,
          runtime = true,
          types = true,
          plugins = true,
        },
        setup_jsonls = false,
        lspconfig = true,
      }
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      require "mason-lspconfig"

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
        require("plugins.lsp.format").on_attach(client, bufnr)
        require("plugins.lsp.keymap").on_attach(client, bufnr)
      end
      local default_opts = { on_attach = on_attach, capabilities = capabilities }

      local servers = require("plugins.lsp.server").configurations
      for name, opts in pairs(servers) do
        opts = vim.tbl_deep_extend("force", default_opts, opts or {})
        if name == "tsserver" then
          require("typescript").setup { server = opts }
        else
          require("lspconfig")[name].setup(opts)
        end
      end

      require("plugins.lsp.format").setup()
      require("plugins.lsp.diagnostic").setup()
      require("plugins.null-ls").setup_sources { on_attach = on_attach }
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
      "mason-lspconfig.nvim",
      "neodev.nvim",
    },
  },
}
return M
