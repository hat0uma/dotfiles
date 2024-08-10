local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("plugins.treesitter.parser").setup()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
          disable = {
            -- 'toml',
          },
        },
      })
    end,
    event = "BufReadPost",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["ia"] = "@parameter.outer",
              ["aa"] = "@parameter.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["swn"] = "@parameter.inner",
            },
            swap_previous = {
              ["swp"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
    end,
    event = "BufReadPost",
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        autotag = {
          enable = true,
        },
      })
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
    config = function()
      require("nt-cpp-tools").setup({
        header_extension = "h",
        source_extension = "cpp",
      })
    end,
    cmd = { "TSCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter" },
    config = function()
      vim.g.skip_ts_context_commentstring_module = true
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
    ft = { "typescript", "typescriptreact", "javascript", "javascript" },
  },
}
return M
