local colorschemes = {
  everforest = require "plugins.colorscheme.everforest",
  kanagawa = require "plugins.colorscheme.kanagawa",
}

--- @param opts { startup:string }
local function colors(opts)
  local specs = {}
  for name, spec in pairs(colorschemes) do
    if name == opts.startup then
      local config = spec.config
      spec.config = function()
        config()
        vim.cmd.colorscheme(name)
      end
      spec.lazy = false
      spec.priority = 999
    else
      spec.lazy = true
    end
    table.insert(specs, spec)
  end

  local group = vim.api.nvim_create_augroup("colorscheme_aug", {})
  vim.api.nvim_create_autocmd("Colorscheme", {
    callback = function()
      require("plugins.colorscheme.highlights").setup()
    end,
    group = group,
  })

  setmetatable(specs, {
    __index = {
      --- @return MyStatuslinePalette
      get_statusline_palette = function()
        return colorschemes[opts.startup].get_statusline_palette()
      end,
    },
  })
  return specs
end

return colors { startup = "kanagawa" }
