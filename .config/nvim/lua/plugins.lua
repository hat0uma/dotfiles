local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup {
  {
    "vim-jp/vimdoc-ja",
    event = { "CmdlineEnter" },
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },

  {
    "RRethy/vim-illuminate",
    config = function()
      require "rc.illuminate"
    end,
    event = "BufReadPost",
  },

  -- lsp
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("nvim-navic").setup { highlight = true }
      vim.go.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end,
    lazy = true,
  },
  { "p00f/clangd_extensions.nvim", lazy = true },
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  { "jose-elias-alvarez/typescript.nvim", lazy = true },
  { "folke/neodev.nvim", lazy = true },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
    lazy = true,
  },
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup {
        backends = {
          "lsp",
          "treesitter",
          "markdown",
          "man",
        },
        filter_kind = {
          "Class",
          "Constant",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          "Object",
          "Array",
          "Package",
        },
        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│",
          whitespace = "  ",
        },
      }
    end,
    cmd = "AerialToggle",
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      require("rc.lsp").setup()
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
    },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
    lazy = true,
    cmd = { "Mason", "MasonInstall" },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    lazy = true,
  },
  {
    "rikuma-t/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("rc.trouble").config()
    end,
    keys = {
      { "<leader>q", require("rc.trouble").toggle, "n" },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "kleber-swf/vscode-unity-code-snippets",
    },
    config = function()
      require("rc.snippets").config()
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },

  -- cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    config = function()
      require "rc.cmp"
    end,
    event = { "InsertEnter", "CmdlineEnter" },
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

  -- colorscheme
  {
    "sainnhe/everforest",
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_ui_contrast = "high"
      vim.g.everforest_better_performance = 1
      vim.cmd [[ autocmd VimEnter * ++nested colorscheme everforest ]]
      require("rc.color").setup()
    end,
    priority = 999,
  },

  {
    "vim-denops/denops.vim",
    -- lazy = true,
    config = function()
      if vim.fn.executable "deno" ~= 1 then
        vim.g["denops#deno"] = vim.fn.expand "~/.deno/bin/deno"
      end
      -- require("rc.denops").wait_ready()
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function()
      require "rc.autopairs"
    end,
    dependencies = { "nvim-cmp" },
    event = { "InsertEnter" },
  },
  {
    "Wansmer/treesj",
    config = function()
      require("treesj").setup { use_default_keymaps = false }
    end,
    keys = {
      { "J", "<cmd>TSJToggle<cr>" },
    },
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
    "tamago324/lir.nvim",
    init = function()
      vim.keymap.set("n", "<leader>e", "<Cmd>MyLirOpen<CR>", { silent = true })
    end,
    config = function()
      require("rc.lir").config()
    end,
    cmd = { "MyLirOpen" },
    -- enabled = false,
  },
  {
    "vim-skk/denops-skkeleton.vim",
    config = function()
      vim.keymap.set("i", "<C-j>", "<Plug>(skkeleton-toggle)", {})
      vim.keymap.set("c", "<C-j>", "<Plug>(skkeleton-toggle)", {})
      require "rc.skkeleton"
    end,
  },

  {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup { default = true }
    end,
    lazy = true,
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
        "<Leader>hc",
        function()
          require("neogen").generate { type = "class" }
        end,
        "n",
      },
      {
        "<Leader>hf",
        function()
          require("neogen").generate { type = "func" }
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
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      require("rc.telescope").setup()
    end,
    config = function()
      require("rc.telescope").config()
    end,
    cmd = { "Telescope" },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = { "telescope.nvim" },
    build = "make",
    lazy = true,
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "telescope.nvim" },
    lazy = true,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "telescope.nvim" },
    enabled = false,
    lazy = true,
  },
  {
    "tsakirist/telescope-lazy.nvim",
    dependencies = { "telescope.nvim" },
    lazy = true,
  },

  -- statusline
  {
    "glepnir/galaxyline.nvim",
    config = function()
      require "rc.statusline"
    end,
    dependencies = { "sainnhe/everforest" },
    event = "VeryLazy",
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require "rc.dap"
    end,
    lazy = true,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {},
    config = function()
      require("rc.treesitter").config()
    end,
    event = "BufReadPost",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("rc.treesitter").textobjects_config()
    end,
    event = "BufReadPost",
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("rc.treesitter").tsautotag_config()
    end,
    ft = { "typescript", "typescriptreact", "javascript", "javascript" },
  },
  {
    "nvim-treesitter/playground",
    dependencies = { "nvim-treesitter" },
    cmd = { "TSPlaygroundToggle" },
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter" },
    cmd = { "TSCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("rc.treesitter").context_commentstring_config()
    end,
    ft = { "typescript", "typescriptreact", "javascript", "javascript" },
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
    keys = {
      { "f", "<Plug>Lightspeed_f", { "n", "x", "o" } },
      { "F", "<Plug>Lightspeed_F", { "n", "x", "o" } },
      { "t", "<Plug>Lightspeed_t", { "n", "x", "o" } },
      { "T", "<Plug>Lightspeed_T", { "n", "x", "o" } },
    },
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
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("rc.gitsigns").setup()
    end,
    event = "BufReadPre",
  },
  -- test
  { "TimUntersberger/neogit", dependencies = { "nvim-lua/plenary.nvim" }, lazy = true },

  -- textobj
  {
    "kana/vim-operator-replace",
    dependencies = { "kana/vim-operator-user" },
    config = function()
      vim.keymap.set("n", "_", "<Plug>(operator-replace)", { silent = true })
      vim.keymap.set("x", "_", "<Plug>(operator-replace)", { silent = true })
    end,
    event = "VeryLazy",
  },
  {
    "osyo-manga/vim-textobj-multiblock",
    dependencies = { "kana/vim-textobj-user" },
    config = function()
      vim.keymap.set({ "o", "v" }, "ib", "<Plug>(textobj-multiblock-i)", { silent = true })
      vim.keymap.set({ "o", "v" }, "ab", "<Plug>(textobj-multiblock-a)", { silent = true })
    end,
    event = "VeryLazy",
  },

  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup {
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "sa",
          normal_cur = "sasa",
          normal_line = false,
          normal_cur_line = false,
          visual = "sa",
          visual_line = "sasa",
          delete = "sd",
          change = "sr",
        },
        aliases = {
          ["b"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
      }
      vim.keymap.set("n", "sdd", "<Plug>(nvim-surround-delete)b", { silent = true })
      vim.keymap.set("n", "srr", "<Plug>(nvim-surround-change)b", { silent = true })
    end,
    event = "VeryLazy",
  },
  { "tpope/vim-repeat" },
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
    "rcarriga/nvim-notify",
    config = function()
      require "rc.notify"
    end,
    event = "VeryLazy",
  },

  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup {
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = { inc_rename = true },
      }
      vim.keymap.set("n", "<leader>n", "<Cmd>Noice telescope<CR>", { silent = true, noremap = true })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "VeryLazy",
  },

  {
    "akinsho/toggleterm.nvim",
    init = function()
      for i = 1, 5 do
        local key = string.format("<leader>%d", i)
        local cmd = string.format("<Cmd>exe %d . 'ToggleTerm'<CR>", i)
        vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
      end
    end,
    config = function()
      require("rc.toggleterm").config()
    end,
    cmd = { "ToggleTerm" },
  },
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
      vim.keymap.set("t", "<c-h>", "<C-><C-N><cmd>TmuxNavigateLeft<cr>", opts)
      vim.keymap.set("t", "<c-j>", "<C-><C-N><cmd>TmuxNavigateDown<cr>", opts)
      vim.keymap.set("t", "<c-k>", "<C-><C-N><cmd>TmuxNavigateUp<cr>", opts)
      vim.keymap.set("t", "<c-l>", "<C-><C-N><cmd>TmuxNavigateRight<cr>", opts)
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
  -- test
  {
    "hrsh7th/vim-searchx",
    config = function()
      local opts = { noremap = true }
      vim.keymap.set("n", "?", "<Cmd>call searchx#start({ 'dir': 0 })<CR>", opts)
      vim.keymap.set("n", "/", "<Cmd>call searchx#start({ 'dir': 1 })<CR>", opts)
      vim.keymap.set("x", "?", "<Cmd>call searchx#start({ 'dir': 0 })<CR>", opts)
      vim.keymap.set("x", "/", "<Cmd>call searchx#start({ 'dir': 1 })<CR>", opts)
      -- vim.keymap.set("c", ";", "<Cmd>call searchx#select()<CR>", opts)
      vim.keymap.set("n", "N", "<Cmd>call searchx#prev_dir()<CR>", opts)
      vim.keymap.set("n", "n", "<Cmd>call searchx#next_dir()<CR>", opts)
      vim.keymap.set("c", "<C-p>", "<Cmd>call searchx#prev()<CR>", opts)
      vim.keymap.set("c", "<C-n>", "<Cmd>call searchx#next()<CR>", opts)
      vim.g.searchx = {
        auto_accept = true,
        scrolloff = 0,
        scrolltime = 0,
        nohlsearch = { jump = true },
        markers = vim.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", ""),
      }
      vim.cmd [[
        " Convert search pattern.
        function g:searchx.convert(input) abort
          if a:input !~# '\k'
            return '\V' .. a:input
          endif
          return a:input[0] .. substitute(a:input[1:], '\\\@<! ', '.\\{-}', 'g')
        endfunction
      ]]
    end,
    keys = {
      { "?", mode = { "n", "x" } },
      { "/", mode = { "n", "x" } },
      { "n", mode = { "n", "x" } },
      { "N", mode = { "n", "x" } },
      { "<C-p>", mode = { "c" } },
      { "<C-n>", mode = { "c" } },
    },
  },
}
