local spec = {
  {
    "hrsh7th/nvim-cmp",
    cond = not vim.g.vscode,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      {
        "onsails/lspkind-nvim",
        config = function()
          require("lspkind").init({ preset = "codicons" })
        end,
      },
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local BORDER_CHARS = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.go.completeopt = "menu,menuone,noselect"
      local cmp = require("cmp")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local t = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
      end

      -- #nnnnnn
      local REGEX_RGBHEX = "#([0-9a-fA-F]+)"
      local function rgb3_to_6(rgb3)
        return table.concat({
          rgb3:sub(1, 1):rep(2),
          rgb3:sub(2, 2):rep(2),
          rgb3:sub(3, 3):rep(2),
        })
      end

      cmp.setup({
        -- completion = {
        --   completeopt = "menu,menuone,noinsert",
        -- },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Tab>"] = cmp.mapping(function(fallback)
            local luasnip = require("luasnip")
            local neogen = require("neogen")

            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif neogen.jumpable() then
              vim.fn.feedkeys(t("<cmd>lua require('neogen').jump_next()<CR>"), "")
            -- elseif has_words_before() then
            --   cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            local luasnip = require("luasnip")
            local neogen = require("neogen")

            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            elseif neogen.jumpable(-1) then
              vim.fn.feedkeys(t("<cmd>lua require('neogen').jump_prev()<CR>"), "")
            else
              fallback()
            end
          end, { "i", "s" }),
          -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-space>"] = cmp.mapping.complete({}),
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                local buf = vim.api.nvim_get_current_buf()
                local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                if byte_size > 5 * 1024 * 1024 then
                  return {}
                end
                return { buf }
              end,
            },
          },
          { name = "path" },
          { name = "orgmode" },
          { name = "lazydev", group_index = 0 },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local orig_kind = vim_item.kind
            local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "
            kind.menu = "    " .. (strings[2] or "")
            kind.menu_hl_group = "CmpItemKind" .. orig_kind

            if orig_kind == "Color" then
              local doc = entry.completion_item.documentation or kind.word
              -- #nnnnnn or #nnn
              local rgb_hex = string.match(doc, REGEX_RGBHEX)
              if rgb_hex and (#rgb_hex == 3 or #rgb_hex == 6) then
                if #rgb_hex == 3 then
                  rgb_hex = rgb3_to_6(rgb_hex)
                end
                local group = "RcCmpColor_" .. rgb_hex
                vim.api.nvim_set_hl(0, group, { fg = "#" .. rgb_hex })
                kind.menu_hl_group = group
                kind.menu = "    " .. " "
              end
            end
            return kind
          end,
        },
        experimental = {
          -- ghost_text = true,
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.scopes,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        window = {
          documentation = {
            border = BORDER_CHARS,
            winhighlight = "Normal:Normal,FloatBorder:Grey,CursorLine:PmenuSel,Search:None",
          },
          completion = {
            border = BORDER_CHARS,
            winhighlight = "Normal:Normal,FloatBorder:Grey,CursorLine:PmenuSel,Search:None",
          },
        },
        -- performance = {
        --   debounce = 0,
        --   throttle = 0,
        -- },
      })
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })

      -- sources
      local group = vim.api.nvim_create_augroup("my_cmp_settings", {})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "denite-filter", "TelescopePrompt", "LspRenamePrompt" },
        callback = function()
          cmp.setup.buffer({ enabled = false })
        end,
        group = group,
      })
    end,
  },
}

return {
  spec = spec,
  get_lsp_capabilities = function(...)
    return require("cmp_nvim_lsp").default_capabilities(...)
  end,
}
