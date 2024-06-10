local function config()
  --- @type MyStatuslinePalette
  local palette = require("plugins.colorscheme").get_statusline_palette()

  local buffer_name = function()
    local filetype = vim.bo.filetype
    local bufname = vim.fn.bufname()

    local name = ""
    if filetype == "simplenote-text" then
      name = vim.fn.getline(1)
    elseif bufname == "" then
      name = "[NONAME]"
    else
      name = vim.fn.simplify(bufname)
      name = vim.fn.fnamemodify(name, ":~:."):gsub("\\", "/")
    end
    return name
  end

  local buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand "%:t") ~= 1
  end

  local modes = {
    n = { color = palette.green, alias = "NORMAL" },
    i = { color = palette.fg, alias = "INSERT" },
    v = { color = palette.blue, alias = "VISUAL" },
    [""] = { color = palette.blue, alias = "V-BLOCK" },
    V = { color = palette.blue, alias = "V-LINE" },
    c = { color = palette.red, alias = "COMMAND" },
    no = { color = palette.magenta, alias = "NORMAL" },
    s = { color = palette.orange, alias = "SELECT" },
    S = { color = palette.orange, alias = "S-LINE" },
    [""] = { color = palette.orange, alias = "S-BLOCK" },
    ic = { color = palette.yellow, alias = "INSERT" },
    R = { color = palette.purple, alias = "REPLACE" },
    Rv = { color = palette.purple, alias = "VIRTUAL" },
    cv = { color = palette.red, alias = "NORMAL" },
    ce = { color = palette.red, alias = "COMMAND" },
    r = { color = palette.cyan, alias = "HIT-ENTER" },
    rm = { color = palette.cyan, alias = "--MORE" },
    ["r?"] = { color = palette.cyan, alias = ":CONFIRM" },
    ["!"] = { color = palette.red, alias = "SHELL" },
    t = { color = palette.red, alias = "TERMINAL" },
  }

  -- Extend with vimode_override if exists
  modes = vim.tbl_deep_extend("force", modes, palette.vimode_override or {})

  local lualine_config = {
    options = {
      icons_enabled = true,
      theme = {
        normal = {
          a = { fg = palette.vimode_fg, bg = palette.bg, gui = "bold" },
          b = { fg = palette.fg, bg = palette.bg2 },
          c = { fg = palette.fg, bg = palette.bg },
        },
        insert = { a = { fg = palette.vimode_fg, bg = palette.bg, gui = "bold" } },
        visual = { a = { fg = palette.vimode_fg, bg = palette.bg, gui = "bold" } },
        replace = { a = { fg = palette.vimode_fg, bg = palette.bg, gui = "bold" } },
        command = { a = { fg = palette.vimode_fg, bg = palette.bg, gui = "bold" } },
      },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(alias)
            if vim.fn.exists "skkeleton#mode" ~= 0 then
              --- @type string
              local skkeleton_mode = vim.fn["skkeleton#mode"]()
              alias = skkeleton_mode ~= "" and alias .. "-" .. skkeleton_mode or alias
            end
            vim.cmd("hi GalaxyViMode guibg=" .. modes[vim.fn.mode()].color)
            return alias
          end,
          color = function()
            return { fg = palette.vimode_fg, bg = modes[vim.fn.mode()].color, gui = "bold" }
          end,
        },
      },
      lualine_b = {
        {
          "branch",
          icon = "",
          color = { fg = palette.fg, bg = palette.bg2 },
        },
      },
      lualine_c = {
        {
          buffer_name,
          color = { fg = palette.fg, bg = palette.bg },
        },
        {
          "recording",
          fmt = function()
            local reg = vim.fn.reg_recording()
            return reg ~= "" and string.format("recording @%s", vim.fn.reg_recording()) or ""
          end,
          condition = function()
            return vim.o.cmdheight == 0
          end,
          color = { fg = "#ff9e64", bg = palette.bg },
        },
      },
      lualine_x = { "overseer" },
      lualine_y = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          sections = { "error", "warn", "info", "hint" },
          diagnostics_color = {
            error = { fg = palette.red },
            warn = { fg = palette.yellow },
            info = { fg = palette.green },
            hint = { fg = palette.blue },
          },
        },
        {
          "encoding",
          fmt = string.lower,
          color = { fg = palette.fg, bg = palette.bg },
        },
        {
          "fileformat",
          fmt = function()
            local ff = vim.bo.fileformat
            local name_tbl = {
              unix = "lf",
              dos = "crlf",
              mac = "cr",
            }
            return name_tbl[ff] or ""
          end,
          color = { fg = palette.fg, bg = palette.bg },
          cond = buffer_not_empty,
        },
        -- {
        --   "filetype",
        --   color = { fg = palette.fg, bg = palette.bg },
        -- },
      },
      lualine_z = {
        {
          "location",
          color = { fg = palette.bg, bg = palette.fg },
        },
      },
    },
    inactive_sections = {
      lualine_c = { "filename" },
      lualine_x = { "location" },
    },
    tabline = {},
    extensions = {},
  }
  require("lualine").setup(lualine_config)
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "Colorscheme",
    config = config,
    enabled = true,
  },
}
