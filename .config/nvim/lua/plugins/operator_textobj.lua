local M = {
  {
    "kana/vim-operator-replace",
    dependencies = { "kana/vim-operator-user" },
    config = function()
      vim.keymap.set("n", "_", "<Plug>(operator-replace)", { silent = true })
      vim.keymap.set("x", "_", "<Plug>(operator-replace)", { silent = true })
    end,
    event = "VeryLazy",
  },
  {
    "osyo-manga/vim-textobj-multiblock",
    dependencies = { "kana/vim-textobj-user" },
    init = function()
      vim.g.textobj_multiblock_blocks = {
        { "(", ")" },
        { "[", "]" },
        { "{", "}" },
        { "<", ">" },
        { '"', '"', 1 },
        { "'", "'", 1 },
        { "`", "`", 1 },
      }
    end,
    config = function()
      vim.keymap.set({ "o", "v" }, "ib", "<Plug>(textobj-multiblock-i)", { silent = true })
      vim.keymap.set({ "o", "v" }, "ab", "<Plug>(textobj-multiblock-a)", { silent = true })
    end,
    event = "VeryLazy",
  },
  {
    "kylechui/nvim-surround",
    config = function()
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
      vim.g.nvim_surround_no_insert_mappings = true
      require("nvim-surround").setup({
        aliases = {
          ["b"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
      })
      vim.keymap.set("n", "sdd", "<Plug>(nvim-surround-delete)b", { silent = true })
      vim.keymap.set("n", "srr", "<Plug>(nvim-surround-change)b", { silent = true })
      vim.keymap.set("i", "<C-g>s", "<Plug>(nvim-surround-insert)", {
        desc = "Add a surrounding pair around the cursor (insert mode)",
      })
      vim.keymap.set("i", "<C-g>S", "<Plug>(nvim-surround-insert-line)", {
        desc = "Add a surrounding pair around the cursor, on new lines (insert mode)",
      })
      vim.keymap.set("n", "sa", "<Plug>(nvim-surround-normal)", {
        desc = "Add a surrounding pair around a motion (normal mode)",
      })
      vim.keymap.set("n", "sasa", "<Plug>(nvim-surround-normal-cur)", {
        desc = "Add a surrounding pair around the current line (normal mode)",
      })
      vim.keymap.set("x", "sa", "<Plug>(nvim-surround-visual)", {
        desc = "Add a surrounding pair around a visual selection",
      })
      vim.keymap.set("x", "sasa", "<Plug>(nvim-surround-visual-line)", {
        desc = "Add a surrounding pair around a visual selection, on new lines",
      })
      vim.keymap.set("n", "sd", "<Plug>(nvim-surround-delete)", {
        desc = "Delete a surrounding pair",
      })
      vim.keymap.set("n", "sr", "<Plug>(nvim-surround-change)", {
        desc = "Change a surrounding pair",
      })
    end,
    event = "VeryLazy",
  },
}
return M
