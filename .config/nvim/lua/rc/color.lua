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

local function setup()
  local group = vim.api.nvim_create_augroup("rc_colorscheme_settings", {})
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      -- gitsigns.nvim
      define_linenr_bg("GitSignsAddLn", "GitSignsAddNrBg")
      define_linenr_bg("GitSignsChangeLn", "GitSignsChangeNrBg")
      define_linenr_bg("GitSignsDeleteLn", "GitSignsDeleteNrBg")

      -- virtual text
      set_hl("VirtualTextError", { default = true, link = "CocErrorSign" })
      set_hl("VirtualTextWarn", { default = true, link = "CocWarningsign" })
      set_hl("VirtualTextInfo", { default = true, link = "CocInfoSign" })
      set_hl("VirtualTextHint", { default = true, link = "CocHintSign" })

      -- noice.nvim
      set_hl("MsgArea", { default = true, link = "LineNr" })

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
    end,
    nested = true,
    group = group,
  })
end

return { setup = setup }
