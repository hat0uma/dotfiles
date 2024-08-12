--- make client capabilies
---@return table
local function make_client_capabilies()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return capabilities
end

return {
  "p00f/clangd_extensions.nvim",
  "Hoffs/omnisharp-extended-lsp.nvim",
  "b0o/schemastore.nvim",
  "pmizio/typescript-tools.nvim",
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
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "plenary.nvim",
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },
  {
    "folke/neoconf.nvim",
    config = function()
      require("neoconf").setup({
        import = {
          vscode = false,
          coc = false,
          nlsp = false,
        },
      })
    end,
  },
  {
    "Fildo7525/pretty_hover",
    event = "LspAttach",
    config = function()
      require("pretty_hover").setup({ max_width = nil })
    end,
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
      require("mason-lspconfig")
      require("plugins.lsp.handlers").setup()

      --- create capabilities
      --- @type table
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- autocmd for lsp attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          assert(client, "client not found")

          -- vim.notify(string.format("  %s", client.name))
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
          require("plugins.lsp.format").on_attach(client, bufnr)
          require("plugins.lsp.keymap").on_attach(client, bufnr)
        end,
      })

      -- setup servers with lspconfig
      local servers = require("plugins.lsp.server").configurations
      for name, _opts in pairs(servers) do
        local opts = vim.tbl_deep_extend("force", { capabilities = capabilities }, _opts or {})
        if name == "gopls" and vim.fn.executable("gopls") == 1 then
          require("go").setup({
            lsp_cfg = opts,
            lsp_keymaps = false,
            diagnostic_hdlr = false,
          })
        else
          require("lspconfig")[name].setup(opts)
        end
      end

      -- others
      require("plugins.lsp.keymap").global_map()
      require("plugins.lsp.diagnostic").setup()
      -- require("plugins.null-ls").setup_sources { on_attach = on_attach }
      require("typescript-tools").setup({
        single_file_support = false,
        root_dir = require("lspconfig").util.root_pattern("tsconfig.json"),
      })
      require("clangd_extensions").setup({})
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      -- "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
      "mason-lspconfig.nvim",
      "neoconf.nvim",
      "clangd_extensions.nvim",
      "go.nvim",
      "typescript-tools.nvim",
      "ionide/Ionide-vim",
      "conform.nvim",
      "nvim-lint",
    },
    cond = not vim.g.vscode,
  },
}
