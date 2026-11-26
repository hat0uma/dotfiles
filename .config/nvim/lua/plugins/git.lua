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
      if rc.sys.is_windows then
        local git_path = vim.fn.resolve(vim.fn.exepath("git"))
        if git_path == "" then
          return
        end

        -- Use directly the git.exe under <msystem>/bin to skip the cmd/git.exe wrapper.
        -- Newer Git for Windows ships ucrt64 instead of mingw64.
        local cmd_dir = vim.fs.dirname(git_path) -- e.g., C:/Program Files/Git/cmd
        local git_root = vim.fs.dirname(cmd_dir)
        for _, msystem in ipairs({ "ucrt64", "mingw64", "clangarm64" }) do
          local bin = vim.fs.joinpath(git_root, msystem, "bin")
          if vim.uv.fs_stat(vim.fs.joinpath(bin, "git.exe")) then
            vim.env.PATH = bin .. ";" .. vim.env.PATH
            break
          end
        end
      end
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
        -- neogit takes green from the `String` fg, which is gold in rose-pine.
        highlight = vim.g.colors_name and vim.g.colors_name:find("^rose%-pine") and {
          green = require("rose-pine.palette").leaf,
        } or nil,
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

      -- Neogit runs popup actions one at a time under a global lock, and the commit
      -- actions hold it until the commit editor is closed, so e.g. `l l` (log) does
      -- nothing while writing a commit message. Run the editor-based commit actions
      -- in their own coroutine so the lock is released right away. The popup only
      -- refreshes the status once the action returns, so refresh again when done.
      -- Only one of them may run at a time: a second `git commit` would overwrite
      -- .git/COMMIT_EDITMSG and wipe the message being written in the first editor.
      local a = require("neogit.lib.async")
      local Watcher = require("neogit.watcher")
      local commit_actions = require("neogit.popups.commit.actions")
      local committing = false
      for _, name in ipairs({ "commit", "amend", "reword", "alter", "augment", "revise" }) do
        local action = commit_actions[name]
        commit_actions[name] = function(popup)
          if committing then
            vim.notify("Neogit: a commit is already in progress", vim.log.levels.WARN)
            return
          end
          committing = true
          a.void(function()
            local ok, err = pcall(action, popup)
            committing = false
            Watcher.instance():dispatch_refresh()
            if not ok then
              error(err)
            end
          end)()
        end
      end
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
