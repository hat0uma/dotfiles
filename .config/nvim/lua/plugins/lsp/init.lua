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
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "wezterm-types", mods = { "wezterm" } },
        "plenary.nvim",
        { path = vim.fn.stdpath("config") .. "/lua/rc", words = { "rc" } },
      },
    },
  },
  { "DrKJeff16/wezterm-types", lazy = true },
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
    "ray-x/go.nvim",
    requires = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function() end,
    build = function()
      -- require("go.install").update_all_sync()
    end,
    ft = { "go", "gomod" },
    dependencies = {
      "ray-x/guihua.lua",
    },
  },
  {
    -- F# support
    "ionide/Ionide-vim",
    ft = { "fsharp", "fsharp_project" },
    config = function() end,
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
      require("plugins.lsp.handlers").setup()

      --- create capabilities
      --- @type table
      local capabilities = require("plugins.completion").get_lsp_capabilities()
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

          -- attach nvim-navic
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end

          -- attach codelens
          if client.server_capabilities.codeLensProvider then
            vim.cmd([[autocmd BufEnter,TextChanged,InsertLeave <buffer> lua vim.lsp.codelens.refresh({ bufnr = 0 })]])
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end

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
          vim.lsp.config(name, opts)
          vim.lsp.enable(name)
        end
      end

      -- others
      require("plugins.lsp.keymap").global_map()
      require("plugins.lsp.diagnostic").setup()
      require("typescript-tools").setup({
        single_file_support = true,
        root_dir = require("lspconfig").util.root_pattern({ "tsconfig.json", "package.json" }),
      })
      require("clangd_extensions").setup({})

      -- enable inlay hints
      vim.lsp.inlay_hint.enable()
      vim.api.nvim_create_user_command(
        "InlayHintsToggle",
        [[lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())]],
        {}
      )
    end,
    dependencies = {
      "none-ls.nvim",
      "SmiteshP/nvim-navic",
      "mason.nvim",
      "neoconf.nvim",
      "clangd_extensions.nvim",
      "typescript-tools.nvim",
      "conform.nvim",
    },
    cond = not vim.g.vscode,
  },
}
