local M = {}

--- @class WinbarItem
--- @field hlgroup string
--- @field text string
--- @param item WinbarItem
--- @return string
local function winbar_item(item)
  return "%#" .. item.hlgroup .. "#" .. item.text .. "%#Normal#"
end

local function oil_location()
  return winbar_item {
    text = require("oil").get_current_dir() or "",
    hlgroup = "Conceal",
  }
end

local config = {
  default = function()
    local success, navic = pcall(require, "nvim-navic")
    if success then
      return navic.get_location()
    else
      return ""
    end
  end,
  ft = {
    oil = oil_location,
  },
}

function M.provider()
  local ft = vim.bo.ft
  if config.ft[ft] then
    return config.ft[ft]()
  else
    return config.default()
  end
end

function M.setup()
  vim.go.winbar = "%{%v:lua.require'rc.winbar'.provider()%}"
end

return M
