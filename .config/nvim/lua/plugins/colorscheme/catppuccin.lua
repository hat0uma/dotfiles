return {
  "catppuccin/nvim",
  name = "catppuccin",
  cond = not vim.g.vscode,
  lazy = false,
  priority = 999,
  config = function()
    require("catppuccin").setup({
      flavour = "frappe",
      integrations = {
        aerial = true,
        cmp = true,
        flash = true,
        gitsigns = true,
        hop = true,
        illuminate = true,
        lightspeed = true,
        lsp_trouble = false,
        markdown = true,
        mason = true,
        neotest = true,
        neogit = true,
        overseer = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = {
          enabled = false,
          custom_bg = "NONE",
        },
        indent_blankline = {
          enabled = true,
          scope_color = "overlay1",
          colored_indent_levels = false,
        },
      },
      dim_inactive = {
        enabled = false,
      },
    })

    vim.api.nvim_set_hl(0, "Blue", { fg = "#7FBBB3" })
    vim.api.nvim_set_hl(0, "CurrentWord", { bg = "#3d484d" })

    vim.cmd.colorscheme("catppuccin")
    require("plugins.colorscheme.highlights").setup()
  end,
  --- @return rc.StatuslinePalette
  get_statusline_palette = function()
    local frappe = require("catppuccin.palettes").get_palette("frappe")
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
