local M = {
  "glepnir/galaxyline.nvim",
  -- lazy = false,
  event = "Colorscheme",
}

--- @class MyStatuslinePalette
--- @field bg string
--- @field bg2 string
--- @field fg string
--- @field vimode_fg string
--- @field yellow string
--- @field cyan string
--- @field darkblue string
--- @field green string
--- @field orange string
--- @field purple string
--- @field magenta string
--- @field grey string
--- @field blue string
--- @field red string
--- @field separator_highlight string
--- @field vimode_override table?

local function setup_statusline()
  local fn = vim.fn
  local gl = require "galaxyline"
  local fileinfo = require "galaxyline.provider_fileinfo"
  local buffer = require "galaxyline.provider_buffer"
  local condition = require "galaxyline.condition"
  local section = gl.section

  gl.short_line_list = {
    -- "defx",
    -- "deol",
    -- "gina-status",
    -- "gina-log",
    -- "gina-branch",
    -- "simplenote",
    -- "translate",
    -- "packer",
  }
  --- @type MyStatuslinePalette
  local palette = require("plugins.colorscheme").get_statusline_palette()

  local buffer_name = function()
    local filetype = vim.bo.filetype
    local bufname = fn.bufname()

    local name = ""
    if filetype == "simplenote-text" then
      name = fn.getline(1)
    elseif bufname == "" then
      name = "[NONAME]"
    else
      name = fn.simplify(bufname)
      name = fn.fnamemodify(name, ":~:."):gsub("\\", "/")
    end
    return name
  end

  local buffer_not_empty = function()
    return fn.empty(fn.expand "%:t") ~= 1
  end

  local checkwidth = function()
    local squeeze_width = fn.winwidth(0) / 2
    return squeeze_width > 40
  end

  local ViMode = {
    provider = function()
      -- auto change color according the vim mode
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
      modes = vim.tbl_deep_extend("force", modes, palette.vimode_override or {})
      local mode = modes[fn.mode()]
      local alias = mode.alias
      local skkeleton_mode = ""
      if fn.exists "skkeleton#mode" ~= 0 then
        skkeleton_mode = fn["skkeleton#mode"]()
      end
      if skkeleton_mode ~= "" then
        alias = mode.alias .. "-" .. skkeleton_mode
      end
      vim.cmd("hi GalaxyViMode guibg=" .. mode.color)
      -- return "  " .. alias .. " "
      return "  " .. alias .. " "
      -- return "  " .. alias.. " "
    end,
    separator = "",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.vimode_fg, palette.bg, "bold" },
  }

  local FileIcon = {
    provider = "FileIcon",
    condition = buffer_not_empty,
    highlight = { fileinfo.get_file_icon_color, palette.bg },
  }

  local FileName = {
    provider = function()
      local name = buffer_name()
      local modified_icon = "*"
      if vim.bo.modifiable and vim.bo.modified then
        name = name .. modified_icon
      end
      return "  " .. name
    end,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  local Navic = {
    provider = function()
      -- needs
      if not require("nvim-navic").is_available() then
        return ""
      end
      local loc = require("nvim-navic").get_location()
      if loc ~= "" then
        loc = "> " .. loc
      end
      return loc
    end,
    condition = function()
      return require("nvim-navic").is_available
    end,
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  local LineInfo = {
    provider = function()
      local line = vim.fn.line "."
      local column = vim.fn.col "."
      return string.format(" %3d:%-2d ", line, column)
    end,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.bg, palette.fg },
  }

  local Recording = {
    provider = function()
      local reg = vim.fn.reg_recording()
      return reg ~= "" and string.format("recording @%s", vim.fn.reg_recording()) or ""
    end,
    condition = function()
      return vim.o.cmdheight == 0
    end,
    -- provider = require("noice").api.statusline.mode.get,
    -- condition = require("noice").api.statusline.mode.has,
    highlight = { "#ff9e64", palette.bg },
  }

  local DiffAdd = {
    provider = "DiffAdd",
    condition = checkwidth,
    icon = " ",
    highlight = { palette.green, palette.bg },
  }

  local DiffModified = {
    provider = "DiffModified",
    condition = checkwidth,
    icon = "柳",
    highlight = { palette.yellow, palette.bg },
  }
  local DiffRemove = {
    provider = "DiffRemove",
    condition = checkwidth,
    icon = " ",
    highlight = { palette.red, palette.bg },
  }

  local FileSize = {
    provider = "FileSize",
    separator = " ",
    condition = buffer_not_empty,
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  local DiagnosticError = {
    provider = "DiagnosticError",
    separator = " ",
    icon = " ",
    highlight = { palette.red, palette.bg },
    separator_highlight = palette.separator_highlight,
  }
  local DiagnosticWarn = {
    provider = "DiagnosticWarn",
    -- separator = " ",
    icon = " ",
    highlight = { palette.yellow, palette.bg },
    separator_highlight = palette.separator_highlight,
  }

  local DiagnosticInfo = {
    -- separator = " ",
    provider = "DiagnosticInfo",
    icon = " ",
    highlight = { palette.green, palette.bg },
    separator_highlight = palette.separator_highlight,
  }

  local DiagnosticHint = {
    provider = "DiagnosticHint",
    separator = " ",
    icon = " ",
    highlight = { palette.blue, palette.bg },
    separator_highlight = palette.separator_highlight,
  }

  local function git_status()
    local s = require("rc.git.component").get_status_cached()
    if not s then
      return ""
    end

    local ahead_arrow = s.branch.ab.a ~= 0 and "↑" or ""
    local behind_arrow = s.branch.ab.b ~= 0 and "↓" or ""
    local change_num = #s.ordinary_changed + #s.renamed_or_copied + #s.unmerged + #s.ignored + #s.untracked
    local dirty = change_num ~= 0
    return string.format("%s%s %s%s", s.branch.head, dirty and "*" or "", ahead_arrow, behind_arrow)
  end

  local GitBranch = {
    provider = function()
      local icon = " "
      return string.format("  %s%s", icon, git_status())
    end,
    condition = condition.check_git_workspace,
    separator = " ",
    separator_highlight = { palette.fg, palette.bg2 },
    highlight = { palette.fg, palette.bg2 },
  }

  local FileType = {
    provider = buffer.get_buffer_filetype,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  local FileEncode = {
    provider = function()
      return fileinfo.get_file_encode():lower()
    end,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  local FileFormat = {
    provider = function()
      local ff = vim.bo.fileformat
      local name_tbl = {
        unix = "lf",
        dos = "crlf",
        mac = "cr",
      }
      return name_tbl[ff] or ""
    end,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.fg, palette.bg },
  }

  -- short lines
  local BufferType = {
    provider = function()
      if vim.tbl_contains(gl.short_line_list, vim.bo.filetype) then
        return vim.bo.filetype .. " "
      else
        return buffer_name()
      end
    end,
    separator = " ",
    separator_highlight = palette.separator_highlight,
    highlight = { palette.orange, "bold" },
  }
  local BufferIcon = {
    provider = "BufferIcon",
    highlight = { palette.fg, palette.bg },
  }

  local function clear(t)
    for k in pairs(t) do
      t[k] = nil
    end
  end

  clear(section.left)
  clear(section.right)
  clear(section.short_line_left)
  clear(section.short_line_right)

  -- section.left[1] = {FirstElement = FirstElement}
  table.insert(section.left, { ViMode = ViMode })
  table.insert(section.left, { GitBranch = GitBranch })
  table.insert(section.left, { FileName = FileName })
  table.insert(section.left, { Recording = Recording })
  -- table.insert(section.left, { nvimGPS = nvimGPS })

  -- table.insert(section.right,{FileType = FileType})
  table.insert(section.right, { DiagnosticError = DiagnosticError })
  table.insert(section.right, { DiagnosticWarn = DiagnosticWarn })
  table.insert(section.right, { DiagnosticInfo = DiagnosticInfo })
  table.insert(section.right, { DiagnosticHint = DiagnosticHint })
  table.insert(section.right, { FileEncode = FileEncode })
  table.insert(section.right, { FileFormat = FileFormat })
  table.insert(section.right, { LineInfo = LineInfo })

  table.insert(section.short_line_right, { BufferType = BufferType })
  table.insert(section.short_line_right, { BufferIcon = BufferIcon })
end

function M.config()
  setup_statusline()
end

return M
