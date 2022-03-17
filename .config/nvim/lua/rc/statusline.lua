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

local M = {}

gl.short_line_list = {
  "defx",
  "deol",
  "gina-status",
  "gina-log",
  "gina-branch",
  "simplenote",
  "translate",
  "packer",
}

local one_dark_colors = {
  bg = "#2e3440",
  fg = "#81a1c1",
  line_bg = "#2e3440",
  fg_green = "#6d96a5",
  yellow = "#fabd2f",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#608B4E",
  orange = "#FF8800",
  purple = "#5d4d7a",
  magenta = "#d16d9e",
  grey = "#c0c0c0",
  blue = "#569CD6",
  red = "#D16969",
}

local ever_forest = vim.fn["everforest#get_palette"](vim.fn["everforest#get_configuration"]().background)
local ever_forest_palette = {
  bg = ever_forest.bg2[1],
  fg = ever_forest.fg[1],
  line_bg = ever_forest.bg3[1],
  bg_red = ever_forest.bg_red[1],
  bg_green = ever_forest.bg_green[1],
  yellow = ever_forest.yellow[1],
  cyan = ever_forest.aqua[1],
  darkblue = ever_forest.blue[1],
  green = ever_forest.green[1],
  orange = ever_forest.orange[1],
  purple = ever_forest.purple[1],
  magenta = ever_forest.purple[1],
  grey = ever_forest.grey1[1],
  blue = ever_forest.blue[1],
  red = ever_forest.red[1],
}

local pinkmare_palette = {
  bg = "#202330",
  fg = "#FAE8B6",
  line_bg = "#472541",
  bg_red = "#f2448b",
  bg_green = "#333b2f",
  yellow = "#ffc85b",
  cyan = "#87c095",
  darkblue = "#203a41",
  green = "#9cd162",
  orange = "#ffb347",
  purple = "#d9bcef",
  magenta = "#d16d9e",
  grey = "#444444",
  blue = "#eba4ac",
  red = "#FF38A2",
}
local palette = ever_forest_palette

--  functions
local deol_edit_buffer = function()
  return string.find(fn.expand "%:p", "deol-edit", 1, true) ~= nil
end

local buffer_name = function()
  local filetype = vim.bo.filetype
  local bufname = fn.bufname()

  local name = ""
  if filetype == "simplenote-text" then
    name = fn.getline(1)
  elseif bufname == "" then
    name = "[NONAME]"
  else
    name = fn.fnamemodify(bufname, ":~:.")
  end
  return name
end

local buffer_not_empty = function()
  if fn.empty(fn.expand "%:t") ~= 1 then
    return true
  end
  return false
end

local checkwidth = function()
  local squeeze_width = fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local FirstElement = {
  -- provider = function() return '▊ ' end,
  provider = function()
    return "  "
  end,
  highlight = { palette.blue, palette.bg },
}

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
    return "  " .. alias .. " "
    -- return "  " .. alias.. " "
  end,
  separator = " ",
  separator_highlight = { palette.bg, palette.bg },
  -- highlight = {palette.bg, palette.bg, "bold"}
  highlight = { palette.bg, palette.bg },
}

local FileIcon = {
  provider = "FileIcon",
  condition = buffer_not_empty,
  highlight = { fileinfo.get_file_icon_color, palette.bg },
}

local FileName = {
  provider = buffer_name,
  condition = function()
    return not deol_edit_buffer()
  end,
  separator = " ",
  separator_highlight = { palette.purple, palette.bg },
  -- highlight = {palette.fg,palette.bg}
  highlight = { ever_forest.grey2[1], palette.bg },
}

local LineInfo = {
  provider = "LineColumn",
  condition = function()
    return not deol_edit_buffer()
  end,
  separator = " ",
  separator_highlight = { palette.gray, palette.bg },
  highlight = { palette.gray, palette.bg },
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
  separator_highlight = { palette.blue, palette.bg },
  highlight = { palette.fg, palette.bg },
}

local DiagnosticError = {
  provider = "DiagnosticError",
  separator = " ",
  icon = " ",
  highlight = { palette.red, palette.bg },
  separator_highlight = { palette.bg, palette.bg },
}
local DiagnosticWarn = {
  provider = "DiagnosticWarn",
  -- separator = " ",
  icon = " ",
  highlight = { palette.yellow, palette.bg },
  separator_highlight = { palette.bg, palette.bg },
}

local DiagnosticInfo = {
  -- separator = " ",
  provider = "DiagnosticInfo",
  icon = " ",
  highlight = { palette.green, palette.bg },
  separator_highlight = { palette.bg, palette.bg },
}

local DiagnosticHint = {
  provider = "DiagnosticHint",
  separator = " ",
  icon = " ",
  highlight = { palette.blue, palette.bg },
  separator_highlight = { palette.bg, palette.bg },
}

local GitIcon = {
  separator = "  ",
  provider = function()
    return " "
  end,
  condition = function()
    return condition.check_git_workspace() and not deol_edit_buffer()
  end,
  highlight = { palette.orange, palette.bg },
  separator_highlight = { palette.bg, palette.bg },
}

local GitBranch = {
  provider = function()
    return vcs.get_git_branch() .. " "
  end,
  condition = condition.check_git_workspace,
  separator = "",
  separator_highlight = { palette.bg, palette.bg },
  highlight = { palette.orange, palette.bg, "bold" },
}

local FileType = {
  provider = buffer.get_buffer_filetype,
  separator = " ",
  separator_highlight = { palette.gray, palette.bg },
  highlight = { palette.gray, palette.bg },
}

local FileEncode = {
  provider = fileinfo.get_file_encode,
  separator = " ",
  separator_highlight = { palette.gray, palette.bg },
  highlight = { palette.gray, palette.bg },
}

local FileFormat = {
  provider = function()
    local ff = vim.bo.fileformat
    local name_tbl = {
      unix = "LF",
      dos = "CRLF",
      mac = "CR",
    }
    return name_tbl[ff] or ""
  end,
  separator = " ",
  separator_highlight = { palette.gray, palette.bg },
  highlight = { palette.gray, palette.bg },
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
  -- separator_highlight = {"NONE", palette.bg},
  highlight = { palette.orange, "bold" },
}
local BufferIcon = {
  provider = "BufferIcon",
  highlight = { palette.fg, palette.bg },
}

function M.setup()
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
  table.insert(section.left, { FileName = FileName })

  table.insert(section.right, { DiagnosticError = DiagnosticError })
  table.insert(section.right, { DiagnosticWarn = DiagnosticWarn })
  table.insert(section.right, { DiagnosticInfo = DiagnosticInfo })
  table.insert(section.right, { DiagnosticHint = DiagnosticHint })

  table.insert(section.right, { LineInfo = LineInfo })
  -- table.insert(section.right,{FileType = FileType})
  table.insert(section.right, { FileEncode = FileEncode })
  table.insert(section.right, { FileFormat = FileFormat })
  table.insert(section.right, { GitIcon = GitIcon })
  table.insert(section.right, { GitBranch = GitBranch })

  table.insert(section.short_line_right, { BufferType = BufferType })
  table.insert(section.short_line_right, { BufferIcon = BufferIcon })
end

return M
