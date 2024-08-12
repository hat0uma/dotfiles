local function config()
  --- @type MyStatuslinePalette
  local palette = require("plugins.colorscheme").get_statusline_palette()

  local buffer_name = function()
    local filetype = vim.bo.filetype
    local bufname = vim.fn.bufname()

    local name = ""
    if bufname == "" then
      name = "[NONAME]"
    else
      name = vim.fn.simplify(bufname)
      name = vim.fn.fnamemodify(name, ":~:."):gsub("\\", "/")
    end
    return name
  end

  local buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
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
          -- buffer
          function()
            local name = buffer_name()
            local modified_icon = "*"
            return vim.bo.modifiable and vim.bo.modified and name .. modified_icon or name
          end,
          color = { fg = palette.fg, bg = palette.bg },
        },
        {
          -- recording,
          function()
            local reg = vim.fn.reg_recording()
            return reg ~= "" and string.format("recording @%s", vim.fn.reg_recording()) or ""
          end,
          condition = function()
            return vim.o.cmdheight == 0
          end,
          color = { fg = "#ff9e64", bg = palette.bg },
        },
      },
      lualine_x = {},
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

  -- autocmds
  vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
      require("lualine").refresh({ place = { "statusline" } })
    end,
  })
  vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = vim.schedule_wrap(function()
      require("lualine").refresh({ place = { "statusline" } })
    end),
  })

  -- lazy load overseer
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(ev)
      if ev.data == "overseer.nvim" then
        require("lualine").setup({ sections = { lualine_x = { "overseer" } } })
      end
    end,
  })
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "Colorscheme",
    config = config,
    enabled = true,
  },
}
