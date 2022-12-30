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
  { "vim-jp/vimdoc-ja" },
  { "dstein64/vim-startuptime" },

  {
    "RRethy/vim-illuminate",
    config = function()
      require "rc.illuminate"
    end,
  },

  -- lsp
  {
    "SmiteshP/nvim-navic",
    config = function()
      local navic = require "nvim-navic"
      navic.setup { highlight = true }
      function _G.navic_winbar()
        return navic.is_available() and navic.get_location() or ""
      end
      vim.o.winbar = "%!v:lua.navic_winbar()"
    end,
  },
  { "p00f/clangd_extensions.nvim" },
  { "Hoffs/omnisharp-extended-lsp.nvim" },
  { "jose-elias-alvarez/typescript.nvim" },
  {
    "neovim/nvim-lspconfig",
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
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "rikuma-t/trouble.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require "rc.trouble"
    end,
  },
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup {}
    end,
    enabled = false,
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
      "hrsh7th/cmp-nvim-lua",
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
  },

  -- colorscheme
  {
    "sainnhe/everforest",
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_ui_contrast = "high"
      vim.g.everforest_better_performance = 1
      vim.cmd [[ autocmd VimEnter * ++nested colorscheme everforest ]]

      local group = vim.api.nvim_create_augroup("rc_everforest_settings", {})
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "everforest",
        callback = function()
          vim.cmd [[highlight! default link VirtualTextError CocErrorSign]]
          vim.cmd [[highlight! default link VirtualTextWarning CocWarningsign]]
          vim.cmd [[highlight! default link VirtualTextInfo CocInfoSign]]
          vim.cmd [[highlight! default link VirtualTextHint CocHintSign]]
          --  vim.cmd [[ highlight! default link WinBar NormalFloat ]]
          -- for noice.nvim
          vim.cmd [[highlight! default link MsgArea LineNr]]
        end,
        nested = true,
        group = group,
      })
    end,
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
    "osyo-manga/vim-jplus",
    config = function()
      vim.keymap.set("n", "J", "<Plug>(jplus)", {})
      vim.keymap.set("v", "J", "<Plug>(jplus)", {})
      vim.keymap.set("n", "<leader>J", "<Plug>(jplus-getchar)", {})
      vim.keymap.set("v", "<leader>J", "<Plug>(jplus-getchar)", {})
      vim.g["jplus#config"] = { _ = {
        delimiter_format = "%d",
      } }
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
    -- dependencies = 'everforest',
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
    config = function()
      require("telescope").load_extension "fzf"
    end,
    build = "make",
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "telescope.nvim" },
    config = function()
      require("telescope").load_extension "live_grep_args"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "telescope.nvim" },
    config = function()
      require("telescope").load_extension "file_browser"
    end,
    enabled = false,
  },

  -- statusline
  {
    "glepnir/galaxyline.nvim",
    config = function()
      require "rc.statusline"
    end,
    dependencies = { "sainnhe/everforest" },
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require "rc.dap"
    end,
  },
  { "rcarriga/nvim-dap-ui" },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("rc.treesitter").config()
    end,
  },
  {
    "nvim-treesitter/playground",
    dependencies = { "nvim-treesitter" },
    cmd = { "TSPlaygroundToggle" },
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
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
    "rhysd/clever-f.vim",
    config = function()
      vim.g.clever_f_use_migemo = 1
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
    -- cmd = "Gina",
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("rc.gitsigns").setup()
    end,
  },
  -- test
  { "TimUntersberger/neogit", dependencies = { "nvim-lua/plenary.nvim" } },

  -- textobj
  { "kana/vim-textobj-user" },
  { "kana/vim-operator-user" },
  {
    "kana/vim-operator-replace",
    dependencies = { "vim-operator-user" },
    config = function()
      vim.keymap.set("n", "_", "<Plug>(operator-replace)", { silent = true })
      vim.keymap.set("x", "_", "<Plug>(operator-replace)", { silent = true })
    end,
  },
  {
    "rhysd/vim-operator-surround",
    dependencies = { "vim-operator-user" },
    config = function()
      vim.keymap.set("", "sa", "<Plug>(operator-surround-append)", { silent = true })
      vim.keymap.set("", "sd", "<Plug>(operator-surround-delete)", { silent = true })
      vim.keymap.set("", "sr", "<Plug>(operator-surround-replace)", { silent = true })
    end,
  },
  {
    "osyo-manga/vim-textobj-multiblock",
    dependencies = { "vim-operator-surround", "vim-textobj-user" },
    config = function()
      vim.keymap.set("n", "sdd", "<Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)", { silent = true })
      vim.keymap.set("n", "srr", "<Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)", { silent = true })
      vim.keymap.set("o", "ib", "<Plug>(textobj-multiblock-i)", { silent = true })
      vim.keymap.set("o", "ab", "<Plug>(textobj-multiblock-a)", { silent = true })
      vim.keymap.set("v", "ib", "<Plug>(textobj-multiblock-i)", { silent = true })
      vim.keymap.set("v", "ab", "<Plug>(textobj-multiblock-a)", { silent = true })
    end,
  },

  { "tpope/vim-repeat" },
  {
    "tyru/open-browser.vim",
    config = function()
      vim.keymap.set("n", "gx", "<Plug>(openbrowser-smart-search)", {})
      vim.keymap.set("v", "gx", "<Plug>(openbrowser-smart-search)", {})
    end,
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
      }
      vim.keymap.set("n", "<leader>n", "<Cmd>Noice telescope<CR>", { silent = true, noremap = true })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
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
  { "ojroques/vim-oscyank" },
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
  },
}
