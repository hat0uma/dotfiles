return {
  {
    "linrongbin16/gitlinker.nvim",
    dependencies = {
      "plenary.nvim",
      "open-browser.vim",
    },
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set({ "n", "v" }, ",y", "<cmd>GitLink<CR>", opts)
      vim.keymap.set({ "n", "x" }, ",x", "<cmd>GitLink!<CR>", opts)
      vim.keymap.set({ "n", "v" }, ",Y", "<cmd>GitLink blame<CR>", opts)
      vim.keymap.set({ "n", "x" }, ",X", "<cmd>GitLink! blame<CR>", opts)
    end,
    config = function()
      require("gitlinker").setup {}
    end,
    cmd = { "GitLink" },
  },
  {
    "NeogitOrg/neogit",
    branch = "nightly",
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set("n", "<C-g>", ":<C-u>Neogit<CR>", opts)
      -- vim.keymap.set("n", ",c", ":<C-u>Neogit commit<CR>", opts)
      -- vim.keymap.set("n", ",l", ":<C-u>Neogit log<CR>", opts)
      -- vim.keymap.set("n", ",,", ":<C-u>Neogit<CR>", opts)
    end,
    config = function()
      local neogit = require "neogit"
      neogit.setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
        ignored_settings = {
          "NeogitPushPopup--force-with-lease",
          "NeogitPushPopup--force",
          "NeogitCommitPopup--allow-empty",
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
    init = function()
      -- vim.keymap.set("n", ",l", "<Cmd>DiffviewFileHistory<CR>", { silent = true, noremap = true })
    end,
    config = function()
      require("diffview").setup {
        hooks = {
          diff_buf_read = function(bufnr)
            vim.opt_local.relativenumber = false
          end,
        },
        keymaps = {
          file_history_panel = {
            { "n", "q", "<Cmd>DiffviewClose<CR>" },
          },
        },
      }
    end,
    cmd = { "DiffviewFileHistory" },
  },
}
