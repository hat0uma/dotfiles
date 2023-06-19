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
    config = function()
      require("indent_blankline").setup {
        char = "│",
        filetype_exclude = {
          "help",
          "toggleterm",
          "terminal",
          "TelescopePrompt",
          "packer",
          "translator",
        },
      }
    end,
    event = "BufReadPre",
  },

  {
    "Wansmer/treesj",
    config = function()
      require("treesj").setup { use_default_keymaps = false }
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
      require("refactoring").setup {}
    end,
  },
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup()
    end,
    keys = { { ";", "<Cmd>HopWord<CR>" } },
  },
  {
    "mfussenegger/nvim-treehopper",
    init = function()
      vim.keymap.set({ "o", "x" }, "m", require("tsht").nodes, {})
    end,
    dependencies = { "hop.nvim" },
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
      require("nvim-web-devicons").setup { default = true }
    end,
  },

  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        patterns = {
          ".git",
          ".svn",
        },
        detection_methods = { "pattern", "lsp" },
      }
    end,
    event = "BufReadPost",
  },
  {
    "danymat/neogen",
    keys = {
      {
        "<Leader>d",
        function()
          require("neogen").generate {}
        end,
        "n",
      },
    },
    config = function()
      require("neogen").setup {
        enabled = true,
        languages = {
          cs = { template = { annotation_convention = "xmldoc" } },
          typescript = { template = { annotation_convention = "tsdoc" } },
          typescriptreact = { template = { annotation_convention = "tsdoc" } },
        },
      }
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-pack/nvim-spectre",
    config = function()
      require("spectre").setup {
        default = {
          find = {
            cmd = "rg",
            options = { "ignore-case", "hidden" },
          },
          replace = { cmd = "sed" },
        },
      }
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
  { "kevinhwang91/nvim-bqf", ft = "qf" },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
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
      require("translate").setup {
        default = {
          command = "google",
          output = "floating",
        },
      }
    end,
    cmd = { "Translate" },
  },

  {
    "ggandor/lightspeed.nvim",
    init = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
    config = function()
      vim.api.nvim_set_hl(0, "LightspeedHiddenCursor", { blend = 100, nocombine = true })

      local guicursor = vim.go.guicursor
      local hide_cursor = function()
        vim.go.guicursor = "a:LightspeedHiddenCursor"
      end
      local restore_cursor = vim.schedule_wrap(function()
        vim.go.guicursor = guicursor
      end)

      local group = vim.api.nvim_create_augroup("lightspeed_aug", {})
      vim.api.nvim_create_autocmd("User", { pattern = "LightspeedFtEnter", callback = hide_cursor, group = group })
      vim.api.nvim_create_autocmd("User", { pattern = "LightspeedFtLeave", callback = restore_cursor, group = group })
    end,
    keys = {
      { "f", "<Plug>Lightspeed_f", { "n", "x", "o" } },
      { "F", "<Plug>Lightspeed_F", { "n", "x", "o" } },
      { "t", "<Plug>Lightspeed_t", { "n", "x", "o" } },
      { "T", "<Plug>Lightspeed_T", { "n", "x", "o" } },
    },
  },

  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },

  -- git
  {
    "lambdalisue/gina.vim",
    init = function()
      local opts = { silent = true, noremap = true }
      -- vim.keymap.set("n", ",s", ":<C-u>Gina status<CR>", opts)
      vim.keymap.set("n", ",c", ":<C-u>Gina commit -v<CR>", opts)
      vim.keymap.set("n", ",a", ":<C-u>Gina commit --amend -v<CR>", opts)
      vim.keymap.set("n", ",b", ":<C-u>Gina branch -a<CR>", opts)
      vim.keymap.set("n", ",l", ":<C-u>Gina log<CR>", opts)

      local yank_cmd = "Gina browse --exact : --yank<CR>:let @+=@0"
      vim.keymap.set("n", ",y", "<Cmd>" .. yank_cmd .. "<CR>", opts)
      vim.keymap.set("v", ",y", ":" .. yank_cmd .. "<CR>", opts)

      local browse_cmd = "Gina browse --exact :"
      vim.keymap.set("n", ",x", "<Cmd>" .. browse_cmd .. "<CR>", opts)
      vim.keymap.set("v", ",x", ":" .. browse_cmd .. "<CR>", opts)
    end,
    cmd = "Gina",
  },
  {
    "lambdalisue/gin.vim",
    dependencies = { "denops.vim" },
    build = require("plugins.denops").cache "gin",
    config = function()
      require("plugins.denops").register "gin"
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
      if vim.fn.filereadable(vim.fn.expand "~/.simplenote-credentials") then
        vim.cmd [[ source ~/.simplenote-credentials ]]
      end
      vim.g.SimplenoteFiletype = "simplenote-text"
      vim.g.SimplenoteListSize = 20
      vim.api.nvim_create_autocmd("FileType", { pattern = "simplenote-text", command = "setl cursorline" })
    end,
    cmd = { "SimplenoteList" },
  },

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
    "ojroques/vim-oscyank",
    init = function()
      vim.cmd [[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankRegister +' | endif ]]
    end,
    cmd = { "OSCYank", "OSCYankRegister" },
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
    keys = { "<C-n>" },
  },
  {
    "kat0h/bufpreview.vim",
    dependencies = { "denops.vim" },
    build = "deno task prepare",
    config = function()
      require("plugins.denops").register "bufpreview"
    end,
    cmd = { "PreviewMarkdown" },
  },
  {
    "chomosuke/term-edit.nvim",
    ft = "toggleterm",
    version = "1.*",
    config = function()
      require("term-edit").setup {
        prompt_end = "❯ ",
      }
    end,
    enabled = false,
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup {
        filetypes = {
          "css",
          "scss",
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
        },
      }
    end,
    event = "BufReadPost",
  },
  {
    "nvim-orgmode/orgmode",
    config = function()
      require("orgmode").setup_ts_grammar()
      require("orgmode").setup {
        mappings = {
          prefix = "<Leader>O",
          global = {
            org_agenda = { "<Leader>Oa" },
            org_capture = { "<Leader>Oc" },
          },
        },
        org_default_notes_file = "~/org/refile.org",
      }
    end,
    lazy = false,
    enabled = false,
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup {
        strategy = "toggleterm",
        use_shell = false,
        direction = "float",
        auto_scroll = nil,
        -- have the toggleterm window close automatically after the task exits
        close_on_exit = false,
        -- open the toggleterm window when a task starts
        open_on_start = true,
      }
    end,
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set("n", "<leader>0", "<Cmd>OverseerToggle<CR>", opts)
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "OverseerList",
        callback = function()
          vim.keymap.set("n", "q", "<Cmd>OverseerClose<CR>", { silent = true, noremap = true, buffer = true })
          vim.keymap.set("n", "A", "<Cmd>OverseerRun<CR>", { silent = true, noremap = true, buffer = true })
        end,
        group = vim.api.nvim_create_augroup("my-overseer-settings", {}),
      })
    end,
    cmd = { "OverseerRun", "OverseerToggle" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
  },
  {
    "nmac427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup {}
    end,
    event = "BufReadPre",
  },
  {
    "TimUntersberger/neogit",
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set("n", ",s", ":<C-u>Neogit<CR>", opts)
    end,
    config = function()
      local neogit = require "neogit"
      neogit.setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
      }
    end,
    cmd = { "Neogit" },
    dependencies = {
      "sindrets/diffview.nvim",
    },
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup {
        hooks = {
          diff_buf_read = function(bufnr)
            vim.opt_local.relativenumber = false
          end,
        },
      }
    end,
  },
}
