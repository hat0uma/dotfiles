return {
  {
    "christoomey/vim-tmux-navigator",
    config = function()
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
      vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", opts)
      vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", opts)
      vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", opts)
      vim.keymap.set("t", "<c-h>", "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>", opts)
      vim.keymap.set("t", "<c-j>", "<C-\\><C-N><cmd>TmuxNavigateDown<cr>", opts)
      vim.keymap.set("t", "<c-k>", "<C-\\><C-N><cmd>TmuxNavigateUp<cr>", opts)
      vim.keymap.set("t", "<c-l>", "<C-\\><C-N><cmd>TmuxNavigateRight<cr>", opts)
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
}
