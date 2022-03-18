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

aug("my_skkeleton_settings", {
  au("User", { pattern = "skkeleton-initialize-pre", callback = my_skkeleton_init }),
})
