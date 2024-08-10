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
  return winbar_item({
    text = require("oil").get_current_dir() or "",
    hlgroup = "Conceal",
  })
end

M.config = {
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
    trouble = require("plugins.trouble").winbar,
  },
}

function M.provider()
  local ft = vim.bo.ft
  if M.config.ft[ft] then
    return M.config.ft[ft]()
  else
    return M.config.default()
  end
end

function M.setup()
  vim.go.winbar = "%{%v:lua.require'rc.winbar'.provider()%}"
end

return M
