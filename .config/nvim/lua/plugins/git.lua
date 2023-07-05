local function neogit_log_preview()
  local CommitViewBufffer = require "neogit.buffers.commit_view"
  local commit = vim.split(vim.fn.getline ".", " ")[2]
  CommitViewBufffer.new(commit):open()
  vim.cmd.wincmd "p"
end

return {
  {
    "lambdalisue/gina.vim",
    init = function()
      local opts = { silent = true, noremap = true }
      -- vim.keymap.set("n", ",s", ":<C-u>Gina status<CR>", opts)
      -- vim.keymap.set("n", ",c", ":<C-u>Gina commit -v<CR>", opts)
      -- vim.keymap.set("n", ",a", ":<C-u>Gina commit --amend -v<CR>", opts)
      -- vim.keymap.set("n", ",b", ":<C-u>Gina branch -a<CR>", opts)
      -- vim.keymap.set("n", ",l", ":<C-u>Gina log<CR>", opts)

      -- local yank_cmd = "Gina browse --exact : --yank<CR>:let @+=@0"
      -- vim.keymap.set("n", ",y", "<Cmd>" .. yank_cmd .. "<CR>", opts)
      -- vim.keymap.set("v", ",y", ":" .. yank_cmd .. "<CR>", opts)

      -- local browse_cmd = "Gina browse --exact :"
      -- vim.keymap.set("n", ",x", "<Cmd>" .. browse_cmd .. "<CR>", opts)
      -- vim.keymap.set("v", ",x", ":" .. browse_cmd .. "<CR>", opts)
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
    "linrongbin16/gitlinker.nvim",
    dependencies = {
      "plenary.nvim",
      "open-browser.vim",
      "vim-oscyank",
    },
    config = function()
      require("gitlinker").setup {
        mapping = false,
      }

      local opts = { silent = true }
      local browse = { action = vim.fn["openbrowser#open"] }
      local yank = { action = vim.fn.OSCYank }
      vim.keymap.set({ "n", "x" }, ",y", function()
        require("gitlinker").link(yank)
      end, opts)
      vim.keymap.set({ "n", "x" }, ",x", function()
        require("gitlinker").link(browse)
      end, opts)
    end,
    keys = {
      { ",y", mode = { "n", "v" } },
      { ",x", mode = { "n", "v" } },
      { ",X", mode = "n" },
    },
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
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NeogitLogView",
        callback = function()
          local preview = true
          vim.api.nvim_create_autocmd("CursorMoved", {
            callback = function()
              if preview then
                neogit_log_preview()
              end
            end,
            buffer = vim.api.nvim_get_current_buf(),
          })
          vim.keymap.set("n", "p", function()
            if not preview then
              neogit_log_preview()
            end
            preview = not preview
          end, { silent = true, noremap = true, buffer = true })
        end,
        group = vim.api.nvim_create_augroup("my-neogit-settings", {}),
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
