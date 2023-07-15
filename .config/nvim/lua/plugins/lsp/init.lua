local function toSnakeCase(str)
  return string.gsub(str, "%s*[- ]%s*", "_")
end

return {
  "p00f/clangd_extensions.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",
  "b0o/schemastore.nvim",
  "pmizio/typescript-tools.nvim",
  -- "jose-elias-alvarez/typescript.nvim",
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
        pathStrict = true,
        setup_jsonls = false,
        lspconfig = true,
      }
    end,
  },
  {
    "Fildo7525/pretty_hover",
    event = "LspAttach",
    opts = {},
  },
  {
    "ray-x/go.nvim",
    requires = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function() end,
    build = function()
      -- require("go.install").update_all_sync()
    end,
    dependencies = {
      "ray-x/guihua.lua",
    },
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

      --- @type table
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local on_attach = function(client, bufnr)
        -- vim.notify(string.format("  %s", client.name))
        --- https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
        if client.name == "omnisharp" or client.name == "omnisharp_mono" then
          local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
          for i, v in ipairs(tokenModifiers) do
            tokenModifiers[i] = toSnakeCase(v)
          end
          local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
          for i, v in ipairs(tokenTypes) do
            tokenTypes[i] = toSnakeCase(v)
          end
        end
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
        elseif name == "omnisharp" and vim.fn.has "win64" ~= 1 then
          require("lspconfig")["omnisharp_mono"].setup(opts)
        elseif name == "clangd" then
          require("clangd_extensions").setup { server = opts }
        elseif name == "gopls" and vim.fn.executable "gopls" == 1 then
          require("go").setup {
            lsp_cfg = opts,
            lsp_keymaps = false,
            lsp_on_attach = opts.on_attach,
            lsp_diag_hdlr = false,
          }
        else
          require("lspconfig")[name].setup(opts)
        end
      end

      --- https://github.com/neovim/nvim-lspconfig/issues/2366
      vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
        local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
        local bufnr = vim.api.nvim_get_current_buf()
        vim.diagnostic.reset(ns, bufnr)
        return true
      end

      require("plugins.lsp.format").setup()
      require("plugins.lsp.diagnostic").setup()
      require("plugins.null-ls").setup_sources { on_attach = on_attach }
      require("typescript-tools").setup { on_attach = on_attach }
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
      "mason-lspconfig.nvim",
      "neodev.nvim",
      "clangd_extensions.nvim",
      "go.nvim",
      "typescript-tools.nvim",
    },
  },
}
