local M = {}

local function define_reversed_hl(name, newname)
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  local bg = hl.foreground and string.format("#%x", hl.foreground) or nil
  local fg = hl.background and string.format("#%x", hl.background) or nil
  vim.api.nvim_set_hl(0, newname, { bg = bg, fg = fg })
end

local function define_linenr_bg(name, newname)
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  local nr = vim.api.nvim_get_hl_by_name("LineNr", true)
  local bg = hl.background and string.format("#%x", hl.background) or nil
  local fg = nr.foreground and string.format("#%x", nr.foreground) or nil
  vim.api.nvim_set_hl(0, newname, { bg = bg, fg = fg })
end

local function set_hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

local function setup_trouble_winbar_hl()
  local function get_hl(hl_name)
    local hl = vim.api.nvim_get_hl_by_name(hl_name, true)
    return {
      bg = hl.background and string.format("#%x", hl.background) or nil,
      fg = hl.foreground and string.format("#%x", hl.foreground) or nil,
    }
  end

  local palette = {
    Blue = get_hl "Blue",
    Grey = get_hl "Grey",
  }
  local highlights = {
    TroubleWinBarActiveMode = {
      bg = palette.Blue.bg,
      fg = palette.Blue.fg,
      underline = true,
    },
    TroubleWinBarInactiveMode = {
      bg = palette.Grey.bg,
      fg = palette.Grey.fg,
    },
  }
  for name, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, hl)
  end
end

local navic_highlights = {
  NavicIconsArray = { link = "@class" },
  NavicIconsBoolean = { link = "@boolean" },
  NavicIconsClass = { link = "CmpItemKindClass" },
  NavicIconsConstant = { link = "CmpItemKindConstant" },
  NavicIconsConstructor = { link = "CmpItemKindConstructor" },
  NavicIconsEnum = { link = "CmpItemKindEnum" },
  NavicIconsEnumMember = { link = "CmpItemKindEnumMember" },
  NavicIconsEvent = { link = "CmpItemKindEvent" },
  NavicIconsField = { link = "CmpItemKindField" },
  NavicIconsFile = { link = "CmpItemKindFile" },
  NavicIconsFunction = { link = "CmpItemKindFunction" },
  NavicIconsInterface = { link = "CmpItemKindInterface" },
  NavicIconsKey = { link = "@class" },
  NavicIconsKeyword = { link = "CmpItemKindKeyword" },
  NavicIconsMethod = { link = "CmpItemKindMethod" },
  NavicIconsModule = { link = "CmpItemKindModule" },
  NavicIconsNamespace = { link = "CmpItemKindNamespace" },
  NavicIconsNull = { link = "@class" },
  NavicIconsNumber = { link = "@number" },
  NavicIconsObject = { link = "@class" },
  NavicIconsOperator = { link = "CmpItemKindOperator" },
  NavicIconsPackage = { link = "@class" },
  NavicIconsProperty = { link = "CmpItemKindProperty" },
  NavicIconsString = { link = "@string" },
  NavicIconsStruct = { link = "CmpItemKindStruct" },
  NavicIconsTypeParameter = { link = "CmpItemKindTypeParameter" },
  NavicIconsVariable = { link = "CmpItemKindVariable" },
  NavicSeparator = { link = "NonText" },
  NavicText = { link = "Conceal" },
}

function M.setup()
  -- gitsigns.nvim
  define_linenr_bg("DiffAdd", "GitSignsAddNr")
  define_linenr_bg("DiffChange", "GitSignsChangeNr")
  define_linenr_bg("DiffDelete", "GitSignsDeleteNr")

  -- virtual text
  -- set_hl("VirtualTextError", { default = true, link = "CocErrorSign" })
  -- set_hl("VirtualTextWarn", { default = true, link = "CocWarningsign" })
  -- set_hl("VirtualTextInfo", { default = true, link = "CocInfoSign" })
  -- set_hl("VirtualTextHint", { default = true, link = "CocHintSign" })

  -- noice.nvim
  set_hl("MsgArea", { default = true, link = "LineNr" })
  set_hl("NoicePopup", { default = true, link = "Normal" })
  set_hl("NoicePopupBorder", { default = true, link = "Grey" })

  set_hl("NormalFloat", { link = "Normal" })
  set_hl("FloatBorder", { link = "Grey" })

  -- navic.nvim
  for name, hl in pairs(navic_highlights) do
    local v = vim.tbl_extend("keep", hl, { default = true })
    vim.api.nvim_set_hl(0, name, v)
  end

  -- illuminate.vim
  set_hl("illuminatedWord", { default = true, link = "CurrentWord" })
  set_hl("illuminatedWordRead", { default = true, link = "CurrentWord" })
  set_hl("illuminatedWordWrite", { default = true, link = "CurrentWord" })
  set_hl("illuminatedWordText", { default = true, link = "CurrentWord" })

  -- treehopper
  set_hl("TSNodeUnmatched", { link = "HopUnmatched" })
  set_hl("TSNodeKey", { link = "HopNextKey" })

  -- trouble.nvim
  setup_trouble_winbar_hl()
end

return M
