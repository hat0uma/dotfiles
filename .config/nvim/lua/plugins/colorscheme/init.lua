local M = {
  require "plugins.colorscheme.everforest",
  require "plugins.colorscheme.catppuccin",
}
setmetatable(M, {
  __index = {
    --- @return MyStatuslinePalette
    get_statusline_palette = function()
      return require("plugins.colorscheme.catppuccin").get_statusline_palette()
    end,
  },
})

return M
