return {
  {
    "folke/noice.nvim",
    cond = not vim.g.vscode,
    config = function()
      require("noice").setup({
        lsp = {
          progress = { enabled = true },
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
        views = {
          cmdline_popup = {
            position = {
              row = math.floor(vim.o.lines * 0.15) + 1,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = math.floor(vim.o.lines * 0.15) + 1,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
          },
        },
        routes = {
          {
            filter = {
              any = {
                { event = "msg_show", kind = "", find = "書込み" },
                { event = "msg_show", kind = "", find = "written" },
                { event = "notify", find = "No information available" },
              },
            },
            opts = { skip = true },
          },
        },
      })
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
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    enabled = false,
    config = function()
      local notify = require("notify")
      vim.notify = notify
      notify.setup({
        -- render = "minimal",
        minimum_width = 15,
        max_width = 50,
        -- stages = stages,
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
}
