local M = {
  "lewis6991/gitsigns.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufReadPre",
}

function M.config()
  require("gitsigns").setup {
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
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      local blame = function()
        gs.blame_line { full = true }
      end
      local diff = function()
        gs.diffthis "~"
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
  }
end

return M
