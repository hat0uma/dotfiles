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
    -- keys = { { "<leader><leader>", "<Cmd>HopWord<CR>" } },
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
          "Makefile",
          "*.csproj",
          "*.sln",
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
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>c",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
        desc = "Structural Replace",
      },
    },
  },

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
      vim.keymap.set("n", ",s", ":<C-u>Gina status<CR>", opts)
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
    build = require("plugins.denops").cache,
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
    "ojroques/vim-oscyank",
    init = function()
      vim.cmd [[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankReg +' | endif ]]
    end,
    cmd = { "OSCYank", "OSCYankReg" },
  },
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
      vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", opts)
      vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", opts)
      vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", opts)
      vim.keymap.set("t", "<c-h>", "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>", opts)
      vim.keymap.set("t", "<c-j>", "<C-\\><C-N><cmd>TmuxNavigateDown<cr>", opts)
      vim.keymap.set("t", "<c-k>", "<C-\\><C-N><cmd>TmuxNavigateUp<cr>", opts)
      vim.keymap.set("t", "<c-l>", "<C-\\><C-N><cmd>TmuxNavigateRight<cr>", opts)
    end,
    keys = {
      { "<c-h>", mode = { "n", "t" } },
      { "<c-j>", mode = { "n", "t" } },
      { "<c-k>", mode = { "n", "t" } },
      { "<c-l>", mode = { "n", "t" } },
    },
  },
  {
    "RyanMillerC/better-vim-tmux-resizer",
    config = function()
      vim.g.tmux_resizer_no_mappings = 1
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<m-h>", "<cmd>TmuxResizeLeft<cr>", opts)
      vim.keymap.set("n", "<m-j>", "<cmd>TmuxResizeDown<cr>", opts)
      vim.keymap.set("n", "<m-k>", "<cmd>TmuxResizeUp<cr>", opts)
      vim.keymap.set("n", "<m-l>", "<cmd>TmuxResizeRight<cr>", opts)
    end,
    keys = { { "<m-h>" }, { "<m-j>" }, { "<m-k>" }, { "<m-l>" } },
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
}
