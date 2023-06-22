return {
  {
    "ggandor/lightspeed.nvim",
    enabled = false,
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
    "hrsh7th/vim-searchx",
    enabled = false,
    config = function()
      local function searchx_start(searchx_opts)
        return function()
          local scrolloff = vim.o.scrolloff
          vim.o.scrolloff = 0
          vim.fn["searchx#start"](searchx_opts)
          vim.o.scrolloff = scrolloff
        end
      end

      local key_opts = { noremap = true }
      vim.keymap.set({ "n", "x" }, "?", searchx_start { dir = 0 }, key_opts)
      vim.keymap.set({ "n", "x" }, "/", searchx_start { dir = 1 }, key_opts)
      -- vim.keymap.set({ "n", "x" }, "<leader><leader>", searchx_start { dir = 1 }, key_opts)
      -- vim.keymap.set("c", ";", "<Cmd>call searchx#select()<CR>", opts)
      vim.keymap.set("n", "N", "<Cmd>call searchx#prev_dir()<CR>", key_opts)
      vim.keymap.set("n", "n", "<Cmd>call searchx#next_dir()<CR>", key_opts)
      vim.keymap.set("c", "<C-p>", "<Cmd>call searchx#prev()<CR>", key_opts)
      vim.keymap.set("c", "<C-n>", "<Cmd>call searchx#next()<CR>", key_opts)
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
      -- { "<leader><leader>", mode = { "n", "x" } },
      { "n", mode = { "n", "x" } },
      { "N", mode = { "n", "x" } },
    },
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
    enabled = false,
    init = function()
      vim.keymap.set({ "o", "x" }, "m", require("tsht").nodes, {})
    end,
    dependencies = { "hop.nvim" },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup {
        jump = {
          nohlsearch = true,
          autojump = true,
        },
        modes = {
          char = {
            enabled = true,
            keys = { "f", "F", "t", "T" },
            highlight = { backdrop = false },
          },
        },
      }
    end,
    keys = {
      -- {
      --   ";",
      --   mode = { "n", "x", "o" },
      --   function()
      --     require("flash").jump {}
      --   end,
      -- },
      {
        "m",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
    },
  },
}
