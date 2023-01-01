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
      local nvim_lsp = require "lspconfig"
      local navic = require "nvim-navic"
      local cmp_nvim_lsp = require "cmp_nvim_lsp"
      require "mason-lspconfig"
      local servers = {
        sumneko_lua = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        vimls = {},
        dockerls = {},
        pyright = {},
        rust_analyzer = {},
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy" },
        },
        powershell_es = {},
        denols = {
          root_dir = nvim_lsp.util.root_pattern "deno.json",
          init_options = {
            enable = true,
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                  ["https://cdn.nest.land"] = true,
                  ["https://crux.land"] = true,
                },
              },
            },
          },
        },
        gopls = {
          cmd = { vim.fn.expand "~/go/bin/gopls" },
        },
        cssls = {},
        omnisharp = {},
        tsserver = {},
      }

      local capabilities =
        vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), cmp_nvim_lsp.default_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
        require("plugins.lsp.format").on_attach(client, bufnr)
        require("plugins.lsp.keymaps").on_attach(client, bufnr)
      end

      local default_opts = { on_attach = on_attach, capabilities = capabilities }
      for name, opts in pairs(servers) do
        opts = vim.tbl_deep_extend("force", default_opts, opts or {})
        if name == "tsserver" then
          require("typescript").setup { server = opts }
        else
          nvim_lsp[name].setup(opts)
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
