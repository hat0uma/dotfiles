local cmp = require "cmp"
local luasnip = require "luasnip"
local neogen = require "neogen"

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif neogen.jumpable() then
        vim.fn.feedkeys(t "<cmd>lua require('neogen').jump_next()<CR>", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif neogen.jumpable(-1) then
        vim.fn.feedkeys(t "<cmd>lua require('neogen').jump_prev()<CR>", "")
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
  },

  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
    { name = "skkeleton" },
  },

  formatting = {
    format = require("lspkind").cmp_format {
      with_text = true,
      menu = {
        buffer = "[buffer]",
        nvim_lsp = "[lsp]",
        luasnip = "[snip]",
        path = "[path]",
        skkeleton = "[skk]",
      },
    },
  },
  experimental = {
    ghost_text = true,
  },
}
cmp.setup.cmdline("/", {
  sources = {
    { name = "buffer" },
  },
})
cmp.setup.cmdline(":", {
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})

-- sources
aug("my_cmp_settings", {
  au("FileType", {
    pattern = { "denite-filter", "TelescopePrompt", "LspRenamePrompt" },
    callback = function()
      require("cmp").setup.buffer { enabled = false }
    end,
  }),
})
