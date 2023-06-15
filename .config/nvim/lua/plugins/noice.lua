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
        -- signature = { enabled = false },
      },
      presets = {
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = {
            any = {
              { event = "msg_show", kind = "", find = "書込み" },
              { event = "msg_show", kind = "", find = "written" },
            },
          },
          opts = { skip = true },
        },
      },
    }
    vim.keymap.set("n", "<leader>n", "<Cmd>Noice telescope<CR>", { silent = true, noremap = true })
    vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
      if not require("noice.lsp").scroll(4) then
        return "<c-f>"
      end
    end, { silent = true, expr = true })

    vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
      if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
      end
    end, { silent = true, expr = true })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  event = "VeryLazy",
}
