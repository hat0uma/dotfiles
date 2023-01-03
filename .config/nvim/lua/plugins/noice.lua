return {
  "folke/noice.nvim",
  config = function()
    require("noice").setup {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        long_message_to_split = true,
        inc_rename = true,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "書込み",
          },
          opts = { skip = true },
        },
      },
    }
    vim.keymap.set("n", "<leader>n", "<Cmd>Noice telescope<CR>", { silent = true, noremap = true })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  event = "VeryLazy",
}
