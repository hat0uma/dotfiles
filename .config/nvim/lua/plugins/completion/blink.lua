local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local spec = {
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
            local _, neogen = pcall(require, "neogen")
            if cmp.snippet_active() then
              return cmp.accept()
            elseif neogen and neogen.jumpable() then
              vim.fn.feedkeys(t("<cmd>lua require('neogen').jump_next()<CR>"), "")
              return true
            else
              return cmp.select_next()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            local _, neogen = pcall(require, "neogen")
            if cmp.snippet_active() then
              return cmp.cancel()
            elseif neogen and neogen.jumpable(-1) then
              vim.fn.feedkeys(t("<cmd>lua require('neogen').jump_prev()<CR>"), "")
              return true
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

return {
  spec = spec,
  get_lsp_capabilities = function(...)
    return require("blink-cmp").get_lsp_capabilities(...)
  end,
}
