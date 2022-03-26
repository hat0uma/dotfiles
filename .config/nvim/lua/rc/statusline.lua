local cmd = vim.cmd
local fn = vim.fn
local gl = require "galaxyline"
-- local diagnostic = require('galaxyline.provider_diagnostic')
local vcs = require "galaxyline.providers.vcs"
local fileinfo = require "galaxyline.providers.fileinfo"
-- local extension = require('galaxyline.provider_extensions')
-- local colors = require('galaxyline.colors')
local buffer = require "galaxyline.providers.buffer"
-- local whitespace = require('galaxyline.provider_whitespace')
-- local lspclient = require('galaxyline.provider_lsp')
local condition = require "galaxyline.condition"
local section = gl.section
local gps = require "nvim-gps"

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

local everforest = vim.fn["everforest#get_palette"](vim.fn["everforest#get_configuration"]().background)
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

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
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
    local mode = modes[fn.mode()]
    local alias = mode.alias
    local skkeleton_mode = ""
    if fn.exists "skkeleton#mode" ~= 0 then
      skkeleton_mode = fn["skkeleton#mode"]()
    end
    if skkeleton_mode ~= "" then
      alias = mode.alias .. "-" .. skkeleton_mode
    end
    cmd("hi GalaxyViMode guibg=" .. mode.color)
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

local nvimGPS = {
  provider = function()
    local loc = gps.get_location()
    if loc ~= "" then
      loc = "> " .. loc
    end
    return loc
  end,
  condition = gps.is_available,
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

local GitBranch = {
  provider = function()
    -- local icon = " "
    local icon = " "
    local branch = vcs.get_git_branch() or ""
    return string.format("  %s%s ", icon, branch)
  end,
  condition = condition.check_git_workspace,
  -- separator = "  ",
  -- separator = "",
  separator = "",
  separator_highlight = { palette.bg2, palette.bg },
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
    if table.contains(gl.short_line_list, vim.bo.filetype) then
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
table.insert(section.left, { nvimGPS = nvimGPS })

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
