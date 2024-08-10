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
    "lukas-reineke/indent-blankline.nvim",
    cond = not vim.g.vscode,
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
        },
        exclude = {
          filetypes = {
            "help",
            "toggleterm",
            "terminal",
            "TelescopePrompt",
            "packer",
            "translator",
          },
        },
      })
    end,
    event = "BufReadPre",
  },

  {
    "Wansmer/treesj",
    config = function()
      require("treesj").setup({ use_default_keymaps = false })
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
    "nvim-pack/nvim-spectre",
    config = function()
      require("spectre").setup({
        default = {
          find = {
            cmd = "rg",
            options = { "ignore-case", "hidden" },
          },
          replace = { cmd = "sed" },
        },
      })
    end,
    keys = {
      {
        "<leader>c",
        function()
          require("spectre").open()
        end,
        mode = { "n" },
        desc = "Open Spectre",
      },
    },
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
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
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
  {
    "simplenote-vim/simplenote.vim",
    config = function()
      if vim.fn.filereadable(vim.fn.expand("~/.simplenote-credentials")) then
        vim.cmd([[ source ~/.simplenote-credentials ]])
      end
      vim.g.SimplenoteFiletype = "simplenote-text"
      vim.g.SimplenoteListSize = 20
      vim.api.nvim_create_autocmd("FileType", { pattern = "simplenote-text", command = "setl cursorline" })
    end,
    cmd = { "SimplenoteList" },
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
    "chomosuke/term-edit.nvim",
    ft = "toggleterm",
    version = "1.*",
    config = function()
      require("term-edit").setup({
        prompt_end = "❯ ",
      })
    end,
    enabled = false,
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
    "smoka7/multicursors.nvim",
    dependencies = { "smoka7/hydra.nvim" },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
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
    branch = "0.10",
  },
  {
    "LunarVim/bigfile.nvim",
    cond = not vim.g.vscode,
    config = function()
      require("bigfile").setup({
        filesize = 1,
        pattern = { "*" },
        features = {
          "indent_blankline",
          "illuminate",
          "lsp",
          "treesitter",
          "syntax",
          "matchparen",
          -- "vimopts",
          "filetype",
        },
      })
    end,
    lazy = false,
  },
  { "stevearc/profile.nvim" },
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    config = function()
      require("csvview").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("CopilotChat").setup({})
    end,
    cmd = { "CopilotChat" },
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
            -- next = "<A-]>",
            -- prev = "<A-[>",
            -- dismiss = "<C-]>",
          },
        },
        filetypes = {
          ["*"] = true,
        },
      })
    end,
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
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
    lazy = false,
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
}
