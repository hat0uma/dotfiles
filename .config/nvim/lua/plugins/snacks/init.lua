return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    require("plugins.snacks.picker").init()
  end,
  config = function()
    require("snacks").setup({
      bigfile = {
        enabled = true,
        notify = true,
        size = 1 * 1024 * 1024,
        -- Enable or disable features when big file detected
        ---@param ctx {buf: number, ft:string}
        setup = function(ctx)
          vim.cmd([[NoMatchParen]])
          Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
          vim.schedule(function()
            vim.bo[ctx.buf].syntax = ctx.ft
          end)
          require("illuminate.engine").stop_buf(ctx.buf)
          if pcall(require, "ibl") then
            require("indent_blankline.commands").disable()
          end
        end,
      },
      notifier = { enabled = true },
      picker = require("plugins.snacks.picker").opts,
      -- quickfile = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
    })
  end,
}
