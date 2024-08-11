local M = {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
}

function M.config()
  local notify = require("notify")
  local stages = require("plugins.notify.fade_in_slide_out_bottom_up")
  vim.notify = notify
  notify.setup({
    -- render = "minimal",
    minimum_width = 15,
    max_width = 50,
    -- stages = stages,
  })
end

return M
