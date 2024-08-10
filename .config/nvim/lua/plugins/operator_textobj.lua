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
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "sa",
          normal_cur = "sasa",
          normal_line = false,
          normal_cur_line = false,
          visual = "sa",
          visual_line = "sasa",
          delete = "sd",
          change = "sr",
        },
        aliases = {
          ["b"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
      })
      vim.keymap.set("n", "sdd", "<Plug>(nvim-surround-delete)b", { silent = true })
      vim.keymap.set("n", "srr", "<Plug>(nvim-surround-change)b", { silent = true })
    end,
    event = "VeryLazy",
  },
}
return M
