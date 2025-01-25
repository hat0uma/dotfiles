return {
  {
    "vim-jp/vimdoc-ja",
    event = { "CmdlineEnter" },
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
        },
      })
    end,
  },
  {
    "Wansmer/treesj",
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
        max_join_length = 999,
      })
    end,
    keys = {
      { "<leader>j", "<cmd>TSJToggle<cr>" },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({})
    end,
  },
  {
    "haya14busa/vim-asterisk",
    config = function()
      vim.keymap.set("", "*", "<Plug>(asterisk-z*)", {})
      vim.keymap.set("", "#", "<Plug>(asterisk-z#)", {})
      vim.keymap.set("", "g*", "<Plug>(asterisk-gz*)", {})
      vim.keymap.set("", "g#", "<Plug>(asterisk-gz#)", {})
    end,
    keys = {
      { "*", mode = "" },
      { "#", mode = "" },
      { "g*", mode = "" },
      { "g#", mode = "" },
    },
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },

  {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({ default = true })
    end,
  },
  {
    "echasnovski/mini.diff",
    config0 = function()
      require("mini.diff").setup()
    end,
  },
  {
    "hat0uma/project.nvim",
    config = function()
      require("project_nvim").setup({
        patterns = {
          ".git",
          ".svn",
        },
        detection_methods = { "pattern", "lsp" },
      })
    end,
    event = "BufReadPost",
  },
  {
    "danymat/neogen",
    keys = {
      {
        "<Leader>d",
        function()
          require("neogen").generate({})
        end,
        "n",
      },
    },
    config = function()
      require("neogen").setup({
        enabled = true,
        languages = {
          cs = { template = { annotation_convention = "xmldoc" } },
          typescript = { template = { annotation_convention = "tsdoc" } },
          typescriptreact = { template = { annotation_convention = "tsdoc" } },
        },
      })
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function()
          vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = true })
        end,
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
    keys = {
      { "gcc", mode = "n" },
      { "gco", mode = "n" },
      { "gcO", mode = "n" },
      { "gcA", mode = "n" },
      { "gc", mode = "v" },
    },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    cond = not vim.g.vscode,
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
      vim.g.matchup_matchpref = {
        html = { tagnameonly = 1 },
        typescriptreact = { tagnameonly = 1 },
      }
    end,
  },
  {
    "uga-rosa/translate.nvim",
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set("v", "<leader>tj", "<Cmd>Translate JA<CR><Esc>", opts)
      vim.keymap.set("n", "<leader>tj", "viw:Translate JA<CR><Esc>", opts)
      -- translate to English and replace
      vim.keymap.set("v", "<leader>te", "<Cmd>Translate EN -output=replace<CR>", opts)
      vim.keymap.set("n", "<leader>te", "viw:Translate EN -output=replace<CR>", opts)
    end,
    config = function()
      require("translate").setup({
        default = {
          command = "google",
          output = "floating",
        },
      })
    end,
    cmd = { "Translate" },
  },
  {
    "tyru/open-browser.vim",
    config = function()
      vim.keymap.set({ "n", "v" }, "gx", "<Plug>(openbrowser-smart-search)", {})
    end,
    keys = {
      { "gx", mode = { "n", "v" } },
    },
  },
  { "gpanders/nvim-parinfer", ft = { "lisp", "yuck" } },
  -- { "/elkowar/yuck.vim", ft = { "yuck" } },
  { "PProvost/vim-ps1", ft = { "ps1" } },
  { "hashivim/vim-vagrant", ft = { "ruby" } },
  { "cespare/vim-toml", ft = { "toml" } },
  { "kevinoid/vim-jsonc", ft = { "json", "jsonc" } },
  { "aklt/plantuml-syntax", ft = { "plantuml" } },
  {
    "weirongxu/plantuml-previewer.vim",
    ft = { "plantuml" },
    dependencies = {
      "open-browser.vim",
      "plantuml-syntax",
    },
  },

  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "kyazdani42/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
    cmd = { "Octo" },
  },
  {
    "mg979/vim-visual-multi",
    config = function()
      -- \\z normal
    end,
    keys = { "<C-n>", "<C-Down>", "<C-Up>" },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    cond = not vim.g.vscode,
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css",
          "scss",
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
        },
      })
    end,
    event = "BufReadPost",
  },
  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
  },
  {
    "nmac427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({})
    end,
    event = "BufReadPre",
    cond = not vim.g.vscode,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "trouble.nvim",
    },
    config = function()
      require("todo-comments").setup({})
    end,
  },
  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          { sign = { namespace = { "diagnostic" }, maxwidth = 1, colwidth = 2 } },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " " } },
          {
            sign = {
              namespace = { "gitsign" },
              maxwidth = 1,
              colwidth = 2,
            },
          },
          {
            text = {
              function(args)
                return builtin.foldfunc(args) .. " "
              end,
            },
            click = "v:lua.ScFa",
          },
        },
      })
    end,
    event = "VeryLazy",
  },
  { "stevearc/profile.nvim" },
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup({
        parser = {
          comments = { "#", "//" },
        },
      })
    end,
    cmd = {
      "CsvViewEnable",
      "CsvViewDisable",
      "CsvViewToggle",
    },
  },
  {
    "chipsenkbeil/distant.nvim",
    branch = "v0.3",
    config = function()
      require("distant"):setup({})
    end,
    cmd = {
      "DistantInstall",
      "DistantClientVersion",
      "DistantConnect",
      "DistantLaunch",
    },
  },
  {
    "lbrayner/vim-rzip",
    ft = { "zip" },
  },
  {
    "hat0uma/prelive.nvim",
    config = function()
      require("prelive").setup({ server = { port = 0 } })
    end,
    cmd = {
      "PreLiveGo",
      "PreLiveStatus",
      "PreLiveClose",
      "PreLiveCloseAll",
      "PreLiveLog",
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("snacks").setup({
        bigfile = {
          enabled = true,
          notify = true,
          size = 1 * 1024 * 1024,
          -- Enable or disable features when big file detected
          ---@param ctx {buf: number, ft:string}
          setup = function(ctx)
            vim.cmd([[NoMatchParen]])
            Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
            vim.schedule(function()
              vim.bo[ctx.buf].syntax = ctx.ft
            end)
            require("illuminate.engine").stop_buf(ctx.buf)
            require("indent_blankline.commands").disable()
          end,
        },
        notifier = { enabled = true },
        -- quickfile = { enabled = true },
        -- statuscolumn = { enabled = true },
        -- words = { enabled = true },
      })
    end,
  },
  {
    "hat0uma/doxygen-previewer.nvim",
    config = function()
      require("doxygen-previewer").setup({})
    end,
    dependencies = { "hat0uma/prelive.nvim" },
    cmd = {
      "DoxygenOpen",
      "DoxygenUpdate",
      "DoxygenStop",
      "DoxygenLog",
      "DoxygenTempDoxyfileOpen",
    },
  },
  {
    "mattn/vim-maketable",
    cmd = {
      "MakeTable",
      "UnmakeTable",
    },
  },
  {
    "RaafatTurki/hex.nvim",
    config = function()
      require("hex").setup()
    end,
    cmd = {
      "HexDump",
      "HexAssemble",
      "HexToggle",
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup({
        engines = {
          ripgrep = { extraArgs = "--hidden" },
        },
      })
    end,
    cmd = { "GrugFar" },
  },
  {
    "hat0uma/UnityEditor.nvim",
    config = function()
      require("unity-editor").setup({ autorefresh = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function()
          vim.keymap.set("n", "<leader>up", "<Cmd>Unity playmode toggle<CR>", { buffer = true })
          vim.keymap.set("n", "<leader>ur", "<Cmd>Unity refresh<CR>", { buffer = true })
        end,
      })
    end,
    ft = { "cs" },
  },
}
