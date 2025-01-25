return {
  "saghen/blink.cmp",
  version = "*",
  config = function()
    -- winhighlight = "Normal:Normal,FloatBorder:Grey,CursorLine:PmenuSel,Search:None",
    -- vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Normal" })
    -- vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "Grey" })
    require("blink-cmp").setup({
      keymap = {
        preset = "none",
        ["<C-space>"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.hide()
            else
              return cmp.show()
            end
          end,
        },
        ["<CR>"] = {
          function(cmp)
            if vim.api.nvim_get_mode().mode == "c" then
              return
            end
            return cmp.accept()
          end,
          "fallback",
        },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_next()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.cancel()
            else
              return cmp.select_prev()
            end
          end,
          "snippet_backward",
          "fallback",
        },
      },

      completion = {
        list = { selection = {
          preselect = false,
          auto_insert = true,
        } },
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
        accept = { auto_brackets = { enabled = false } },
      },

      snippets = { preset = "luasnip" },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    })
  end,
}
