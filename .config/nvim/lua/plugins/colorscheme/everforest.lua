local M = {
  "sainnhe/everforest",
  enabled = false,
  init = function()
    vim.g.everforest_background = "hard"
    vim.g.everforest_ui_contrast = "high"
    vim.g.everforest_better_performance = 1
  end,
  config = function() end,
}

setmetatable(M, {
  __index = {
    --- @return MyStatuslinePalette
    ---@diagnostic disable: no-unknown
    get_statusline_palette = function()
      local configuration = vim.fn["everforest#get_configuration"]()
      local everforest = vim.fn["everforest#get_palette"](configuration.background, configuration.colors_override)
      local palette = {
        bg = everforest.bg0[1],
        bg2 = everforest.bg2[1],
        -- fg = everforest.statusline2[1],
        fg = everforest.grey2[1],
        vimode_fg = everforest.bg2[1],
        -- other colors
        yellow = everforest.yellow[1],
        cyan = everforest.aqua[1],
        darkblue = everforest.blue[1],
        green = everforest.green[1],
        orange = everforest.orange[1],
        purple = everforest.purple[1],
        magenta = everforest.purple[1],
        grey = everforest.grey1[1],
        blue = everforest.blue[1],
        red = everforest.red[1],
      }
      palette.separator_highlight = { palette.fg, palette.bg }
      palette.vimode_fg = palette.bg2
      return palette
    end,
  },
})
return M
