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
      require("gitlinker").setup({})
    end,
    cmd = { "GitLink" },
  },
  {
    "NeogitOrg/neogit",
    init = function()
      local opts = { silent = true, noremap = true }
      vim.keymap.set("n", "<C-g>", ":<C-u>Neogit<CR>", opts)
      -- vim.keymap.set("n", ",c", ":<C-u>Neogit commit<CR>", opts)
      -- vim.keymap.set("n", ",l", ":<C-u>Neogit log<CR>", opts)
      -- vim.keymap.set("n", ",,", ":<C-u>Neogit<CR>", opts)
    end,
    config = function()
      local neogit = require("neogit")
      neogit.setup({
        disable_signs = true,
        disable_commit_confirmation = true,
        integrations = {
          telescope = false, -- If turned on, neogit uses Telescope with the `ivy` theme, which I don't like.
          diffview = true,
        },
        ignored_settings = {
          "NeogitPushPopup--force-with-lease",
          "NeogitPushPopup--force",
          "NeogitCommitPopup--allow-empty",
        },
      })
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
      require("diffview").setup({
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
      })
    end,
    cmd = { "DiffviewFileHistory" },
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        trouble = false,
        signcolumn = true,
        numhl = false,
        linehl = false,
        signs = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "┃" },
          topdelete = { text = "┃" },
          changedelete = { text = "┃" },
          untracked = { text = "┃" },
        },
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 100,
          ignore_whitespace = false,
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, l, r, opts)
            opts = vim.tbl_extend("keep", opts or {}, { silent = true })
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          local blame = function()
            gs.blame_line({ full = true })
          end
          local diff = function()
            gs.diffthis("~")
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", blame)
          map("n", "<leader>tb", gs.toggle_current_line_blame)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", diff)
          map("n", "<leader>td", gs.toggle_deleted)

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },
}
