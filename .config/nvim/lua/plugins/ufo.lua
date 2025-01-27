return {
  "kevinhwang91/nvim-ufo",
  event = "VeryLazy",
  init = function()
    vim.keymap.set("n", "zR", function()
      require("ufo").openAllFolds()
    end)
    vim.keymap.set("n", "zM", function()
      require("ufo").closeAllFolds()
    end)
    vim.keymap.set("n", "<Tab>", "za") -- toggle folding
  end,
  config = function()
    require("ufo").setup({
      enable_get_fold_virt_text = true,
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate, ctx)
        local result = {}
        local first_line = ctx.get_fold_virt_text(lnum)
        local last_line = ctx.get_fold_virt_text(end_lnum)
        vim.list_extend(result, first_line)
        vim.list_extend(result, {
          { " ", "UfoPreviewCursorLine" },
          { " ... ", "UfoFoldedEllipsis" },
          { " ", "UfoPreviewCursorLine" },
        })
        for _, chunk in ipairs(last_line) do
          if vim.trim(chunk[1]):len() ~= 0 then
            table.insert(result, chunk)
          end
        end

        return result
      end,
    })
  end,
  dependencies = { "kevinhwang91/promise-async" },
}
