return {
  "vim-skk/denops-skkeleton.vim",
  config = function()
    require("plugins.denops").register "skkeleton"

    vim.keymap.set("i", "<C-j>", "<Plug>(skkeleton-toggle)", {})
    vim.keymap.set("c", "<C-j>", "<Plug>(skkeleton-toggle)", {})

    local function my_skkeleton_init()
      vim.fn["skkeleton#config"] {
        eggLikeNewline = true,
        registerConvertResult = true,
        userJisyo = vim.fn.expand "~/.skk-jisyo",
        globalJisyo = vim.fn.expand "~/.eskk/SKK-JISYO.L",
        globalJisyoEncoding = "utf-8",
        markerHenkan = "<>",
        markerHenkanSelect = ">>",
      }
      vim.fn["skkeleton#register_kanatable"]("rom", {
        jj = "escape",
      })
    end

    local group = vim.api.nvim_create_augroup("my_skkeleton_settings", {})
    vim.api.nvim_create_autocmd(
      "User",
      { pattern = "skkeleton-initialize-pre", callback = my_skkeleton_init, group = group }
    )
  end,
  dependencies = { "denops.vim" },
  keys = { { "<C-j>", mode = { "i", "c" } } },
  -- build = require("plugins.denops").cache "skkeleton",
}
