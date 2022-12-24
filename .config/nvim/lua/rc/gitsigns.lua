local M = {}

local function define_reversed_hl(name, newname)
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  local bg = hl.foreground and string.format("#%x", hl.foreground) or nil
  local fg = hl.background and string.format("#%x", hl.background) or nil
  vim.api.nvim_set_hl(0, newname, { bg = bg, fg = fg })
end
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    define_reversed_hl("Green", "GitSignsAddNrReversed")
    define_reversed_hl("Blue", "GitSignsChangeNrReversed")
    define_reversed_hl("Red", "GitSignsDeleteNrReversed")
  end,
})

function M.setup()
  require("gitsigns").setup {
    signcolumn = false,
    numhl = true,
    linehl = false,
    signs = {
      add = {
        hl = "GitSignsAdd",
        text = "┃",
        -- numhl = "GitSignsAddNrReversed",
        numhl = "GitSignsAddLn",
        linehl = "GitSignsAddLn",
      },
      change = {
        hl = "GitSignsChange",
        text = "┃",
        -- numhl = "GitSignsChangeNrReversed",
        numhl = "GitSignsChangeLn",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        hl = "GitSignsDelete",
        text = "┃",
        -- numhl = "GitSignsDeleteNrReversed",
        numhl = "GitSignsDeleteLn",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        hl = "GitSignsDelete",
        text = "┃",
        -- numhl = "GitSignsDeleteNrReversed",
        numhl = "GitSignsDeleteLn",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        hl = "GitSignsChange",
        text = "┃",
        -- numhl = "GitSignsChangeNrReversed",
        numhl = "GitSignsChangeLn",
        linehl = "GitSignsChangeLn",
      },
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
