return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false,
  config = function()
    require("rose-pine").setup({
      variant = "auto", -- auto, main, moon, or dawn
      dark_variant = "moon", -- main, moon, or dawn
      -- dim_inactive_windows = true,
      styles = {
        italic = false,
        bold = true,
        transparency = false,
      },
      palette = {
        dawn = {
          text = "#575279",
        },
      },
      highlight_groups = {
        Comment = { fg = "muted" },
      },
    })
    vim.cmd.colorscheme("rose-pine-dawn")
  end,

  --- @return rc.StatuslinePalette
  get_statusline_palette = function()
    local rosepine = require("rose-pine.palette")
    --- @type table <string,string>
    local palette = {
      bg = rosepine.base,
      bg2 = rosepine.surface,
      fg = rosepine.text,
      -- other colors
      yellow = rosepine.gold,
      cyan = rosepine.foam,
      darkblue = rosepine.pine,
      green = rosepine.leaf,
      orange = rosepine.rose,
      purple = rosepine.iris,
      magenta = rosepine.rose,
      grey = rosepine.muted,
      blue = rosepine.foam,
      red = rosepine.love,
    }
    palette.separator_highlight = { palette.fg, palette.bg }
    palette.vimode_fg = rosepine.base
    palette.vimode_override = {
      n = { color = rosepine.rose },
      v = { color = rosepine.iris },
      [""] = { color = rosepine.iris },
      V = { color = rosepine.iris },
    }
    return palette
  end,
}
