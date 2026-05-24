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
    local frappe = require("rose-pine.palette").base("frappe")
    --- @type table <string,string>
    local palette = {
      bg = frappe.base,
      bg2 = frappe.mantle,
      fg = frappe.text,
      -- other colors
      yellow = frappe.yellow,
      cyan = frappe.sapphire,
      darkblue = frappe.lavender,
      green = frappe.green,
      orange = frappe.peach,
      purple = frappe.mauve,
      magenta = frappe.pink,
      grey = frappe.overlay1,
      blue = frappe.blue,
      red = frappe.red,
    }
    palette.separator_highlight = { palette.fg, palette.bg }
    palette.vimode_fg = frappe.base
    palette.vimode_override = {
      n = { color = palette.blue },
      v = { color = palette.green },
      [""] = { color = palette.green },
      V = { color = palette.green },
    }
    return palette
  end,
}
