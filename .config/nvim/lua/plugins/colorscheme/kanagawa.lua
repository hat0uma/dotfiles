local M = {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 999,
  config = function()
    vim.opt.fillchars:append {
      horiz = "━",
      horizup = "┻",
      horizdown = "┳",
      vert = "┃",
      vertleft = "┨",
      vertright = "┣",
      verthoriz = "╋",
    }
    require("kanagawa").setup { globalStatus = true, dimInactive = true }

    vim.api.nvim_set_hl(0, "Blue", { fg = "#7FBBB3" })
    vim.api.nvim_set_hl(0, "CurrentWord", { bg = "#3d484d" })
  end,
}

setmetatable(M, {
  __index = {
    --- @return MyStatuslinePalette
    get_statusline_palette = function()
      local kanagawa = require("kanagawa.colors").setup()
      local palette = {
        bg = kanagawa.bg,
        bg2 = kanagawa.bg_dark,
        fg = kanagawa.fg,
        -- other colors
        yellow = kanagawa.carpYellow,
        cyan = kanagawa.waveAqua1,
        darkblue = kanagawa.waveBlue1,
        green = kanagawa.springGreen,
        orange = kanagawa.surimiOrange,
        purple = kanagawa.oniViolet,
        magenta = kanagawa.peachRed,
        grey = kanagawa.katanaGray,
        blue = kanagawa.springBlue,
        red = kanagawa.peachRed,
      }
      palette.separator_highlight = { palette.fg, palette.bg }
      palette.vimode_fg = kanagawa.sumiInk0
      return palette
    end,
  },
})
return M
